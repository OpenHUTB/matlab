classdef(Sealed)GpuCoderReportType<codergui.ReportType




    properties(Constant)
        ClientTypeValue='gpu'
        FileCategory='GPU_Coder_Report'
    end

    methods
        function this=GpuCoderReportType()
            this.MapFilePath=fullfile('gpucoder','helptargets.map');
            this.BaseProducts={'matlabcoder','gpucoder'};
        end

        function matched=isType(~,reportContext)
            matched=~isempty(reportContext.Config)&&isprop(reportContext.Config,'GpuConfig')&&...
            ~isempty(reportContext.Config.GpuConfig);
        end

        function title=getWindowTitle(~,~)
            title=message('coderWeb:matlab:browserTitleGpuCoder').getString();
        end
    end
end