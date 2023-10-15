function transformed = transformBindableToConfigType( bindable )

arguments
    bindable( 1, : ){ isCharStringOrEnum }
end

if isa( bindable, 'simulink.compiler.internal.AppConfigType' )
    transformed = bindable;
    return
end

bindable = string( bindable );

supportedBindables =  ...
    simulink.compiler.internal.AppConfigType.names(  );

bitMap = strcmp( bindable, supportedBindables );
index = find( bitMap == 1 );

transformed = [  ];

if index
    transformed = simulink.compiler.internal.AppConfigType.( bindable );
end
end

function isValid = isCharStringOrEnum( toValidate )
isValid = ischar( toValidate ) || isstring( toValidate ) ||  ...
    isa( toValidate, 'simulink.compiler.internal.AppConfigType' );

if ~isValid
    error( message( "simulinkcompiler:genapp:MustBeCharStringOrEnum", toValidate ) );
end
end

