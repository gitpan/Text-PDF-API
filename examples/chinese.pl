#!/usr/bin/perl 

$ff3='/share/_fonts_/cjk.dir/mshei_regular.ttf'; 
$e='ucs2';
use Text::PDF::API;
$pdf=Text::PDF::API->new('pagesize'=>'a4','compression'=>0);
$pdf->newFontCore('Helvetica-Bold');
$pdf->newFontTTF('someCJK',$ff3);
$pdf->newpage();
$pdf->useFont('Helvetica-Bold',20,'latin1');
$pdf->showTextXY(60,780,"Now supports Chinese characters...");
$pdf->useFont('someCJK',20,$e);
$pdf->showTextXY(30+(30*1),800-(40*1),"\x73\xB0\x57\x28\x65\x2F\x63\x01\x6C\x49\x5B\x57");
$pdf->useFont('Helvetica-Bold',20,'latin1');
$pdf->showTextXY(60,740,"Also able to use with Chinese characters...");
$pdf->useFont('someCJK',20,$e);
$pdf->showTextXY(30+(30*1),800-(80*1),"\x4E\x5F\x80\xFD\x75\x28\x6C\x49\x5B\x57");
$pdf->endpage();
$pdf->saveas("$0.pdf");
$pdf->end;
__END__
