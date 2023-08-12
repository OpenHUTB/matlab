function mode = rtwenvironmentmode( mdl )








if ( ~strcmpi( get_param( mdl, 'RapidAcceleratorSimStatus' ), 'inactive' ) )
mode = true;
else 
switch get_param( mdl, 'TargetStyle' )
case 'StandAloneTarget'
mode = false;
otherwise 

if strcmp( get_param( mdl, 'SimulationMode' ), 'external' )
mode = false;
else 
mode = true;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_xhsr9.p.
% Please follow local copyright laws when handling this file.

