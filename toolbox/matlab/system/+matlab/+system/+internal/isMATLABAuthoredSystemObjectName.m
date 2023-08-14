function flag=isMATLABAuthoredSystemObjectName(name)










    flag=false;
    mc=meta.class.fromName(name);

    if~isempty(mc)
        flag=isMATLABAuthoredSysObj(mc);
    end

    function flag=isMATLABAuthoredSysObj(mc)


        flag=false;

        if strcmp(mc.Name,'matlab.System')
            flag=true;
            return;
        end

        for ix=1:length(mc.SuperClasses)
            flag=isMATLABAuthoredSysObj(mc.SuperClasses{ix});
            if flag
                return;
            end
        end
