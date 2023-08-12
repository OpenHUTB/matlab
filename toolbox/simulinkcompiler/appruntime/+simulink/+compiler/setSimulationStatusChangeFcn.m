function in = setSimulationStatusChangeFcn( in, callback )





















R36
in( 1, 1 )Simulink.SimulationInput
callback( 1, 1 )function_handle
end 

product = "Simulink_Compiler";
[ status, msg ] = builtin( 'license', 'checkout', product );
if ~status
product = extractBetween( msg, 'Cannot find a license for ', '.' );
if ~isempty( product )
error( message( 'simulinkcompiler:build:LicenseCheckoutError', product{ 1 } ) );
end 
error( msg );
end 

in.RuntimeFcns.SimStatusChangeFcn = callback;

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcbpBYo.p.
% Please follow local copyright laws when handling this file.

