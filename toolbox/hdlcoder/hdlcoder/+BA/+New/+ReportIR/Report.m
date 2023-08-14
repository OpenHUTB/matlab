classdef Report<BA.New.ReportIR.PrettyPrintable

    properties(GetAccess=private,SetAccess=private)
paths
    end

    methods
        function this=Report(paths)
            this.paths=paths;
        end

        function paths=getPaths(this)
            paths=this.paths(:);
        end

        function prettyPrint(this,indentWidth,indentLevel)
        end
    end

    methods(Access=private)
        function checkRep(this)
            assert(true);
        end
    end
end
