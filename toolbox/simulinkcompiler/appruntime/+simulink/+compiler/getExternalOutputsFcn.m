function callback = getExternalOutputsFcn( in )

arguments
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

