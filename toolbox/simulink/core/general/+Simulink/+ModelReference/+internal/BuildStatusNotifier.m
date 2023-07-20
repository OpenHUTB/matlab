




classdef BuildStatusNotifier<handle
    properties
mdlCounter
nTotalMdls
lvlMdlRefName
targetType
numWorkers
iMdl
    end
    events
startMdlRefBuild
    end
    methods
        function obj=BuildStatusNotifier(iMdl,totalMdls,targetType)
            obj.iMdl=iMdl;
            obj.nTotalMdls=totalMdls;
            obj.targetType=targetType;
            obj.mdlCounter=0;
        end



        function increment(obj,mdlName)
            obj.mdlCounter=obj.mdlCounter+1;
            obj.lvlMdlRefName=mdlName;
            notify(obj,'startMdlRefBuild',Simulink.ModelReference.internal.BuildStatusEventData());
        end
        function update(obj,mdlCount,mdlName)
            obj.mdlCounter=mdlCount;
            obj.lvlMdlRefName=mdlName;
            notify(obj,'startMdlRefBuild',Simulink.ModelReference.internal.BuildStatusEventData());
        end
    end
end