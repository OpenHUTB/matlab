classdef PDFReport<matlab.internal.project.util.ReportGenerator.ReportGeneratorCustomisation




    properties(Constant)
        FileType='pdf';
        Parameter='single';
        DisplayType='pdf';
    end

    methods(Access=public)
        function displayReport(obj,filePath)
            rptview(filePath,obj.DisplayType);
        end

        function filePath=getFilePath(obj,filePath)
            [pathstr,name,~]=fileparts(filePath);
            filePath=fullfile(pathstr,[name,'.',obj.FileType]);
        end
    end

end

