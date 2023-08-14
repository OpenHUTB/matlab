classdef(Sealed)MatlabCoderReportType<codergui.ReportType




    properties(Constant)
        ClientTypeValue='codegen'
        FileCategory='MATLAB_Coder_Report'
    end

    methods
        function this=MatlabCoderReportType()
            this.Priority=-1;
            this.MapFilePath=fullfile('coder','helptargets.map');
            this.BaseProducts='matlabcoder';
        end

        function matched=isType(~,reportContext)
            matched=~isempty(reportContext.CompilationContext)&&strcmpi(reportContext.ClientType,'codegen');
        end

        function products=getProductsUsed(~,reportContext)
            products={'matlabcoder'};
            if~isempty(reportContext.CompilationContext.FixptData)
                products{end+1}='fixedpoint';
            end
        end

        function title=getWindowTitle(~,~)
            title=message('coderWeb:matlab:browserTitleMatlabCoder').getString();
        end
    end
end