package WeightTracker::Schema::Result::Weight;

use base 'WeightTracker::Schema::Result';

__PACKAGE__->table('weight');

__PACKAGE__->add_columns(

  id => {
    data_type         => 'serial',
    is_auto_increment => 1,
    is_nullable       => 0,
  },

  user => {
    data_type   => 'integer',
    add_fk_index => 1,
    is_nullable => 0,
  },

  created => {
    data_type   => 'datetime',
    is_nullable => 0,
  },

  weight => {
    data_type   => 'real',
    is_nullable => 0,
  },

  body_fat => {
    data_type   => 'real',
    is_nullable => 1,
  },

);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(user => 'WeightTracker::Schema::Result::User');

1;

