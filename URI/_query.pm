package URI::_query;

use strict;
use URI ();
use URI::Escape qw(uri_unescape);

sub query
{
    my $self = shift;
    $$self =~ m,^([^?\#]*)(?:\?([^\#]*))?(.*)$,s or die;
    
    if (@_) {
	my $q = shift;
	$$self = $1;
	if (defined $q) {
	    $q =~ s/([^$URI::uric])/$URI::Escape::escapes{$1}/go;
	    $$self .= "?$q";
	}
	$$self .= $3;
    }
    $2;
}

# Handle ...?foo=bar&bar=foo type of query
sub query_form {
    my $self = shift;
    my $old = $self->query;
    if (@_) {
        # Try to set query string
        my @query;
        while (my($key,$vals) = splice(@_, 0, 2)) {
            $key = '' unless defined $key;
            $key =~ s/(\W)/$URI::Escape::escapes{$1}/g;
            $vals = [$vals] unless ref $vals;
            for my $val (@$vals) {
                $val = '' unless defined $val;
                $val =~ s/(\W)/$URI::Escape::escapes{$1}/g;
                push(@query, "$key=$val");
            }
        }
        $self->query(join('&', @query));
    }
    return if !defined($old) || !length($old) || !defined(wantarray);
    map { s/\+/ /g; uri_unescape($_) }
         map { /=/ ? split(/=/, $_, 2) : ($_ => '')} split(/&/, $old);
}

# Handle ...?dog+bones type of query
sub query_keywords
{
    my $self = shift;
    my $old = $self->query;
    if (@_) {
        # Try to set query string
        $self->query(join('+', map { my $k = $_;
                                     $k =~ s/(\W)/$URI::Escape::escapes{$1}/g;
                                     $k }
                                     @_));
    }
    return if !defined($old) || !defined(wantarray);
    map { uri_unescape($_) } split(/\+/, $old, -1);
}

1;
