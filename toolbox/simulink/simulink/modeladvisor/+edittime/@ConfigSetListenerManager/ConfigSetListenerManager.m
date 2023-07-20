classdef ConfigSetListenerManager<handle





    properties
        listeners=[];
    end
    methods(Static=true,Access='public')
        function singleObj=getInstance(~)
            persistent localStaticObj;
            if(isempty(localStaticObj))
                localStaticObj=edittime.ConfigSetListenerManager;
            end
            singleObj=localStaticObj;
        end

        function addListener(system)
            obj=edittime.ConfigSetListenerManager.getInstance;
            systemObj=get_param(system,'object');
            cs=systemObj.getActiveConfigSet();
            if isempty(obj.listeners)
                obj.listeners=edittime.ConfigSetAdapter(cs,system);
            else
                obj.listeners(end+1)=edittime.ConfigSetAdapter(cs,system);
            end
        end

        function removeListener(system)
            obj=edittime.ConfigSetListenerManager.getInstance;
            for i=1:length(obj.listeners)
                if strcmp(obj.listeners(i).system,system)
                    obj.listeners(i)=[];
                    break;
                end
            end
        end
    end


end

