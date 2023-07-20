function[tf,reason]=isDisabledModel(modelH)
    reason=[];
    if isempty(get_param(modelH,'FileName'))&&~strcmpi(get_param(modelH,'IsHarness'),'on')
        tf=true;
        reason='emptyfile';
        return;
    end



    appmgr=slreq.app.MainManager.getInstance;
    allDisabledModels=appmgr.perspectiveManager.getDisabledModelList();
    tf=ismember(modelH,allDisabledModels);
end