




classdef Watchpoint<Simulink.Debug.BaseItem
    properties(Transient)
        id=[];
    end

    methods
        function obj=Watchpoint(modelName,domain)
            obj=obj@Simulink.Debug.BaseItem(modelName,domain);
            obj.id=Simulink.Debug.Watchpoint.getNextId();
        end

        function loadSuccessfully=reload(obj)
            obj.id=Simulink.Debug.Watchpoint.getNextId();
            loadSuccessfully=true;
        end

        function clearValue(~)

        end
    end

    methods(Abstract)
        updateValue(obj);
        result=getValue(obj);
        name=getName(obj);
        path=getPath(obj);
        navigateToData(obj);
        navigateToPath(obj);
    end

    methods(Static)

        function id=getNextId
            persistent index;

            mlock();
            if isempty(index)
                index=0;
            end

            index=index+1;
            id=index;
        end
    end
end
