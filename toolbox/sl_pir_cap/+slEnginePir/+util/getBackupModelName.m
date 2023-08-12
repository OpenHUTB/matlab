function [ backupModelName ] = getBackupModelName( namePrefix, modelName, maxCharactersInName )





R36
namePrefix
modelName
maxCharactersInName uint32 = 59
end 

namePrefixLength = length( namePrefix );
availableCharLength = maxCharactersInName - namePrefixLength;

if iscell( modelName )
backupModelName = cell( length( modelName ), 1 );
for modelIndex = 1:length( modelName )
modelNameUsableLength = min( availableCharLength, length( modelName{ modelIndex } ) );
backupModelName{ modelIndex } = [ namePrefix, modelName{ modelIndex }( 1:modelNameUsableLength ) ];
end 
else 
modelNameUsableLength = min( availableCharLength, length( modelName ) );
backupModelName = [ namePrefix, modelName( 1:modelNameUsableLength ) ];
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp1L4j0n.p.
% Please follow local copyright laws when handling this file.

