function result=refreshUI(this)
    result=[];
    window=Advisor.UIService.getInstance.getWindowById('ExclusionEditor',this.windowId);
    if isempty(window)
        return;
    end

    window.publishToUI("ExclusionEditor::UpdateUI",this.TableData);
end