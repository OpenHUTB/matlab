function onBrowseHdlPath(this,dialog)



    r=uigetdir(this.UserData.HdlPath,'Please select the directory that contains HDL simulator executables.');
    if(~isnumeric(r))
        this.UserData.HdlPath=r;
    end
    dialog.refresh;
end

