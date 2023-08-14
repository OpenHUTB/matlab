classdef SmallSignalData<rf.file.shared.ParameterData



    properties(SetAccess=protected)
ParameterType
FrequencyConversion
    end

    methods
        function obj=SmallSignalData(newData,newFreqUnit,newFormat,newRefImp,newParamType,newFrequencyConversion,newFormatLine)


            narginchk(7,7)
            validateattributes(newFormatLine,{'char'},{'row'})
            obj=obj@rf.file.shared.ParameterData(newData,newFreqUnit,newFormat,newRefImp);
            obj.ParameterType=newParamType;
            obj.FrequencyConversion=newFrequencyConversion;
            assigndata(obj,newData,newFormatLine)
        end
    end

    methods
        function set.FrequencyConversion(obj,newFreqConv)
            validateattributes(newFreqConv,{'numeric'},{'size',[1,2],'real','nonnan'},'','FrequencyConversion')
            obj.FrequencyConversion=newFreqConv;
        end

        function set.ParameterType(obj,newParamType)
            validateattributes(newParamType,{'char'},{'scalar'},'','ParameterType')
            obj.ParameterType=newParamType;
        end
    end

    methods(Access=protected,Static,Hidden)
        function out=getformatlinekeys
            out={'F','N11X','N11Y','N21X','N21Y','N12X','N12Y','N22X','N22Y'};
        end
    end

    methods(Access=protected,Hidden)
        function assigndata(obj,newData,newFormatLine)
            reorderedData=rf.file.shared.sandp2d.reorderdata(rf.file.shared.sandp2d.SmallSignalData.getformatlinekeys,newData,newFormatLine);
            obj.Data=reorderedData;
        end
    end
end