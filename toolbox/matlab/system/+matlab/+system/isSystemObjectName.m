function flag=isSystemObjectName(name)








    flag=false;
    mc=meta.class.fromName(name);

    if~isempty(mc)
        flag=isSysObj(mc);
    end

    function flag=isSysObj(mc)


        flag=false;

        if strcmp(mc.Name,'matlab.system.SystemImpl')
            flag=true;
            return;
        end

        for ix=1:length(mc.SuperClasses)
            flag=isSysObj(mc.SuperClasses{ix});
            if flag
                return;
            end
        end
