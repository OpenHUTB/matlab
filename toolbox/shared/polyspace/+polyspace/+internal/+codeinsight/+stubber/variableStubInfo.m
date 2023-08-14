

classdef variableStubInfo<handle
    properties
        Name(1,1)string
        TypeDeclaration(1,1)string
        Definition(1,1)string
    end

    methods
        function self=variableStubInfo(variableName,variableTypeName,typeDefStub)
            self.Name=variableName;

            self.TypeDeclaration=typeDefStub;

            self.Definition=variableTypeName+";";
        end
    end
end

