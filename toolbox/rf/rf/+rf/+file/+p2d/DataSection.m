classdef DataSection<rf.file.shared.sandp2d.DataSection




    properties(SetAccess=protected)
Power
    end

    methods
        function obj=DataSection(newSmallSignal,newNoise,newIMT,newPower)
            obj=obj@rf.file.shared.sandp2d.DataSection(newSmallSignal,newNoise,newIMT);
            obj.Power=newPower;
        end
    end

    methods
        function set.Power(obj,newPowerObj)
            validateattributes(newPowerObj,{'rf.file.p2d.PowerData'},{'2d'})
            obj.Power=newPowerObj;
        end
    end

    methods
        function out=haspowerdata(obj)
            out=~isempty(obj.Power);
        end
    end
end