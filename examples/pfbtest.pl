$fs=(-s $ARGV[0]);
open(INF,$ARGV[0]);
$/="\cM";
do {
$line=<INF>;
chomp($line);
} until ($line EQ "currentfile eexec" || eof(INF));

$acsi=tell(INF);
print "Ascii portion= $acsi \n";

binmode(INF);
do {
read INF,$line,64;
} until ($line=~/00000000/ || eof(INF));

$enc=tell(INF)-128;
seek INF,$enc,0;
$/="00000000\cM";

$line=<INF>;

$enc=tell(INF)-65;

print "Encrypted portion= ".($enc-$acsi)." \n";

print "trailer portion= ".($fs-$enc)." \n";

close(INF);


__END__