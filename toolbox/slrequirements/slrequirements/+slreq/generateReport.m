









































function out=generateReport(reqSetList,opts)
    try
        useDefault=false;

        if nargin<2||isempty(opts)
            opts=slreq.getReportOptions();
            useDefault=true;
        end

        if~useDefault
            if~isstruct(opts)
                error(message('Slvnv:slreq:ReportGenErrorInvalidOptions'))
            end
            [opts,msgid]=getUserOptions(opts);
            if~isempty(msgid)
                error(msgid);
            end
        end

        if nargin<1||(~iscell(reqSetList)&&strcmpi(reqSetList,'all'))
            reqSetList=slreq.data.ReqData.getInstance.getLoadedReqSets();
        elseif~isa(reqSetList,'slreq.ReqSet')
            error(message('Slvnv:slreq:ReportGenErrorInvalidReqSet'));
        end

        if isempty(reqSetList)
            error(message('Slvnv:slreq:ReportOPTGUINoReqSelected'));
        end

        slreq.report.utils.generateReport(reqSetList,...
        'ReportOptions',opts,...
        'ShowUI',false);
        out=opts.reportPath;
    catch ex
        throwAsCaller(ex);
    end
end

function[out,msgid]=getUserOptions(opts)

    defaultOpts=slreq.getReportOptions;
    msgid='';
    out=defaultOpts;
    if isfield(opts,'reportPath')
        [reportPath,~,reportExt]=fileparts(opts.reportPath);
        if~exist(reportPath,'dir')
            msgid=message('Slvnv:slreq:ReportGenErrorInvalidReportDir',reportPath);
            return;
        end

        if~ismember(reportExt,{'.pdf','.html','.docx'})
            msgid=message('Slvnv:slreq:ReportGenErrorInvalidReportType');
            return;
        end
        out.reportPath=opts.reportPath;
    end

    if isfield(opts,'openReport')
        out.openReport=opts.openReport;
    end

    if isfield(opts,'titleText')
        out.titleText=opts.titleText;
    end

    if isfield(opts,'authors')
        out.authors=opts.authors;
    end

    if isfield(opts,'includes')
        allIncludes=opts.includes;
        allfields=fieldnames(defaultOpts.includes);
        for index=1:length(allfields)
            cField=allfields{index};
            if isfield(allIncludes,cField)
                out.includes.(cField)=allIncludes.(cField);
            end
        end
    end
end