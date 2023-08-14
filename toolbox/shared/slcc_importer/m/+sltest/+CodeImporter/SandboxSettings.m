

















classdef SandboxSettings
    properties














        Mode(1,1)internal.CodeImporter.SandboxTypeEnum=...
        internal.CodeImporter.SandboxTypeEnum.GenerateAggregatedHeader











        CopySourceFiles(1,1)logical=true










        RemoveAllPragma(1,1)logical=false









        RemoveVariableDefinitionInHeader(1,1)logical=false
    end

    properties(Hidden)


        AlwaysGenerateInterfaceHeader(1,1)logical=false
    end

    methods(Hidden)
        function shouldGenerate=generateInterfaceHeader(obj)
            shouldGenerate=obj.Mode~=internal.CodeImporter.SandboxTypeEnum.GenerateAggregatedHeader||...
            obj.AlwaysGenerateInterfaceHeader;
        end
    end

end

