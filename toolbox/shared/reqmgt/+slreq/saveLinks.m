










function filePath=saveLinks(artifact,varargin)

    filePath='';

    linkSet=slreq.utils.findLinkSet(artifact);

    if isempty(linkSet)

        return;

    else

        if~isempty(varargin)&&ischar(varargin{1})

            newFilePath=varargin{1};
            if~contains(newFilePath,'.slmx')
                newFilePath=[newFilePath,'.slmx'];
            end
            if isempty(fileparts(newFilePath))
                newFilePath=fullfile(pwd,newFilePath);
            end
            if~strcmp(linkSet.filepath,newFilePath)
                linkSet.updateLinksFileLocation(newFilePath);



                if~slreq.utils.isEmbeddedLinkSet(newFilePath)
                    [artifactLocation,artifactName]=fileparts(linkSet.artifact);
                    [linkFileLocation,linkFileName]=fileparts(newFilePath);
                    if~strcmp(artifactName,linkFileName)||...
                        (~isempty(artifactLocation)&&~strcmp(artifactLocation,linkFileLocation))
                        rmimap.StorageMapper.getInstance.set(linkSet.artifact,newFilePath);
                    end
                end
            end
        end


        if exist(linkSet.filepath,'file')~=2

            slreq.data.ReqData.getInstance.forceDirtyFlag(linkSet,true);
        end

        unsavedReqSets=linkSet.getUnsavedDependeeReqSets();

        if isempty(unsavedReqSets)
            success=linkSet.save();
        elseif slreq.utils.saveWithPrompt(unsavedReqSets,linkSet.artifact)
            success=linkSet.save();
        else
            success=false;
        end

        if success
            filePath=linkSet.filepath;
            if slreq.utils.isEmbeddedLinkSet(filePath)

                [~,mdlName]=fileparts(linkSet.artifact);
                if isModelFileWriteable(mdlName)
                    save_system(mdlName);
                else


                end
            end
        end
    end
end

function tf=isModelFileWriteable(mdlName)
    mdlFile=get_param(mdlName,'FileName');
    if exist(mdlFile,'file')==4
        [~,fattr]=fileattrib(mdlFile);
        tf=fattr.UserWrite;
    else
        tf=true;
    end
end

