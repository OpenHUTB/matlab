

classdef FunInfo<polyspace.internal.codeinsight.parser.InfoHandle

    properties
        Name(1,1)string
        Signature(1,1)string
        IsDeclared(1,1)logical=false
        DeclarationFile(1,:)polyspace.internal.codeinsight.parser.FileInfo
        DeclarationLine(1,:)int32
        IsDefined(1,1)logical=false
        DefinitionFile(1,1)polyspace.internal.codeinsight.parser.FileInfo
        DefinitionBlock(1,1)polyspace.internal.codeinsight.parser.BlockInfo
        FormalArguments(1,:)polyspace.internal.codeinsight.parser.TypeInfo
        ReturnedType(1,1)polyspace.internal.codeinsight.parser.TypeInfo
        IsImportCompliant(1,1)logical
        CalledFuns(1,:)polyspace.internal.codeinsight.parser.FunInfo
        ReadVars(1,:)polyspace.internal.codeinsight.parser.VarInfo
        WrittenVars(1,:)polyspace.internal.codeinsight.parser.VarInfo
        MacroInvocation(1,:)string
        LocalTypes(1,:)string
    end

    methods

        function res=unfold(self)
            res.DeclarationFile="";
            if numel(self.DeclarationFile)>0
                res.DeclarationFile=join([self.DeclarationFile.Path],newline);
            end
            res.FormalArguments="";
            if numel(self.FormalArguments)>0
                res.FormalArguments=join([self.FormalArguments.Signature],",");
            end
            res.Name=self.Name;
            res.Signature=self.Signature;
            res.IsDeclared=self.IsDeclared;
            res.IsDefined=self.IsDefined;
            res.DefinitionFile=self.DefinitionFile.Path;
            res.ReturnedType=self.ReturnedType.Signature;
            res.IsImportCompliant=self.IsImportCompliant;
            res.CalledFuns="";
            if numel(self.CalledFuns)>0
                res.CalledFuns=join([self.CalledFuns.Name],",");
            end
            res.ReadVars="";
            if numel(self.ReadVars)>0
                res.ReadVars=join([self.ReadVars.Name],",");
            end
            res.WrittenVars="";
            if numel(self.WrittenVars)>0
                res.WrittenVars=join([self.WrittenVars.Name],",");
            end
            res.MacroInvocation="";
            if numel(self.MacroInvocation)>0
                res.MacroInvocation=join([self.MacroInvocation],",");
            end
            res.LocalTypes="";
            if numel(self.LocalTypes)>0
                res.LocalTypes=join([self.LocalTypes],",");
            end
        end
    end
end