function setDialogDirty(this,status)
    ExclWindow=Advisor.UIService.getInstance.getWindowById('ExclusionEditor',this.windowId);

    if status
        title=strcat(ExclWindow.getTitle(),'*');
    else
        title=strrep(ExclWindow.getTitle(),'*','');
    end

    if ExclWindow.isOpen()
        ExclWindow.setTitle(title);
        ExclWindow.publishToUI('ExclusionEditor::setDirty',status);
    end
end