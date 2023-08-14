classdef(Sealed)InstrumentedMexReportType<codergui.ReportType




    properties(Constant)
        ClientTypeValue='instrumentedmex'
        FileCategory=codergui.ReportType.GENERIC_FILE_CATEGORY
    end

    methods
        function this=InstrumentedMexReportType()
            this.Priority=1;
            this.MapFilePath=codergui.internal.reporttype.InstrumentationReportType.FIXED_POINT_MAP_PATH;
            this.MainDocTopic='help_button_compilation_report_instrumented_mex';
        end

        function matched=isType(~,reportContext)
            matched=~isempty(reportContext.CompilationContext)&&...
            strcmpi(reportContext.CompilationContext.getFeatureControl().LocationLogging,'mex');
        end

        function title=getWindowTitle(~,~)
            title=message('coderWeb:matlab:browserTitleInstrumentedMex').getString();
        end

        function products=getProductsUsed(~,reportContext)
            products={'fixedpoint'};
            if~isempty(reportContext.CompilationContext)&&reportContext.CompilationContext.isCodeGenClient()
                products{end+1}='matlabcoder';
            end
        end
    end
end