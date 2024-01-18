function yesno=bdHasExternalData(slModelHandle,orIsPackaged)

    if nargin<2
        orIsPackaged=true;
    end

    if slreq.data.ReqData.exists()&&slreq.hasLinks(slModelHandle)

        if orIsPackaged
            yesno=true;
        else
            artifact=get_param(slModelHandle,'FileName');
            linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifact);
            [~,fname]=fileparts(linkSet.filepath);
            yesno=~strcmp(fname,slreq.utils.getEmbeddedLinksetName());
        end
    else
        yesno=false;
    end
end
