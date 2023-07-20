classdef(Sealed)FloatToFixedReportType<codergui.ReportType




    properties(Constant)
        ClientTypeValue='float2fixed'
        FileCategory=codergui.ReportType.GENERIC_FILE_CATEGORY
    end

    methods
        function this=FloatToFixedReportType()
            this.Priority=2;
            this.MapFilePath=codergui.internal.reporttype.InstrumentationReportType.FIXED_POINT_MAP_PATH;
        end

        function title=getWindowTitle(this,~)
            title=this.getDefaultWindowTitle();
        end

        function matched=isType(this,reportContext)
            matched=strcmp(reportContext.ClientType,this.ClientTypeValue);
        end

        function products=getProductsUsed(~,reportContext)
            products={'fixedpoint'};
            if~isempty(reportContext.CompilationContext)&&reportContext.CompilationContext.isCodeGenClient()
                products{end+1}='matlabcoder';
            end
        end

        function yes=canHaveMainDocTopic(~)
            yes=false;
        end
    end
end