function in = setPostStepFcn( in, callback, options )

arguments
    in( 1, 1 )Simulink.SimulationInput
    callback( 1, 1 )function_handle
    options.Decimation( 1, 1 )double{ mustBePositive, mustBeInteger } = 1
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

in.RuntimeFcns.PostStepFcn = callback;
in.RuntimeFcns.PostStepFcnDecimation = options.Decimation;

end

