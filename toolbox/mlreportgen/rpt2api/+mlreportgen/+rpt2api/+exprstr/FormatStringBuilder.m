classdef FormatStringBuilder<mlreportgen.rpt2api.exprstr.StringBuilder

    methods
        function obj=FormatStringBuilder()

            obj@mlreportgen.rpt2api.exprstr.StringBuilder();
        end

        function build(obj,char)

            switch char
            case{"%","\",'"'}
                obj.Str=[obj.Str,char,char];
            case newline
                obj.Str=[obj.Str,'\n'];
            otherwise
                obj.Str=[obj.Str,char];
            end
        end
    end
end

