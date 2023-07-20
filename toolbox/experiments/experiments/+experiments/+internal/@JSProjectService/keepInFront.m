function cleanup=keepInFront(this)




    function returnToFront(this)
        pause(0.25);
        this.cef.setAlwaysOnTop(false);
        this.cef.bringToFront();
    end



    if isprop(this,'cef')&&~isempty(this.cef)&&(ispc()||ismac())
        this.cef.setAlwaysOnTop(true);
        cleanup=onCleanup(@()returnToFront(this));
    else
        cleanup=[];
    end
end
