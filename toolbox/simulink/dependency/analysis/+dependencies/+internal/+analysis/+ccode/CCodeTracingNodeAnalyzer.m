classdef CCodeTracingNodeAnalyzer<dependencies.internal.analysis.ccode.CCodeNodeAnalyzer





    methods

        function deps=analyze(~,~,node)
            filePath=node.Location{1};
            parentPath=fileparts(filePath);

            try
                rptInfo=rtw.report.getReportInfo([],parentPath);
            catch
                rptInfo=[];
            end

            import dependencies.internal.analysis.ccode.findHeaderDependencies;
            if isempty(rptInfo)
                deps=findHeaderDependencies(filePath);
            else
                includeFolders=unique({parentPath,rptInfo.StartDir,...
                rptInfo.GenUtilsPath,rptInfo.BuildDirectory,rptInfo.getFileInfo.Path});
                includeFolders=includeFolders(~strcmp(includeFolders,""));
                includeFlags=strcat('-I',includeFolders);
                deps=findHeaderDependencies(filePath,includeFlags);
            end
        end

    end

end
