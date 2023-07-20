function setLog(h,str)




    h.Log=str;

    if~isempty(h.testComp)&&~h.closed
        try
            w=DAStudio.imDialog.getIMWidgets(h.dialogH);
            log=find(w,'Tag','logarea');
            if~h.closed
                log.text=h.Log;
            end
        catch Mex %#ok<NASGU>
        end
    end
