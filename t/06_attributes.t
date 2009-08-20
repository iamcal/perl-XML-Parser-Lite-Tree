use Test::More tests => 9;

#
# this tests a bug present in 0.10 on perl 5.8.9 only which
# caused attributes to be copied from one node into the next
#

use XML::Parser::Lite::Tree;
my $x = XML::Parser::Lite::Tree->instance();

my $tree = $x->parse('<foo><bar id="a" /><bar a="1" b="2" /></foo>');

# has a root element called 'foo' with 2 children
is($tree->{children}->[0]->{name}, "foo");
is(scalar @{$tree->{children}->[0]->{children}}, 2);

# children are both called bar
is($tree->{children}->[0]->{children}->[0]->{name}, "bar");
is($tree->{children}->[0]->{children}->[1]->{name}, "bar");

# first child has a single attribute (id="a")
is(scalar keys %{$tree->{children}->[0]->{children}->[0]->{attributes}}, 1);
is($tree->{children}->[0]->{children}->[0]->{attributes}->{id}, "a");

# second child has 2 attributes (a=1, b=2)
is(scalar keys %{$tree->{children}->[0]->{children}->[1]->{attributes}}, 2);
is($tree->{children}->[0]->{children}->[1]->{attributes}->{a}, "1");
is($tree->{children}->[0]->{children}->[1]->{attributes}->{b}, "2");
