function files = findAllFiles( filesAndFolder )

arguments
    filesAndFolder( 1, : )string;
end

foldersIdx = isfolder( filesAndFolder );
files = filesAndFolder( ~foldersIdx );

if any( foldersIdx )
    otherFiles = dir( '' );
    for folder = filesAndFolder( foldersIdx )
        allSubDir = dir( fullfile( folder, "**" ) );
        otherFiles = [ otherFiles;allSubDir( ~[ allSubDir.isdir ] ) ];%#ok<AGROW>
    end
    files = [ files, string( fullfile( { otherFiles.folder }, { otherFiles.name } ) ) ];
end

files = unique( files );

end

