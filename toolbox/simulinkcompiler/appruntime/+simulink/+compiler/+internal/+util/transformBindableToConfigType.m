function transformed = transformBindableToConfigType( bindable )




R36
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



% Decoded using De-pcode utility v1.2 from file /tmp/tmpGPrn2k.p.
% Please follow local copyright laws when handling this file.

