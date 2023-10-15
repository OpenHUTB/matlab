function [ backupModelName ] = getBackupModelName( namePrefix, modelName, maxCharactersInName )

arguments
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

