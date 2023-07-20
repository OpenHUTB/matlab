



function fileNames=generateReport(obj,sldvData,format,fileNames)
    if isempty(format)
        format='-fHTML';
    end
    if isfield(obj.mTestComp.resolvedSettings,'ReportFileName')
        resolvedRptFileName=obj.mTestComp.resolvedSettings.ReportFileName;




        if strcmp(format,'-fHTML')
            if exist(resolvedRptFileName,'file')
                delete(resolvedRptFileName);
            end
        else
            [path,fileName,~]=fileparts(resolvedRptFileName);



            resolvedRptFileName=[fileName,'.pdf'];
            if~isempty(path)
                resolvedRptFileName=fullfile(path,resolvedRptFileName);
            end
            if exist(resolvedRptFileName,'file')
                delete(resolvedRptFileName);
            end
        end
    else
        resolvedRptFileName=[];
    end

    [rptCreated,rptFileName]=Sldv.ReportUtils.generate(sldvData,{'usesldvoptions'},...
    obj.mShowUI,resolvedRptFileName,format);
    if rptCreated
        if strcmp(format,'-fHTML')
            fileNames.Report=rptFileName;
        else
            fileNames.PDFReport=rptFileName;
        end
        obj.logAll(obj.html_spaced_label_val(getString(message('Sldv:SldvRun:Report')),rptFileName));
    else
        obj.logAll(getString(message('Sldv:SldvRun:NoReport')));
        if isfield(obj.mTestComp.resolvedSettings,'ReportFileName')
            obj.mTestComp.resolvedSettings=rmfield(obj.mTestComp.resolvedSettings,'ReportFileName');
        end
    end
end
