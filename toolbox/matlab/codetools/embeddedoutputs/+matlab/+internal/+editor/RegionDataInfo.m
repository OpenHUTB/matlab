classdef RegionDataInfo<handle
    properties
RegionData
        HasError=false;
        ErrorMessage='';
    end

    methods
        function setRegionData(obj,data)
            obj.RegionData=data;
        end

        function setError(obj,message)
            obj.HasError=true;
            obj.ErrorMessage=message;
        end
    end
end

