function generateCodeMetrics(model,varargin)




    model=convertStringsToChars(model);
    par=inputParser;
    par.addParameter('BuildDir','');
    par.addParameter('FileName','metrics.html');
    par.parse(varargin{:})
    par=par.Results;
    if isempty(par.BuildDir)
        rptInfo=rtw.report.getReportInfo(model);
        par.BuildDir=rptInfo.BuildDirectory;
    end
    cm=rtw.codemetrics.CodeMetrics(par.BuildDir,struct('BuildDir',par.BuildDir,'SourceSubsystem',model));
    cm.emitHTML(struct('standalone',true,'ReportFileName',convertStringsToChars(par.FileName)));
end
