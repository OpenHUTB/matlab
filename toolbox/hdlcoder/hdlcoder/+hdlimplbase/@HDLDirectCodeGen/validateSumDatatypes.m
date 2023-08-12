function v = validateSumDatatypes( this, hC )




















ports = [  ];


for ii = 1:length( hC.SLInputPorts )
ports = [ ports, hC.SLInputPorts( ii ) ];%#ok<AGROW>
end 

for ii = 1:length( hC.SLOutputPorts )
ports = [ ports, hC.SLOutputPorts( ii ) ];%#ok<AGROW>
end 

v = hdlvalidatestruct;

[ noports, any_double, all_double ] = this.checkForDoublePorts( ports );

if ~noports


out = hC.SLOutputPorts( 1 ).Signal;
opsizes = hdlsignalsizes( out );
bfp = hC.SimulinkHandle;




got_accum_type = true;
try 
tmpdt = getaccumforsum( bfp, opsizes( 1 ), opsizes( 2 ), opsizes( 3 ) );
catch me
v = [ v ...
, hdlvalidatestruct( 1, message( 'hdlcoder:validate:unsupportedaccumtype', me.message ) ) ];
got_accum_type = false;
end 

if got_accum_type
if ( tmpdt.size == 0 )
accum_double = true;
else 
accum_double = false;
end 


any_double = any_double || accum_double;
all_double = all_double && accum_double;
end 

if ( any_double && ~all_double )
v = [ v ...
, hdlvalidatestruct( 1, message( 'hdlcoder:validate:mixeddoublesum' ) ) ];
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmp04jiQh.p.
% Please follow local copyright laws when handling this file.

