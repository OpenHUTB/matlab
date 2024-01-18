function wasSaved=saveIfHasChanges(mdl)

    if ischar(mdl)&&exist(mdl,'file')==4&&rmidata.isExternal(mdl)
        wasSaved=saveReqFileIfHasChanges(mdl);
    else
        wasSaved=false;
    end
end


function wasSaved=saveReqFileIfHasChanges(mdl)
    modelH=get_param(mdl,'Handle');
    if slreq.hasChanges(modelH)
        wasSaved=rmidata.promptToSave(modelH);
    else
        wasSaved=false;
    end
end
