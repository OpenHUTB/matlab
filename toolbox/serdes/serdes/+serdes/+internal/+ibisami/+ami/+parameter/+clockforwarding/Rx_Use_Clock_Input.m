classdef Rx_Use_Clock_Input<serdes.internal.ibisami.ami.parameter.ReservedParameter

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...



    properties(Access=private)
        AllowedValues=["None","Times","Wave"]
    end

    methods
        function param=Rx_Use_Clock_Input()
            param.NodeName="Rx_Use_Clock_Input";
            param.Usage=serdes.internal.ibisami.ami.usage.In;
            param.Type=serdes.internal.ibisami.ami.type.String;
            param.Format=serdes.internal.ibisami.ami.format.Value("None");
            param.Description=...
            "Specifies the content of the clock_times input supported by this model.";
            param.AllowedUsages=["In"];%#ok<*NBRAK>
            param.AllowedTypes=["String"];
            param.DirectionTx=false;
            param.AllowedFormats=["Value","List"];
            param.EarliestRequiredVersion=7.1;
        end
    end
    methods(Access=protected)
        function value=currentValueChanging(parameter,value)
            if ischar(value)||isstring(value)
                tvalue=parameter.AllowedValues(strcmpi(value,parameter.AllowedValues));
                if isempty(tvalue)
                    error(message('serdes:ibis:RxUseClockInputMustBe',value))
                end
                value=currentValueChanging@...
                serdes.internal.ibisami.ami.parameter.AmiParameter(parameter,tvalue);
            end
        end
    end
end

