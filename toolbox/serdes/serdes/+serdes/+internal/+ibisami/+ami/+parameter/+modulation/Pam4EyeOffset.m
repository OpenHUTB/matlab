classdef(Abstract)Pam4EyeOffset<serdes.internal.ibisami.ami.parameter.JitterOrNoiseParameter

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



    methods
        function param=Pam4EyeOffset()
            param.Usage=serdes.internal.ibisami.ami.usage.Out();
            param.Type=serdes.internal.ibisami.ami.type.Float();
            param.AllowedUsages=["Info","InOut","Out","Dep"];
            param.AllowedTypes=["Float","UI"];
            param.AllowedFormats="Value";
            param.DirectionTx=false;
        end
    end
end

