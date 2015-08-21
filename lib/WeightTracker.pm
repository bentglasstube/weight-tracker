package WeightTracker;

use Dancer2;
use Dancer2::Plugin::DBIC 'resultset';
use Data::FormValidator;
use Data::FormValidator::Constraints ':closures';
use Data::FormValidator::Constraints::DateTime ':all';

get '/' => sub {
  template 'index';
};

get '/register' => sub {
  template 'register';
};

post '/register' => sub {
  my $results = Data::FormValidator->check(
    scalar params, {
      required => [qw[email password name gender height birth_date]],
      optional => [qw[weight_goal]],
      constraint_methods => {
        email => [
          email(),
          sub {
            my ($dfv, $email) = @_;
            return not defined resultset('User')->find({ email => $email });
          },
        ],
        password => sub {
          my ($dfv, $password) = @_;
          return $password eq params->{pass2};
        },
        gender      => qr/^[mf]$/,
        height      => qr/^\d+(?:\D\d+\D*)?$/,
        birth_date  => to_datetime('%Y-%m-%d'),
        weight_goal => qr/^\d+$/,
      },
      filters       => 'trim',
      field_filters => {
        height => sub {
          my ($height) = @_;
          my @parts = split /\D/, $height;
          return @parts == 2 ? 12 * $parts[0] + $parts[1] : $parts[0];
        },
      },
    });

  if ($results->success) {
    if (my $user = resultset('User')->create(scalar $results->valid)) {
      session user => $user;
      redirect '/';
    }
  } else {
    delete params->{$_} for $results->invalid;
    template 'register',
      { errors => { map { $_ => 1 } $results->missing, $results->invalid }, };
  }
};

1;
