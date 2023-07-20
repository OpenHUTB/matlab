classdef CodeTracingAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant,Hidden)
        GeneratedCodeType='GeneratedCode';
        GeneratedCodeRelationshipType='GeneratedCode';
    end

    methods
        function this=CodeTracingAnalyzer()
            this@dependencies.internal.analysis.simulink.ModelAnalyzer(true);
        end

        function deps=analyze(this,handler,node,~)
            [~,modelName]=fileparts(node.Location{1});

            try
                rptInfo=rtw.report.getReportInfo(modelName);
            catch
                rptInfo=[];
            end

            if isempty(rptInfo)
                deps=dependencies.internal.graph.Dependency.empty;
                return;
            end

            fileInfos=rptInfo.getFileInfo;

            import dependencies.internal.graph.Dependency;
            deps=arrayfun(@(fileInfo)Dependency(handler.Analyzers.Simulink.resolve(...
            fullfile(fileInfo.Path,fileInfo.FileName)),"",node,"",...
            strcat(this.GeneratedCodeType,',',fileInfo.Group),...
            this.GeneratedCodeRelationshipType),fileInfos);
        end
    end

end
