classdef ListHelper
    methods(Static)






        function C=flatten(A)























            if iscell(A)
                C={};
                for i=1:numel(A)
                    if(~iscell(A{i}))
                        if~isempty(A{i})
                            C=safeConcat(C,A(i));
                        end
                    else
                        Ctemp=coder.internal.lib.ListHelper.flatten(A{i});
                        if iscell(Ctemp)
                            C=safeConcat(C,Ctemp);
                        else
                            C=safeConcat(C,{Ctemp});
                        end
                    end
                end
            else
                C=A;
            end



            function res=safeConcat(a,b)
                assert(iscell(a)&&iscell(b));
                res=[a,b];
            end
        end
    end
end