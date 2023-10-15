function fullFilePathList = searchFilesInDir( dirPath, searchStr )

arguments
    dirPath( 1, 1 )string
    searchStr( 1, 1 )string
end
fileList = dir( fullfile( dirPath, searchStr ) );

isDir = [ fileList.isdir ];
fileList = fileList( ~isDir );
fileNameCellList = { fileList.name };
fileFolderPathCellList = { fileList.folder };

pathFunction = @( folderPath, fileName )fullfile( folderPath, fileName );
fullFilePathList = cellfun( pathFunction, fileFolderPathCellList,  ...
    fileNameCellList, 'UniformOutput', false );
fullFilePathList = sort( fullFilePathList );
end
