#
# An example program which creates graph paper. Very simple, but shows the basics
# page creation, etc.


use Text::PDF::API;
$pdf=Text::PDF::API->new('pagesize' => 'a4','compression'=>0);
$pdf->addCoreFonts();
$pdf->newTTFont('Wingdings,Normal','space.ttf');
$pdf->newTTFont('arschloch,irgendwas','WarningLH-Pi-Regular.ttf');
foreach (0..4) {
	$pdf->newpage();
#	$font=	$pdf->newfont("<path/to/fontfile>");
#		$pdf->usefont($font,$pts);

    $pdf->_addtopage("1 w 58 58 m 595 842 l S\n");
	$font=$pdf->_getFontpdfname("Wingdings,Normal");
	$font2=$pdf->_getFontpdfname("arschloch,irgendwas");
    $pdf->_addtopage("BT /$font 20 Tf 1 0 0 1 20 20 Tm (hAsTeMaLfEuEr) Tj ET\n");
    $pdf->_addtopage("BT /$font2 20 Tf 1 0 0 1 50 50 Tm (hAsTeMaLfEuEr) Tj ET\n");
  #  $pdf->_addtopage("BT /$font 20 Tf 1 0 0 1 20 20 Tm <0002000300040005> Tj ET\n");

#	
	$pdf->endpage();
}
foreach $x (0..4) {
	$pdf->{'PAGE'}=$pdf->{'PAGES'}->[$x];
	$pdf->_setcurrent('PageContext',$x);
	$pdf->_addtopage("1 w 58 842 m 595 58 l S\n");
}
$pdf->saveas("pdf.api.test.pdf");
$pdf->end();
#	

__END__



