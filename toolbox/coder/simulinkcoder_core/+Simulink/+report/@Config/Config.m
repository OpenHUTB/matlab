classdef Config





    properties
        LaunchReport='off'
        IncludeHyperlinkInReport='off'
        GenerateTraceInfo='off'
        GenerateTraceReport='off'
        GenerateTraceReportSl='off'
        GenerateTraceReportSf='off'
        GenerateTraceReportEml='off'
        GenerateCodeMetricsReport='off'
        GenerateCodeReplacementReport='off'
        GenerateMissedCodeReplacementReport='off'
        GenerateWebview='off'
        GenerateComments='off'
        InCodeTrace='off'
    end

    methods
        function obj=Config(model)
            if nargin>0
                if~strcmp(get_param(model,'IsERTTarget'),'on')
                    obj.LaunchReport=get_param(model,'LaunchReport');
                else

                    param=obj.getAllPropNames;
                    for k=1:length(param)
                        obj.(param{k})=get_param(model,param{k});
                    end
                end
            end
        end
    end

    methods(Access=private)
        out=getAllPropNames(obj)
    end
end


