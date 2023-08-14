classdef Report<handle





    methods(Sealed,Hidden)
        function ctr=getImplCtr(~)
            ctr=str2func('mlreportgen.report.internal.Document');
        end
    end

end

