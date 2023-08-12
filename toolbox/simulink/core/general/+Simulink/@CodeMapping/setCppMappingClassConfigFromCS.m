function setCppMappingClassConfigFromCS( modelMapping, cs, csparam )




csparamValue = get_param( cs, csparam );
modelMapping.DefaultsMapping.setMappingByConfigsetKVP( csparam, csparamValue );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3ELOPj.p.
% Please follow local copyright laws when handling this file.

