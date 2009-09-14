use Test::More tests => 43;

use XML::Parser::LiteCopy;
use Data::Dumper;

my($s, $c, $e, $a);


#
# start, char, end
#

($s, $c, $e) = (0) x 3;
my $p1 = XML::Parser::LiteCopy->new();
$p1->setHandlers(
    Start => sub { $s++; },
    Char => sub { $c++; },
    End => sub { $e++; },
);
$p1->parse('<foo>Hello World!</foo>');

is($s, 1);
is($c, 1);
is($e, 1);


#
# attributes from start event
#

($s, $c, $e) = (0) x 3;
my %foo;
my $p2 = new XML::Parser::LiteCopy
  Handlers => {
    Start => sub { shift; $s++; %foo = @_[1..$#_] if $_[0] eq 'foo'; },
    Char => sub { $c++; },
    End => sub { $e++; },
  }
;
$p2->parse('<foo id="me" root="0" empty="">Hello <bar>cruel</bar> <foobar/> World!</foo>');
is($s, 3);
is($c, 4);
is($e, 3);
is($foo{id}, 'me');
ok(defined $foo{root});
is($foo{root}, '0');
ok(defined $foo{empty});
is($foo{empty}, '');


#
# PCDATA
#

sub test_chars {
  my @chars;
  my $p = new XML::Parser::LiteCopy
    Handlers => {
      Char => sub { push @chars, $_[1]; },
    }
  ;
  my $in = shift;
  $p->parse($in);
  is(scalar @chars, scalar @_);
  is_deeply(\@chars, \@_);
}


# >>> An important note about entities:
# PCDATA segments will fire Char events as-is.
# CDATA segments will convert &<>" into their entities, leaving everything else as-is.
# this means that the Char events will always have encoded data!

&test_chars('<foo />', ());
&test_chars('<foo></foo>', ());
&test_chars('<foo>hey</foo>', ('hey'));
&test_chars('<foo>hey&lt;</foo>', ('hey&lt;'));
&test_chars('<foo>&amp;hey</foo>', ('&amp;hey'));

&test_chars('<foo><![CDATA[ yo ]]></foo>', (' yo '));


#
# comments
#

sub test_comments {
  my @comments;
  my $p = new XML::Parser::LiteCopy
    Handlers => {
      Comment => sub { push @comments, $_[1]; },
    }
  ;
  my $in = shift;
  $p->parse($in);
  is(scalar @comments, scalar @_);
  is_deeply(\@comments, \@_);
}

# >>> A note about comments:
# An XML comment opens with a "<!--" delimiter and generally closes with the first subsequent
# occurrence of the closing "-->" delimiter. An explicitly stated exception is that a double
# hyphen is not permitted within the body of a comment. This rule ensures that unterminated
# comments are detected if a new comment opening delimiter is encountered. There is an
# additional restriction that comments cannot be terminated with the "--->" sequence, that is,
# that the body of the comment cannot terminate with a hyphen

&test_comments('<foo></foo>', ());
&test_comments('<foo><!--a--></foo>', ('a'));
&test_comments('<foo><!-- b --></foo>', (' b '));
&test_comments('<foo><!-- c-d --></foo>', (' c-d '));
&test_comments('<foo><!-- e- --></foo>', (' e- '));
&test_comments('<foo><!-- - --></foo>', (' - '));
&test_comments('<foo><!--fg--></foo><!--h-->', ('fg','h'));
&test_comments('<foo><!--i-j--></foo>', ('i-j'));


#
# processing instructions (PI)
#

sub test_pi {
  my @instructions;
  my $p = new XML::Parser::LiteCopy
    Handlers => {
      XMLDecl => sub { push @instructions, $_[1]; },
    }
  ;
  my $in = shift;
  $p->parse($in);
  is(scalar @instructions, scalar @_);
  is_deeply(\@instructions, \@_);
}

&test_pi('<foo />', ());
&test_pi('<?name pidata?><foo />', ('name pidata'));
&test_pi('<?xml version="1.0"? encoding="UTF-8"?><foo/>', ('xml version="1.0"? encoding="UTF-8"'));
&test_pi(qq|<bar><?php\nexit;\n?></bar>|, (qq|php\nexit;\n|));
&test_pi('<?yay woo??><foo />', ('yay woo?')); # technically allowed...


#
# error conditions
#

$p2->setHandlers;

# check for junk before
eval { $p2->parse('foo<foo id="me">Hello World!</foo>') };
ok($@ =~ /^junk .+ before/);

# check for junk after
eval { $p2->parse('<foo id="me">Hello World!</foo>bar') };
ok($@ =~ /^junk .+ after/);

# check for non-closed tag
eval { $p2->parse('<foo id="me">Hello World!') };
ok($@ =~ /^not properly closed tag 'foo'/);

# check for non properly closed tag
eval { $p2->parse('<foo id="me">Hello World!<bar></foo></bar>') };
ok($@ =~ /^mismatched tag 'foo'/);

# check for unwanted tag
eval { $p2->parse('<foo id="me">Hello World!</foo><bar></bar>') };
ok($@ =~ /^multiple roots, wrong element 'bar'/);

# check for string without elements
eval { $p2->parse('  ') };
ok($@ =~ /^no element found/);

