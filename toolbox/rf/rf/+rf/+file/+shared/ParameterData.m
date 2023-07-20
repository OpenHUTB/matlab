classdef ParameterData<handle



    properties(SetAccess=protected)
Data
FrequencyUnit
Format
ReferenceImpedance
    end

    methods
        function obj=ParameterData(newData,newFreqUnit,newFormat,newImp)
            narginchk(4,4)
            obj.validatedatainput(newData);
            obj.FrequencyUnit=newFreqUnit;
            obj.Format=newFormat;
            obj.ReferenceImpedance=newImp;
        end
    end

    methods
        function set.Data(obj,newData)


            obj.Data=newData;
        end

        function set.FrequencyUnit(obj,newFreqUnit)
            validateattributes(newFreqUnit,{'char'},{'row'},'','FrequencyUnit')
            obj.FrequencyUnit=newFreqUnit;
        end

        function set.Format(obj,newFormat)
            validateattributes(newFormat,{'char'},{'row'},'','Format')
            obj.Format=newFormat;
        end

        function set.ReferenceImpedance(obj,newReferenceImpedance)
            validateattributes(newReferenceImpedance,{'numeric'},{'scalar','real','positive','nonnan'},'','ReferenceImpedance')
            obj.ReferenceImpedance=newReferenceImpedance;
        end
    end

    methods(Static)
        function validatedatainput(newData)
            validateattributes(newData,{'numeric'},{'2d'})
        end
    end

    methods(Abstract,Access=protected,Hidden)




        assigndata(obj,varargin)
    end
end