classdef(Abstract)ReportGeneratorCustomisation<matlab.mixin.Heterogeneous





    properties(Abstract=true,Constant=true)
        FileType;
        Parameter;
        DisplayType;
    end

    methods(Access=public)
        function displayReport(obj,filePath)
            rptgen.rptview(filePath,obj.DisplayType);
        end

        function filePath=getFilePath(~,filePath)
        end
    end

end

