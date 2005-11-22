package MIME::Lite::TT::HTML::Japanese;
use strict;

use MIME::Lite;
use Template;
use Jcode;
use DateTime::Format::Mail;
use Carp;

our $VERSION = '0.02';

=head1 NAME

MIME::Lite::TT::HTML::Japanese - Create html mail with MIME::Lite and TT

=head1 SYNOPSIS

    use MIME::Lite::TT::HTML::Japanese;
    
    my $msg = MIME::Lite::HTML::Japanese->new(
        From        => 'from@example.com',
        To          => 'to@example.com',
        Subject     => 'Subject',
        Template    => {
            html => 'mail.html',
            text => 'mail.txt',
        },
        Icode       => 'euc', # input code (Jcode Format)
        TmplIcode   => 'jis', # Template input code (Optional)
        TmplOptions => \%options,
        TmplParams  => \%params,
    );
    
    $msg->send;

=head1 DESCRIPTION

This module provide easy interface to make MIME::Lite object with html formatted mail.

=head1 METHODS

=over 4

=item new

return MIME::Lite object with Japanese html mail format.

=cut

sub new {
    my $class = shift;
    my $options = @_ > 1 ? {@_} : $_[0];

    my $template = delete $options->{ Template };
    return croak "html template not defined" unless $template->{html};

    $template->{text} = generate_text( $template->{html} ) unless $template->{text};

    my $icode        = delete $options->{ Icode };
    my $tmpl_icode   = delete $options->{ TmplIcode   };
    my $tmpl_params  = delete $options->{ TmplParams  };

    my $tt = Template->new( delete $options->{ TmplOptions } );

    my $msg = MIME::Lite->new(
        %$options,
        Subject => encode_subject( delete $options->{ Subject }, $icode ),
        Type    => 'multipart/alternative',
        Date    => DateTime::Format::Mail->format_datetime( DateTime->now->set_time_zone('Asia/Tokyo') ),
    );

    my ( $text, $html );
    $tt->process( $template->{text}, $tmpl_params, \$text ) or croak $tt->error;
    $tt->process( $template->{html}, $tmpl_params, \$html ) or croak $tt->error;

    $msg->attach(
        Type => 'text/plain; charset=iso-2022-jp',
        Data => encode_body( $text, $tmpl_icode || $icode ),
    );

    $msg->attach(
        Type => 'text/html; charset=iso-2022-jp',
        Data => encode_body( $html, $tmpl_icode || $icode ),
    );

    $msg;
}

sub encode_subject {
    my ( $subject, $icode ) = @_;
    my $str = remove_utf8_flag( $subject );
    Jcode->new( $str, $icode )->mime_encode;
}

sub encode_body {
    my ( $body, $icode ) = @_;
    my $str = remove_utf8_flag( $body );
    Jcode->new( $str, $icode )->jis;
}

sub generate_text {
    my $str = shift;
    $str =~ s/<.*?>//gs;
    $str;
}

sub remove_utf8_flag {
    pack 'C0A*', shift;
}

=back

=head1 AUTHOR

Daisuke Murase E<lt>typester@cpan.orgE<gt>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
