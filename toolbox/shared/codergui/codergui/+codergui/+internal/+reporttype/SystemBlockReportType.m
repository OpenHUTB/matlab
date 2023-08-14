classdef(Sealed)SystemBlockReportType<codergui.ReportType




    properties(Constant)
        ClientTypeValue='systemblock'
        FileCategory='System_Block_Report'
    end

    methods
        function this=SystemBlockReportType()
            this.AppendFilePathToTitle=false;
            this.Priority=2;
        end

        function matched=isType(this,reportContext)
            matched=strcmpi(reportContext.ClientType,this.ClientTypeValue);
        end

        function title=getWindowTitle(~,manifest)
            blockName=codergui.internal.reporttype.MatlabFunctionBlockReportType.manifestToBlockName(manifest);
            title=message('coderWeb:matlab:browserTitleSystemBlock',blockName).getString();
        end
    end
end