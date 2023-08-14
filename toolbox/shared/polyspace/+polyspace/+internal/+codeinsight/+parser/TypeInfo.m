

classdef TypeInfo<polyspace.internal.codeinsight.parser.InfoHandle

    properties
        Name(1,1)string
        Signature(1,1)string
        Kind(1,1)string
        UnderlayingType(1,1)string
        IsDeclared(1,1)logical
        DeclarationFile(1,:)string
        IsDefined(1,1)logical
        DefinitionFile(1,1)string
        StubDefinition(1,:)string
        StubDeclaration(1,:)string
        StubTypeName(1,:)string
        IsImportCompliant(1,1)logical
        IsImportCompliantAsFunctionArg(1,1)logical
        IsImportCompliantAsFunctionReturn(1,1)logical
        IsImportCompliantAsAggregateField(1,1)logical
        Type polyspace.internal.codeinsight.parser.TypeInfo
        Members polyspace.internal.codeinsight.parser.MemberInfo
    end

    methods

        function res=unfold(self)
            res.Name=self.Name;
            res.Signature=self.Signature;
            res.Kind=self.Kind;
            res.IsDeclared=self.IsDeclared;
            res.DeclarationFile="";
            if numel(self.DeclarationFile)>0
                res.DeclarationFile=join(self.DeclarationFile,newline);
            end
            res.IsDefined=self.IsDefined;
            res.DefinitionFile=self.DefinitionFile;
            res.UnderlayingType=self.UnderlayingType;
            res.IsImportCompliant=self.IsImportCompliant;
            res.IsImportCompliantAsFunctionArg=self.IsImportCompliantAsFunctionArg;
            res.IsImportCompliantAsFunctionReturn=self.IsImportCompliantAsFunctionReturn;
            res.IsImportCompliantAsAggregateField=self.IsImportCompliantAsAggregateField;
            res.StubDefinition=self.StubDefinition;
        end
    end
end
