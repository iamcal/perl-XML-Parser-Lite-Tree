use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME'		=> 'XML::Parser::Lite::Tree',
	'VERSION_FROM'	=> 'Tree.pm',
	'PREREQ_PM'	=> {
				'XML::Parser::Lite'	=> 0,
				'Test::Simple'		=> 0,
			},
);
