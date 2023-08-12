function callback = getExternalOutputsFcn( in )











R36
in( 1, 1 )Simulink.SimulationInput
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

callback = in.ExperimentalProperties.RapidAccelExternalOutputsFcn;

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpnksBW5.p.
% Please follow local copyright laws when handling this file.

