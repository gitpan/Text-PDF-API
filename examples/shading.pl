#!/usr/bin/perl

        use Text::PDF::API;
        use Text::PDF::Utils;
        $pdf=Text::PDF::API->new('pagesize'=>'a4','compression'=>0);
        $pdf->newpage();
	$fn='Helvetica-Bold';
        $pdf->newFontCore($fn);
        $pdf->useFont($fn,20);
       	$pdf->showTextXY(72,72,'this is the shading test');

#### HOWTO CREATE A REUSABLE SHADING 

        $key='OURxSHADINGxISxGOOD';

        $xo=PDFDict();
        $xo->{'ShadingType'}=PDFNum(2);
        $xo->{'ColorSpace'}=PDFName('DeviceRGB');
        $xo->{'Extend'}=PDFArray(PDFBool('true'),PDFBool('true'));
        $xo->{'Coords'}=PDFArray(PDFNum(0),PDFNum(0.5),PDFNum(1),PDFNum(0));
        $xo->{'Function'}=PDFDict();
	$xo->{'Function'}->{'FunctionType'}=PDFNum(2);
	$xo->{'Function'}->{'Domain'}=PDFArray(PDFNum(0),PDFNum(1));
	$xo->{'Function'}->{'C0'}=PDFArray(PDFNum(1),PDFNum(1),PDFNum(0));
	$xo->{'Function'}->{'C1'}=PDFArray(PDFNum(1),PDFNum(0),PDFNum(1));
	$xo->{'Function'}->{'N'}=PDFNum(1.2);
	$shade0=$pdf->shadeAdd($xo,$key); 
	$pdf->setColorStroke(0);
	$pdf->moveTo(100,100);
	$pdf->rectXY(100,100,500,500);
	## $pdf->stroke();
	$pdf->clipPath();
	$pdf->endPath();
	$pdf->shadePath($shade0,100,100,500,500); 
        $pdf->endpage();

        $pdf->saveas("$0.pdf");
        $pdf->end;

__END__
151 0 obj
<< 
        /ShadingType 2 
        /ColorSpace /DeviceRGB 
        /Coords [ 0 0 1 0 ] 
        /Extend [ true true ] 
        /Function <<
                /FunctionType 2
                /Domain [ 0 1 ]
                /C0 [ 1 0 0 ]
                /C1 [ 1 1 1 ]
                /N 1
        >> 
>> 
endobj
152 0 obj
<< 
        /ShadingType 2 
        /ColorSpace /DeviceRGB 
        /Coords [ 1 0 0 0 ] 
        /Extend [ true true ] 
        /Function <<
                /FunctionType 2
                /Domain [ 0 1 ] 
                /C0 [ 1 0 0 ] 
                /C1 [ 1 1 1 ] 
                /N 1 
        >> 
>> 
endobj
158 0 obj
<< 
        /ShadingType 2 
        /ColorSpace 
        /DeviceRGB 
        /Coords [ 0 0 1 1 ] 
        /Extend [ true true ] 
        /Function << 
                /FunctionType 2 
                /Domain [ 0 1 ] 
                /C0 [ 1 0 0 ] 
                /C1 [ 1 1 1 ] 
                /N 1 
        >> 
>> 
endobj

