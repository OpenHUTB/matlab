



classdef SystemBeat<matlab.System

    properties
ModelName
Count
    end

    methods
        function obj=SystemBeat(modelName)
            obj.ModelName=modelName;
            obj.Count=uint32(0);
        end
    end

    methods(Access=protected)

        function y=stepImpl(obj,init)
            if nargin<2
                init=false;
            end
            obj.Count(:)=obj.Count+1;
            if init
                obj.Count=uint32(0);
            end
            y={};
        end
    end
end
