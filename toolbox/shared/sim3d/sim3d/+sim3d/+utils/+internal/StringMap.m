classdef StringMap
    methods(Static)
        function output=fwd(s)


            s=strrep(s,'-',' ');


            output=regexprep(s,'(?:^|\s+)(.)','${upper($1)}');
        end

        function output=inv(s)

            output=regexprep(s,'([a-z])([A-Z])','$1 ${lower($2)}');


        end
    end
end
