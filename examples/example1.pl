#
# An example program which creates graph paper. Very simple, but shows the basics
# page creation, etc.


use Text::PDF::API;
use Text::PDF::Utils;

$pdf=Text::PDF::API->new('pagesize' => 'a4','compression'=>0);
$pdf->newpage();
$pdf->newFont("Arial,Reh","mystic-etchings-normal.ttf",'MicrosoftAnsi');
$pdf->setColorStroke(1,0,0);
$pdf->circleXYR(200,200,200);
$pdf->stroke;
$pdf->lineXY(0,0,500,800);
$pdf->stroke;
$pdf->useFont("Arial,Reh",20,'latin1');
$pdf->showTextXY_C(20,20,'asdfQWERT');
$pdf->endpage();

$pdf->saveas("pdf.api.pdf");
$pdf->end();
#	

__END__



