classdef BCI_ID<serdes.internal.ibisami.ami.parameter.BCIReservedParameter

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
...
...
...
...
...
...



    methods
        function param=BCI_ID()
            param.NodeName="BCI_ID";
            param.Usage=serdes.internal.ibisami.ami.usage.In;
            param.Type=serdes.internal.ibisami.ami.type.String;
            param.Format=serdes.internal.ibisami.ami.format.Value("To be Set by EDA Tool");
            param.Description=...
            "A unique identifier set by EDA tool.";
            param.AllowedUsages=["In"];%#ok<*NBRAK>
            param.AllowedTypes=["String"];
            param.AllowedFormats=["Value"];
            param.EarliestRequiredVersion=7.0;
        end
    end
end

