function tf=shouldUpdateFilePaths(mfLinkSet,pathToArtifact,pathToLinksFile)




    if~isempty(fileparts(mfLinkSet.artifactUri))&&isfile(mfLinkSet.artifactUri)

        tf=false;

    elseif~strcmp(mfLinkSet.filepath,pathToLinksFile)


        tf=true;

    else



        if any(pathToArtifact=='.')

            pathToArtifactFolder=fileparts(pathToArtifact);
            if isempty(pathToArtifactFolder)
                tf=false;
            else
                storedPathToArtifactFolder=fileparts(mfLinkSet.artifactUri);
                tf=~strcmp(storedPathToArtifactFolder,pathToArtifactFolder);
            end
        else
            tf=false;
        end
    end
end
