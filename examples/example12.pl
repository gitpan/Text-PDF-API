use Text::PDF::API::JPEG;
use Text::PDF::API::GIF;
use Text::PDF::API::PPM;
use Text::PDF::API::BMP;
use Text::PDF::API;

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);

        $pdf->newpage();
	($key,$w,$h)=$pdf->rawImage('my-sample-imagei1',Text::PDF::API::JPEG::readJPEG("$0.jpg"));
	$pdf->placeImage($key,0,0,$w,$h);
        $pdf->endpage();

        $pdf->newpage();
	($key,$w,$h)=$pdf->rawImage('my-sample-imagei2',Text::PDF::API::GIF::readGIF("$0.gif"));
	$pdf->placeImage($key,0,0,$w,$h);
        $pdf->endpage();
        
        $pdf->newpage();
	($key,$w,$h)=$pdf->rawImage('my-sample-imagei3',Text::PDF::API::PPM::readPPM("$0.ppm"));
	$pdf->placeImage($key,0,0,$w,$h);
        $pdf->endpage();
        
        $pdf->newpage();
	($key,$w,$h)=$pdf->rawImage('my-sample-imagei4',Text::PDF::API::BMP::readBMP("$0.bmp"));
	$pdf->placeImage($key,0,0,$w,$h);
        $pdf->endpage();
        
        $pdf->newpage();
	($key,$w,$h)=$pdf->newImage("$0.gif");
	$pdf->placeImage($key,0,0,$w,$h);
        $pdf->endpage();
        
	$pdf->saveas("$0.pdf");
        $pdf->end;



__END__


