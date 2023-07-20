classdef Report<handle




    methods(Sealed,Hidden)
        function ctr=getImplCtr(~)
            ctr=str2func('slreportgen.report.internal.Document');
        end
    end

end

