classdef ModelNameUtils<handle
    methods(Static,Access=public)
        function s=getNameSuffix(n)
            s=char('a'+mod(n,26));
            n=fix(n/26);
            while(n>0)
                n=n-1;
                s=[char('a'+mod(n,26)),s];%#ok<AGROW>
                n=fix(n/26);
            end
        end
    end
end
