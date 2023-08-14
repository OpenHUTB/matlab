


function hasFiles=hasExternalInitFiles

    externalInitFiles={'txInit.m','rxInit.m','runExternalInit.m'};
    hasFiles=false;
    mFiles=dir('*.m');
    if~isempty(mFiles)
        mFilesNames={mFiles.name};
        if all(contains(externalInitFiles,mFilesNames))
            hasFiles=true;
        end
    end
end

