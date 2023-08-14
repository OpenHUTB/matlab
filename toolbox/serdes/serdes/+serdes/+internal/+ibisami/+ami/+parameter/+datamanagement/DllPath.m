classdef DllPath<serdes.internal.ibisami.ami.parameter.DataManagementReservedParameter

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
        function param=DllPath()
            param.NodeName="DLL_Path";
            param.Usage=serdes.internal.ibisami.ami.usage.In();
            param.Type=serdes.internal.ibisami.ami.type.String();
            param.Format=serdes.internal.ibisami.ami.format.Value();
            param.Description=...
            "The EDA tool is responsible for replacing the value declared in the .ami file with a string that contains the path to the directory where the executable model file and .ami files reside";
        end
    end
end

