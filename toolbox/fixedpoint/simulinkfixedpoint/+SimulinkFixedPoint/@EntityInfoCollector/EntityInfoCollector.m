classdef EntityInfoCollector<handle





    properties(GetAccess=private,SetAccess=private)


        busObjHandleMap=SimulinkFixedPoint.BusObjectHandleMap;
    end

    methods

        function obj=EntityInfoCollector(ascalerMetaData)



            obj.busObjHandleMap=ascalerMetaData.getBusObjectHandleMap;
        end


        info=collectInfo(this,entityAutoscaler,entity,pathItem);
    end

end



