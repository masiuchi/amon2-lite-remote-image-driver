use Amon2::Lite;

use File::Basename;
use File::Copy;
use File::Spec;
use File::Temp qw/ tempdir /;
use Imager;

use lib File::Spec->catdir( dirname(__FILE__), 'lib' );
use RemoteImageDriver::Imager;

__PACKAGE__->load_plugins('Web::Raw');

my $temp_dir = tempdir();

sub upload_file {
    my $c = shift;

    my $file = $c->req->uploads->{file};
    my $filename = File::Spec->catfile( $temp_dir, $file->{filename} );
    move( $file->{tempname}, $filename );

    my ($suffix) = $file->filename =~ /\.([^\.]+)$/;
    $suffix = lc $suffix;
    $suffix = 'jpeg' if $suffix eq 'jpg';

    ( $filename, $suffix );
}

get '/' => sub {
    my ($c) = @_;
    return $c->render('index.tt');
};

post 'scale' => sub {
    my $c = shift;
    my ( $filename, $suffix ) = upload_file($c);

    my $width  = $c->req->param('width');
    my $height = $c->req->param('height');

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->scale( width => $width, height => $height );

    $c->render_raw( $suffix => $blob );
};

post 'crop_rectangle' => sub {
    my $c = shift;
    my ( $filename, $suffix ) = upload_file($c);

    my $left = $c->req->param('left') || 0;
    my $top  = $c->req->param('top')  || 0;
    my $width  = $c->req->param('width');
    my $height = $c->req->param('height');

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->crop_rectangle(
        left   => $left,
        top    => $top,
        width  => $width,
        height => $height,
    );

    $c->render_raw( $suffix => $blob );
};

post 'flip_horizontal' => sub {
    my $c = shift;
    my ( $filename, $suffix ) = upload_file($c);

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->flip_hozontal;

    $c->render_raw( $suffix => $blob );
};

post 'flip_vertical' => sub {
    my $c = shift;
    my ( $filename, $suffix ) = upload_file($c);

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->flip_vertical;

    $c->render_raw( $suffix => $blob );
};

post '/rotate' => sub {
    my $c = shift;
    my ( $filename, $suffix ) = upload_file($c);

    my $degrees = $c->req->param('degrees');
    $degrees %= 360;

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->rotate( degrees => $degrees );

    $c->render_raw( $suffix => $blob );
};

post 'convert' => sub {
    my $c = shift;
    my ( $filename, $suffix ) = upload_file($c);

    my $type = $c->req->param('type');

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->convert( type => $type );

    $c->render_raw( $type => $blob );
};

__PACKAGE__->to_app();

__DATA__

@@ index.tt
<!doctype html>
<html>
    <body>Hello</body>
</html>

