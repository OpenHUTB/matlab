

function refresh(obj)


    if obj.inRefresh
        return;
    else
        obj.inRefresh=true;
        c=onCleanup(@()loc_cleanup(obj));
    end

    if obj.isWebPageReady
        obj.isWebPageReady=false;
        if isa(obj.Dlg,'DAStudio.Dialog')
            obj.Dlg.refresh;
        end

        adp=obj.Source;
        cs=adp.Source;
        if isa(cs,'Simulink.BaseConfig')
            obj.createPage;
        end
    else


        obj.deferredRefresh=true;
    end

    function loc_cleanup(obj)
        obj.inRefresh=false;
