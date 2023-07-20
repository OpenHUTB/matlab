classdef MaxInitAggressors<serdes.internal.ibisami.ami.parameter.GeneralReservedParameter

...
...
...
...
...
...
...
...



    methods
        function param=MaxInitAggressors()
            param.NodeName="Max_Init_Aggressors";
            param.Usage=serdes.internal.ibisami.ami.usage.Info();
            param.Type=serdes.internal.ibisami.ami.type.Integer();
            param.Format=serdes.internal.ibisami.ami.format.Value(0);
            param.Description=...
            "The number of crosstalk aggressors supported by this model.";
        end
    end
    methods(Access=protected)
        function value=currentValueChanging(parameter,value)
            if isnumeric(value)
                value=num2str(value);
            end
            if ischar(value)||isstring(value)
                num=str2double(value);
                mustBeLessThanOrEqual(num,50)
                mustBeGreaterThanOrEqual(num,0)
                value=currentValueChanging@...
                serdes.internal.ibisami.ami.parameter.AmiParameter(parameter,value);
            end

        end
    end
end

