function [ a0, an ] = simrfV2sqWaveCoeff( block, NumCoef, Bias, DutyCyc, action )








top_sys = bdroot( block );
if strcmpi( get_param( top_sys, 'BlockDiagramType' ), 'library' ) &&  ...
strcmpi( top_sys, 'simrfV2private' )
a0 = 0;
an = 1;
return 
end 




switch ( action )
case 'simrfInit'

if any( strcmpi( get_param( top_sys, 'SimulationStatus' ),  ...
{ 'running', 'paused' } ) )
return 
end 


A = 1;
n = 1:( NumCoef - 1 );


a0 = A * DutyCyc / 100 + Bias;
an = ( ( 2 * A ./ ( n * pi ) ) .* sin( n * pi * DutyCyc / 100 ) ) / sqrt( 2 );


i_need = mod( n * pi * DutyCyc / 100, pi ) ~= 0;
an = an( i_need );

case 'simrfDelete'

case 'simrfCopy'

case 'simrfDefault'

end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQfzazK.p.
% Please follow local copyright laws when handling this file.

