function [ archiveFile, filesNotArchived ] = createProjectArchiveFromFiles( project, files, archiveName )

arguments
    project( 1, 1 )matlab.project.Project
    files string
    archiveName( 1, 1 )string = "archive.zip"
end

tempFolder = tempname;
mkdir( tempFolder );
archiveFile = fullfile( tempFolder, archiveName );

isFileInProject = arrayfun( @( fileName )isFileFoundInProject( project, fileName ), files );
refProjects = project.listAllProjectReferences(  );
isFileInProjectRefs = arrayfun( @( fileName )isFileFoundInReferenceProject( refProjects, fileName ), files );
projectHasReferences = ~isempty( refProjects );


filesToArchive = [ {  }, convertStringsToChars( files( isFileInProject ) ) ];
project.export( archiveFile, "specifiedFilesOnly", filesToArchive,  ...
    "archiveReferences", projectHasReferences );
filesNotArchived = files( ~( isFileInProject | isFileInProjectRefs ) );
end

function fileIsInProject = isFileFoundInProject( project, fileName )
fileIsInProject = ~isempty( project.findFile( fileName ) );
end

function fileWasFound = isFileFoundInReferenceProject( referenceProjects, fileName )
arguments
    referenceProjects
    fileName( 1, 1 )string
end

fileWasFound = false;
for refProject = referenceProjects
    project = refProject.Project;
    if ~isempty( project.findFile( fileName ) )
        fileWasFound = true;
        return ;
    end
end
end

