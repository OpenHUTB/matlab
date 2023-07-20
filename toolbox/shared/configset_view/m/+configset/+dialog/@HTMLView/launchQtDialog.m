function launchQtDialog(obj)





    if isa(obj.Dlg,'DAStudio.Dialog')
        obj.Dlg.showNormal;
    else
        dirty=loc_preLaunch(obj);
        obj.Dlg=DAStudio.Dialog(obj);
        loc_afterLaunch(obj,dirty);
    end

    function dirty=loc_preLaunch(obj)

        cs=obj.Source.getCS;


        if~isempty(cs.getComponent('Code Generation'))
            dirty=configset.internal.util.objectiveUpgrade(cs);
        else
            dirty=false;
        end

        function loc_afterLaunch(obj,dirty)

            if dirty
                obj.enableApplyButton(true);
            end
