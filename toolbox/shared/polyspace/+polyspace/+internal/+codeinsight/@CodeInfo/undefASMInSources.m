function hasChanged = undefASMInSources( cInfo, sourceFolder )

arguments
    cInfo( 1, 1 )polyspace.internal.codeinsight.CodeInfo
    sourceFolder( 1, 1 )string
end

hasChanged = false;
fInfoList = cInfo.CodeInsightInfo.Functions.toArray;
if isempty( fInfoList )

    return ;
end


fInfoList = fInfoList( [ fInfoList.HasASMBlock ] );
if isempty( fInfoList )

    return ;
end

defRange = [ fInfoList.DefinitionSourceRange ];
startList = [ defRange.Start ];
fileList = [ startList.File ];
filePath = string( { fileList.Path } );
fileToModify = unique( filePath );

for aFilePath = fileToModify
    if aFilePath.startsWith( sourceFolder )
        if cInfo.undefASM( aFilePath )
            hasChanged = true;
        end
    end
end

end


