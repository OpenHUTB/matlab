classdef IMTData<handle


    properties(SetAccess=protected)
Data
ReferencePowerLevels
    end

    methods
        function obj=IMTData(newData,newReferencePowerLevels)
            obj.Data=newData;
            obj.ReferencePowerLevels=newReferencePowerLevels;
        end
    end

    methods
        function set.Data(obj,newData)
            validateattributes(newData,{'numeric'},{'2d'},'','Data')
            obj.Data=newData;
        end

        function set.ReferencePowerLevels(obj,newReferencePowerLevels)
            validateattributes(newReferencePowerLevels,{'numeric'},{'size',[1,2],'real','nonnan'},'','ReferencePowerLevels')
            obj.ReferencePowerLevels=newReferencePowerLevels;
        end
    end
end