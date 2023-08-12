function setModelMappingMSFromCS( modelMapping, cs, csparam, mappingParam )




memSecCategory = get_param( cs, csparam );
if ~isequal( memSecCategory, 'Default' )
msName = memSecCategory;
uuid = modelMapping.DefaultsMapping.getMemorySectionUuidFromName(  ...
msName );
assert( ~isempty( uuid ) )
modelMapping.DefaultsMapping.set( mappingParam, 'MemorySection', uuid );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpm8abIU.p.
% Please follow local copyright laws when handling this file.

