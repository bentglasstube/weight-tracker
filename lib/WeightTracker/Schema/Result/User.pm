package WeightTracker::Schema::Result::User;

use base 'WeightTracker::Schema::Result';

__PACKAGE__->load_components('EncodedColumn');

__PACKAGE__->table('user');

__PACKAGE__->add_columns(

  id => {
    data_type         => 'serial',
    is_auto_increment => 1,
    is_nullable       => 0,
  },

  email => {
    data_type   => 'varchar',
    is_nullable => 0,
    size        => 128,
  },

  name => {
    data_type   => 'varchar',
    is_nullable => 0,
    size        => 128,
  },

  password => {
    data_type           => 'char',
    size                => 60,
    is_nullable         => 0,
    encode_column       => 1,
    encode_class        => 'Crypt::Eksblowfish::Bcrypt',
    encode_args         => { cost => 10 },
    encode_check_method => 'verify_password',
  },

  gender => {
    data_type   => 'char',
    size        => 1,
    is_nullable => 0,
  },

  height => {
    data_type   => 'integer',
    extra       => { unsigned => 1 },
    is_nullable => 0,
  },

  birth_date => {
    data_type   => 'date',
    is_nullable => 0,
  },

  weight_goal => {
    data_type   => 'integer',
    extra       => { unsigned => 1 },
    is_nullable => 1,
  },

);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint(['email']);

__PACKAGE__->has_many(
  weights => 'WeightTracker::Schema::Result::Weight',
  { 'foreign.user' => 'self.id' },
  { cascade_copy   => 0, cascade_delete => 1 },
);

__PACKAGE__->has_many(
  events => 'WeightTracker::Schema::Result::Event',
  { 'foreign.user' => 'self.id' },
  { cascade_copy   => 0, cascade_delete => 1 },
);

sub height_ft_in {
  my ($self) = @_;

  my $feet   = int $self->height / 12;
  my $inches = $self->height % 12;

  return $feet, $inches;
}

sub age {
  my ($self) = @_;

  my $duration = DateTime->now() - $self->birth_date;

  return int $duration->years;
}

sub current_weight {
  my ($self) = @_;

  my $latest = $self->weights(
    {},
    {
      order_by => { -desc => 'created' },
      rows     => 1
    }
  )->single;

  return $latest ? $latest->weight : undef;
}

1;
