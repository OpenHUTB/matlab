function result=checkAndCloseWindow(this,msg)
    result=[];

    if(msg==2)
        this.saveToDefaultLocation();
    end
    this.closeChildWindows();
    window=Advisor.UIService.getInstance.getWindowById('ExclusionEditor',this.windowId);
    window.close();
end