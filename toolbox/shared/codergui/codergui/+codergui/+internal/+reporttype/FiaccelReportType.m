classdef FiaccelReportType<codergui.ReportType




    properties(Constant)
        ClientTypeValue='fiaccel'
        FileCategory=codergui.ReportType.GENERIC_FILE_CATEGORY
    end

    methods
        function this=FiaccelReportType()
            this.MapFilePath=codergui.internal.reporttype.InstrumentationReportType.FIXED_POINT_MAP_PATH;
            this.MainDocTopic='help_button_compilation_report_fiaccel';
            this.BaseProducts='fixedpoint';
        end

        function matched=isType(~,reportContext)
            matched=~isempty(reportContext.CompilationContext)&&strcmpi(reportContext.ClientType,'fiaccel');
        end

        function title=getWindowTitle(this,~)
            title=this.getDefaultWindowTitle();
        end
    end
end
