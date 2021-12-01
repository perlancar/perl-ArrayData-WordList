package ArrayData::WordList;

use strict;

use Role::Tiny::With;
with 'ArrayDataRole::Spec::Basic';

# AUTHORITY
# DATE
# DIST
# VERSION

# STATS

sub new {
    my ($class, %args) = @_;

    my $wlname = delete $args{wordlist};
    defined $wlname or die "Please specify wordlist";

    require Module::Load::Util;
    my $wl = Module::Load::Util::instantiate_class_with_optional_args(
        {ns_prefix=>"WordList"}, $wlname);

    bless {
        wl => $wl,
        pos => 0, # iterator
    }, $class;
}

sub reset_iterator {
    my $self = shift;
    $self->{wl}->reset_iterator;
    $self->{pos} = 0;
}

sub get_next_item {
    my $self = shift;
    if (exists $self->{buf}) {
        $self->{pos}++;
        return delete $self->{buf};
    } else {
        my $word = $self->{pos} == 0 ? $self->{wordlist}->first_word : $self->{wordlist}->next_word;
        die "StopIteration" unless defined $word;
        $self->{pos}++;
        $word;
    }
}

sub has_next_item {
    my $self = shift;
    if (exists $self->{buf}) {
        return 1;
    }
    my $word = $self->{pos} == 0 ? $self->{wordlist}->first_word : $self->{wordlist}->next_word;
    return 0 unless defined $word;
    $self->{buf} = $word;
    1;
}

sub get_iterator_pos {
    my $self = shift;
    $self->{pos};
}

sub get_item_at_pos {
    my ($self, $pos) = @_;
    $self->reset_iterator if $self->{pos} > $pos;
    while (1) {
        die "Out of range" unless $self->has_next_item;
        my $item = $self->get_next_item;
        return $item if $self->{pos} > $pos;
    }
}

sub has_item_at_pos {
    my ($self, $pos) = @_;
    return 1 if $self->{pos} > $pos;
    while (1) {
        return 0 unless $self->has_next_item;
        $self->get_next_item;
        return 1 if $self->{pos} > $pos;
    }
}

1;
# ABSTRACT: Array data from a WordList::* module
