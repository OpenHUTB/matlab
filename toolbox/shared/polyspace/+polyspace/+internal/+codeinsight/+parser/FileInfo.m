classdef FileInfo<polyspace.internal.codeinsight.parser.InfoHandle
    properties
        Path(1,1)string
        Includes polyspace.internal.codeinsight.parser.FileInfo
    end

    methods

        function res=unfold(self)
            res.Path=self.Path;
            if numel(self.Includes)>0
                res.Includes=join([self.Includes.Path],",");
            else
                res.Includes="";
            end
        end
    end
end

