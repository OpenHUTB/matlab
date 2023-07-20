classdef(Sealed)InstrumentationReportType<codergui.ReportType




    properties(Hidden,Constant)
        FIXED_POINT_MAP_PATH=fullfile('fixedpoint','fixedpoint.map')
    end

    properties(Constant)
        ClientTypeValue='instrumentation'
        FileCategory='Instrumentation_Report'
    end

    methods
        function this=InstrumentationReportType()
            this.Priority=1;
            this.MapFilePath=this.FIXED_POINT_MAP_PATH;
            this.MainDocTopic='help_button_instrumentation_report';
            this.BaseProducts='fixedpoint';
        end

        function matched=isType(~,reportContext)
            matched=~isempty(reportContext.Report)&&isfield(reportContext.Report,'InstrumentedData');
        end

        function title=getWindowTitle(~,~)
            title=message('coderWeb:matlab:browserTitleInstrumentation').getString();
        end
    end
end

