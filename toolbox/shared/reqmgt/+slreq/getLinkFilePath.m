










function[linkFilePath,usingDefault]=getLinkFilePath(artifactPath)
    [~,fname,ext]=fileparts(artifactPath);


    if strcmp(ext,'.slx')

        try
            tempLocation=get_param(fname,'UnpackedLocationNoCreate');
            if~isempty(tempLocation)
                [~,slxPartName]=slreq.utils.getEmbeddedLinksetName();
                possibleLinksetFile=fullfile(tempLocation,slxPartName);
                if exist(possibleLinksetFile,'file')==2
                    linkFilePath=possibleLinksetFile;
                    usingDefault=true;
                    return;
                end
            end
        catch ex %#ok<NASGU>
        end
    end

    [linkFilePath,usingDefault]=rmimap.StorageMapper.getInstance.getStorageFor(artifactPath);
end