



classdef ResultReportCreatedEvent<event.EventData
    properties
        ResultObjs sltest.testmanager.TestResult;
        FilePath(1,1)string;
    end

    methods
        function this=ResultReportCreatedEvent(resultObjs,filePath)
            this.ResultObjs=resultObjs;
            this.FilePath=filePath;
        end
    end
end
