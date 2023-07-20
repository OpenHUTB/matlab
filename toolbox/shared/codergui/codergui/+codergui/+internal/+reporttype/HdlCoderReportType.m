classdef(Sealed)HdlCoderReportType<codergui.ReportType




    properties(Constant)
        ClientTypeValue='hdl'
        FileCategory='HDL_Coder_Report'
    end

    methods
        function this=HdlCoderReportType()
            this.MapFilePath=fullfile('hdlcoder','helptargets.map');
            this.Priority=3;
            this.BaseProducts={'matlabcoder','hdlcoder'};
        end

        function matched=isType(~,reportContext)
            matched=reportContext.IsHdl||isa(reportContext.Config,'coder.HdlConfig');
        end

        function title=getWindowTitle(~,~)
            title=message('coderWeb:matlab:browserTitleHdlCoder').getString();
        end
    end
end