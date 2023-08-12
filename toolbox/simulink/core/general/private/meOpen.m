








function meOpen(  )
filterList = [ 
{ '*.mdl;*.slx;*.sldd', DAStudio.message( 'Simulink:utility:SimulinkFiles' ) }; ...
{ '*.*', DAStudio.message( 'MATLAB:uistring:uiopen:AllFiles' ) }
 ];
[ fn, pn ] = uigetfile( filterList, getString( message( 'MATLAB:uistring:uiopen:DialogOpen' ) ) );
if ~isequal( fn, 0 )
filepath = fullfile( pn, fn );
uiopen( filepath, 1 );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpclP53B.p.
% Please follow local copyright laws when handling this file.

