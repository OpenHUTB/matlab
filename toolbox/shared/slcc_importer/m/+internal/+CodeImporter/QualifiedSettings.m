classdef QualifiedSettings
    properties
        OutputFolder(1,1)string=""
        CustomCode(1,1)Simulink.CodeImporter.CustomCode=Simulink.CodeImporter.CustomCode;
    end

    methods
        function obj=QualifiedSettings
            obj.OutputFolder="";
            obj.CustomCode=Simulink.CodeImporter.CustomCode;
        end
    end
end

