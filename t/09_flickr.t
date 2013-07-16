use strict;
use warnings;

use Test::More tests => 5;
use Test::Deep;
use XML::Parser::Lite::Tree;
 
# response XML received by Flickr::API
# parsing without options (as it is used in the Flickr::API
# and parsing with skip_white => 1
my $str = 
q{<?xml version="1.0" encoding="utf-8" ?>
<rsp stat="ok">
<method>flickr.test.echo</method>
<api_key>1234</api_key>
</rsp>};

my $p = XML::Parser::Lite::Tree->new(skip_white => 1);
my $skip_tree = $p->parse($str);
is_deeply $skip_tree, {
  'children' => [
    {
      'content' => 'version="1.0" encoding="utf-8" ',
      'target' => 'xml',
      'type' => 'pi'
    },
    {
      'attributes' => {
        'stat' => 'ok'
      },
      'children' => [
        {
          'attributes' => {},
          'children' => [
            {
              'content' => 'flickr.test.echo',
              'type' => 'text'
            }
          ],
          'name' => 'method',
          'type' => 'element'
        },
        {
          'attributes' => {},
          'children' => [
            {
              'content' => '1234',
              'type' => 'text'
            }
          ],
          'name' => 'api_key',
          'type' => 'element'
        }
      ],
      'name' => 'rsp',
      'type' => 'element'
    }
  ],
  'type' => 'root'
}, "skip_tree";

my $xplt = XML::Parser::Lite::Tree->instance();
my $tree = $xplt->parse($str);

# remove and test empty nodes
my @nodes;
push @nodes, splice @{ $tree->{children}[1]{children} }, 0, 1;
push @nodes, splice @{ $tree->{children}[1]{children} }, 1, 1;
push @nodes, splice @{ $tree->{children}[1]{children} }, 2, 1;
foreach my $i (@nodes) {
	is_deeply $i, {
	  'content' => "\n",
	  'type' => 'text'
	};
}

is_deeply $tree, $skip_tree;



