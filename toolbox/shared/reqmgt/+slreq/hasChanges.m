





function yesno=hasChanges(artifact)

    if~slreq.data.ReqData.exists()
        yesno=false;
        return;
    end

    if ischar(artifact)&&any(artifact=='.')
        artifactPath=artifact;
    else

        if ischar(artifact)
            artifact=strtok(artifact,':');
        end
        artifactPath=get_param(artifact,'FileName');
    end

    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactPath);

    if isempty(linkSet)

        yesno=false;

    elseif linkSet.dirty

        yesno=true;

    elseif exist(linkSet.filepath,'file')==0





        [isInstalled,isLicensed]=rmi.isInstalled();
        if~isInstalled||~isLicensed
            yesno=false;
        else



            if contains(linkSet.filepath,matlabroot)
                yesno=false;
            else



                if strcmp(linkSet.domain,'linktype_rmi_simulink')
                    [~,mdlName]=fileparts(artifactPath);
                    yesno=strcmp(get_param(mdlName,'Shown'),'on');
                else
                    yesno=true;
                end
            end
        end
    else

        yesno=false;
    end

end
