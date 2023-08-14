

classdef VarInfo<polyspace.internal.codeinsight.parser.InfoHandle

    properties
        Name(1,1)string
        Type(1,1)polyspace.internal.codeinsight.parser.TypeInfo
        TypeName(1,1)string
        IsDeclared(1,1)logical
        DeclarationFile(1,:)polyspace.internal.codeinsight.parser.FileInfo
        DeclarationLine(1,:)int32
        IsDefined(1,1)logical
        DefinitionFile(1,1)polyspace.internal.codeinsight.parser.FileInfo
        DefinitionBlock(1,1)polyspace.internal.codeinsight.parser.BlockInfo
        IsImportCompliant(1,1)logical
        IsRead(1,1)logical=false
        IsWritten(1,1)logical=false
    end

    methods

        function res=unfold(self)
            res.Name=self.Name;
            res.Type=self.Type.Signature;
            res.IsDeclared=self.IsDeclared;
            res.DeclarationFile="";
            if numel(self.DeclarationFile)>0
                res.DeclarationFile=join([self.DeclarationFile.Path],newline);
            end
            res.IsDefined=self.IsDefined;
            res.DefinitionFile=self.DefinitionFile;
            res.IsImportCompliant=self.IsImportCompliant;
            res.IsRead=self.IsRead;
            res.IsWritten=self.IsWritten;
        end
    end
end
