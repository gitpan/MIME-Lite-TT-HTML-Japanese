use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'MIME::Lite::TT::HTML::Japanese',
      license         => 'perl',
      requires        => {
          Template     => 0,
          'MIME::Lite' => 0,
          Jcode        => 0,
          Carp         => 0,
          perl         => '5.6.0',
      },
    )->create_build_script;
