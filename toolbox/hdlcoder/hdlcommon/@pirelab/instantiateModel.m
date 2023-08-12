function hRefComp = instantiateModel( hN, newPir, hInSignals, hOutSignals, instanceName, simMode )





narginchk( 5, 6 );
if nargin < 6
simMode = 'Normal';
end 
hRefComp = hN.addComponent( 'ctx_ref_comp', newPir );
hRefComp.Name = instanceName;
hRefComp.setSimulationMode( simMode );
pirelab.connectComp( hRefComp, hInSignals, hOutSignals );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPXYaO0.p.
% Please follow local copyright laws when handling this file.

