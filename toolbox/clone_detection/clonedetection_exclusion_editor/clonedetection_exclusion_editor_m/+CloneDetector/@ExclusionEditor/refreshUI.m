function result=refreshUI(this)




    result=[];
    window=Advisor.UIService.getInstance.getWindowById(this.AppID,this.windowId);
    if isempty(window)
        return;
    end

    window.publishToUI('ExclusionEditorClones::UpdateUI',this.TableData);
end
