use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME'		=> 'XML::Parser::Lite::Tree',
	'VERSION_FROM'	=> 'lib/XML/Parser/Lite/Tree.pm',
    'LICENSE'           => 'perl',
    'META_MERGE'        => {
        resources => {
            repository  =>  'https://github.com/iamcal/perl-XML-Parser-Lite-Tree',
        },
    },
	'PREREQ_PM'	=> {
		'Test::More'		=> 0,
	},
);
