classdef MacroInfo<polyspace.internal.codeinsight.parser.InfoHandle

    properties
        Name(1,1)string
        Text(1,1)string
        Location(1,1)polyspace.internal.codeinsight.parser.BlockInfo
        IsReferenced(1,1)logical=true
    end

    methods

        function res=unfold(self)
            res.Name=self.Name;
            res.Text=self.Text;
            res.File=self.Location.File.Path;
            res.IsReferenced=self.IsReferenced;
        end
    end
end

