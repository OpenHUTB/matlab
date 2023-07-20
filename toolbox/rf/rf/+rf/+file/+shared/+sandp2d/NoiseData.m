classdef NoiseData<rf.file.shared.ParameterData


    properties(SetAccess=protected)
IsNormalized
    end

    methods
        function obj=NoiseData(newData,newFreqUnit,newFormat,newRefImp,newIsNormalized,newFormatLine)


            narginchk(6,6)
            validateattributes(newFormatLine,{'char'},{'row'})
            obj=obj@rf.file.shared.ParameterData(newData,newFreqUnit,newFormat,newRefImp);
            obj.IsNormalized=newIsNormalized;
            assigndata(obj,newData,newFormatLine)
        end
    end

    methods
        function set.IsNormalized(obj,newIsNormalized)
            validateattributes(newIsNormalized,{'numeric','logical'},{'scalar'},'','IsNormalized')
            obj.IsNormalized=newIsNormalized;
        end
    end

    methods(Access=protected,Static,Hidden)
        function out=getformatlinekeys
            out={'F','NFMIN','N11X','N11Y','RN'};
        end
    end

    methods(Access=protected,Hidden)
        function assigndata(obj,newData,newFormatLine)
            reorderedData=rf.file.shared.sandp2d.reorderdata(rf.file.shared.sandp2d.NoiseData.getformatlinekeys,newData,newFormatLine);
            obj.Data=reorderedData;
        end
    end
end