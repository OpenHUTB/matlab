function isValid = createCodeGenBtn_isValid( hProxy )




isValid = isMappingSupported( hProxy ) && hasLicense;
end 

function validMapping = isMappingSupported( hProxy )
slidObj = hProxy.getObject(  );
modelRootObj = get_param( slidObj.System.Handle, 'Object' );
[ ~, mappingType ] = Simulink.CodeMapping.getCurrentMapping( modelRootObj.getPropValue( 'Name' ) );

validMapping = strcmp( mappingType, 'CoderDictionary' ) ||  ...
strcmp( mappingType, 'SimulinkCoderCTarget' ) ||  ...
strcmp( mappingType, 'AutosarTarget' );
end 

function hasLicense = hasLicense(  )
hasLicense = dig.isProductInstalled( 'MATLAB Coder' ) &&  ...
dig.isProductInstalled( 'Simulink Coder' ) &&  ...
dig.isProductInstalled( 'Embedded Coder' );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpbihtiA.p.
% Please follow local copyright laws when handling this file.

