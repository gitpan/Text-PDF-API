#!/usr/bin/perl

        use Text::PDF::API;
        use Text::PDF::Utils;
        $pdf=Text::PDF::API->new('pagesize'=>'a4','compression'=>0);
        $pdf->newpage();
	$fn='Helvetica-Bold';
        $fk=$pdf->newFont($fn,'latin1');
        $pdf->useFont($fn,20);
       	$pdf->showTextXY(72,72,'this is NOT the xo');

#### HOWTO CREATE A REUSABLE PDF-COMMAND-STREAM :) VIA THE FORM XOBJECT

        $key='XFxTBx'.sprintf('%08X',time());

        $xo=PDFDict();
        $pdf->{'PDF'}->new_obj($xo);
        $xo->{'Type'}=PDFName('XObject');
        $xo->{'Subtype'}=PDFName('Form');
        $xo->{'Name'}=PDFName($key);
        $xo->{'Formtype'}=PDFNum(1);
        $xo->{'BBox'}=PDFArray(PDFNum(0),PDFNum(0),PDFNum(250),PDFNum(250));
        ## $xo->{'Filter'}=PDFArray(PDFName('FlateDecode'));
        $xo->{' stream'}=qq|BT /$fk 20 Tf (this is the xo) Tj (so anders!!) Tj ET\n|;
        $pdf->{'ROOT'}->{'Resources'}->{'XObject'}=PDFDict() unless $pdf->{'ROOT'}->{'Resources'}->{'XObject'};
        $pdf->{'ROOT'}->{'Resources'}->{'XObject'}->{$key}=$xo;
	$pdf->saveState; 
	$pdf->clearGfxMatrix;
	$pdf->setGfxScale(0.5,2);
	$pdf->calcGfxMatrix;
	$pdf->useGfxState;
	$pdf->_addtopage("/$key Do\n");
	$pdf->restoreState; 
        $pdf->endpage();

#### HOWTO WRITE THE INFO DICTIONARY !!!!!

        $pdf->{'PDF'}->{'Info'}=PDFDict();
	$pdf->{'PDF'}->new_obj($pdf->{'PDF'}->{'Info'});
	$pdf->{'PDF'}->{'Info'}->{'Producer'}=PDFStr('Text::PDF::API on '.localtime());
	$pdf->{'PDF'}->{'Info'}->{'Author'}  =PDFStr('me, myself and I');
	$pdf->{'PDF'}->{'Info'}->{'Creator'} =PDFStr('me, myself and I');
	$pdf->{'PDF'}->{'Info'}->{'Title'}   =PDFStr('me, myself and I');
	$pdf->{'PDF'}->{'Info'}->{'Subject'} =PDFStr('me, myself and I');
	$pdf->{'PDF'}->{'Info'}->{'Keywords'}=PDFStr('me, myself and I');

#---> already implemented in 0.6 $pdf->info()

        $pdf->saveas("$0.pdf");
        $pdf->end;

__END__
