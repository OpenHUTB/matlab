classdef Modulation<serdes.internal.ibisami.ami.parameter.ModulationReservedParameter

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
        AllowedValuesForIBISAMI=["NRZ","PAM4"]
        AllowedValuesForSimulation=["PAM3","PAM8","PAM16"]
    end
    methods
        function param=Modulation()
            param.NodeName="Modulation";
            param.Usage=serdes.internal.ibisami.ami.usage.Info();
            param.Type=serdes.internal.ibisami.ami.type.String();
            param.Format=serdes.internal.ibisami.ami.format.Value("PAM4");
            param.Description="Specifies signaling scheme of model.";
            param.AllowedUsages=["Info","In"];
            param.AllowedTypes="String";
            param.AllowedFormats=["Value","List"];
        end
    end
    methods(Access=protected)
        function value=currentValueChanging(parameter,value)
            if ischar(value)||isstring(value)
                value=string(value).upper;
                if~ismember(value,parameter.AllowedValuesForIBISAMI)&&~ismember(value,parameter.AllowedValuesForSimulation)
                    error(message('serdes:ibis:ModulationMustBe',value))
                end
                value=currentValueChanging@...
                serdes.internal.ibisami.ami.parameter.AmiParameter(parameter,value);
            end

        end
    end
end

