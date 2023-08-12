function dictObj = create( dictFileName )







R36
dictFileName{ validateDictFileName }
end 

dictImpl = sl.interface.dict.api.createInterfaceDictionary( dictFileName );
dictObj = Simulink.interface.dictionary.open( dictImpl.getDictionaryFilePath(  ) );




Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( dictObj.filepath(  ) );
Simulink.SystemArchitecture.internal.DictionaryRegistry.DirtyDD( dictObj.filepath(  ) );


if ~slfeature( 'InterfaceDictionaryPlatforms' )
if ~dictObj.hasPlatformMapping( 'AUTOSARClassic' )

dictObj.addPlatformMapping( 'AUTOSARClassic' );
end 
end 

dictObj.save(  );

end 


function validateDictFileName( dictFileName )
R36
dictFileName{ mustBeTextScalar, mustBeNonzeroLengthText }
end 

if ~endsWith( dictFileName, '.sldd' )
error( message( 'interface_dictionary:api:InvalidDictionaryExtension', dictFileName ) );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpC8StvQ.p.
% Please follow local copyright laws when handling this file.

