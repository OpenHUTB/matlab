classdef NoiseData<rf.file.shared.ParameterData


    properties(SetAccess=protected)
IsNormalized
    end

    methods
        function obj=NoiseData(newData,newFreqUnit,newFormat,newRefImp,newIsNormalized)
            narginchk(5,5)
            obj=obj@rf.file.shared.ParameterData(newData,newFreqUnit,...
            newFormat,newRefImp);
            obj.IsNormalized=newIsNormalized;
            assigndata(obj,newData);
        end
    end

    methods
        function set.IsNormalized(obj,newIsNormalized)
            validateattributes(newIsNormalized,{'numeric','logical'},{'scalar'},'','IsNormalized')
            obj.IsNormalized=newIsNormalized;
        end
    end

    methods(Access=protected,Hidden)
        function assigndata(obj,newData)
            obj.Data=newData;
        end
    end
end