classdef(Sealed)ReportInfo<handle
































    properties(SetAccess=immutable)
        Summary coder.Summary=coder.Summary.empty()
Config
        InputFiles coder.File=coder.File.empty()
        GeneratedFiles coder.File=coder.File.empty()
        Functions coder.Function=coder.Function.empty()
        Messages coder.Message=coder.Message.empty()
        CodeInsights coder.Message=coder.Message.empty()
        BuildLogs coder.BuildLog=coder.BuildLog.empty()
    end

    methods(Access=?codergui.internal.CodegenInfoBuilder)
        function obj=ReportInfo(summary,config,inputFiles,generatedFiles,...
            fcns,msgs,insights,buildLogs)
            if nargin==0
                return
            end
            narginchk(8,8);
            obj.Summary=summary;
            obj.Config=config;
            obj.InputFiles=inputFiles;
            obj.GeneratedFiles=generatedFiles;
            obj.Functions=fcns;
            obj.Messages=msgs;
            obj.CodeInsights=insights;
            obj.BuildLogs=buildLogs;
        end
    end
end