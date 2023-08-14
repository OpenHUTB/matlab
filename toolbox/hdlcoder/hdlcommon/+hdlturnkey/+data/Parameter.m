


classdef Parameter<handle


    properties

        ID='';
        DisplayName='';
        Value='';
        DefaultValue='';
        ParameterType=hdlcoder.ParameterType.Edit;
        Choice={};
        ValidationFcn=[];

    end

    methods

        function obj=Parameter()

        end


        function validateParameterValue(obj,value)
            if isempty(obj.ValidationFcn)
                return;
            else
                obj.ValidationFcn(value);
            end
        end
    end

end
