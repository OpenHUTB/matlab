classdef(Abstract,Hidden,AllowedSubclasses={?matlab.internal.language.Snapshottable})VisualOutput<handle













    properties(Hidden,Transient,Access=private)
        VisualOutputUid;
        VisualOutputData;
        VisualOutputIsCapturing;
    end

    methods(Sealed,Hidden)
        function obj=VisualOutput()




            obj.VisualOutputIsCapturing=matlab.internal.language.hasVisualOutputEventListeners();




            obj.notifyOutputChanged();
        end

        function notifyOutputChanged(obj)





            if obj.VisualOutputIsCapturing
                matlab.internal.language.signalVisualOutputEvent(obj);
            end
        end

        function uid=getVisualOutputUid(obj)






            if isempty(obj.VisualOutputUid)
                obj.VisualOutputUid=matlab.lang.internal.uuid;
            end
            uid=obj.VisualOutputUid;
        end

        function setVisualOutputData(obj,namespace,key,value)









            name=['NS',namespace,'_',key];
            obj.VisualOutputData.(name)=value;
        end

        function value=getVisualOutputData(obj,namespace,key)









            value=[];
            name=['NS',namespace,'_',key];
            if isfield(obj.VisualOutputData,name)
                value=obj.VisualOutputData.(name);
            end
        end

        function clearVisualOutputData(obj,namespace)




            if isempty(obj.VisualOutputData)
                return
            end

            keys=fieldnames(obj.VisualOutputData);
            matches=startsWith(keys,['NS',namespace,'_']);
            fieldsToRemove=keys(matches);
            obj.VisualOutputData=rmfield(obj.VisualOutputData,fieldsToRemove);
        end
    end
end
