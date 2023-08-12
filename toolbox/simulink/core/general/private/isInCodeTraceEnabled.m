function flag = isInCodeTraceEnabled( modelName )




obfuscateLevel = get_param( modelName, 'ObfuscateCode' );
ObfuscatorOn = strcmp( get_param( 0, 'AcceleratorUseTrueIdentifier' ), 'off' ) &&  ...
obfuscateLevel ~= 0;

targetType = get_param( modelName, 'ModelReferenceTargetType' );
flag = ~slprivate( 'isSimulationBuild', modelName, targetType ) &&  ...
strcmp( get_param( modelName, 'InCodeTrace' ), 'on' ) &&  ...
strcmp( get_param( modelName, 'IsERTTarget' ), 'on' ) &&  ...
~ObfuscatorOn;



% Decoded using De-pcode utility v1.2 from file /tmp/tmpN0im5i.p.
% Please follow local copyright laws when handling this file.

