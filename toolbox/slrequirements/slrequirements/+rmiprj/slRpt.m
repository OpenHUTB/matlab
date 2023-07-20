function slRpt(fullPath)



    [mdlDir,name,ext]=fileparts(fullPath);
    domain='';
    if any(strcmp(ext,{'.mdl','.slx'}))
        domain='sl';
        prefix='_requirements.html';
    elseif strcmp(ext,'.m')
        domain='ml';
        prefix='_rmiml.html';
    elseif strcmp(ext,'.sldd')
        domain='dd';
        prefix='_rmide.html';
    elseif strcmp(ext,'.mldatx')
        domain='tm';
        prefix='_rmitm.html';
    else
        prefix='_SLRefReport.html';
    end


    expectedRptPath=fullfile(mdlDir,[name,prefix]);
    if exist(expectedRptPath,'file')==2
        web(expectedRptPath);
        return;
    end


    rmiRptDir=rmiprj.getRptFolder();
    rptSubDir=fullfile(rmiRptDir,[domain,'rpt']);
    expectedRptPath=fullfile(rptSubDir,[name,prefix]);
    if exist(expectedRptPath,'file')==2
        web(expectedRptPath);
        return;
    end


    expectedRptPath=fullfile(pwd,[name,prefix]);
    if exist(expectedRptPath,'file')==2
        web(expectedRptPath);
        return;
    end


    reply=questdlg({...
    getString(message('Slvnv:rmiml:TraceabilityReportNotFound',[name,ext])),...
    getString(message('Slvnv:rmiml:TraceabilityReportGenerateNow'))},...
    getString(message('Slvnv:rmiml:TraceabilityReportSimulink')),...
    getString(message('Slvnv:rmiml:Yes')),...
    getString(message('Slvnv:rmiml:No')),...
    getString(message('Slvnv:rmiml:Yes')));
    if strcmp(reply,getString(message('Slvnv:rmiml:Yes')))
        if exist(rptSubDir,'dir')~=7
            mkdir(rptSubDir);
        end
        switch domain
        case 'sl'
            origDir=pwd;
            cd(rptSubDir);
            load_system(fullPath);
            rmi.reqReport(name);
            cd(origDir);
        case 'ml'
            rmiml.reqReport(fullPath,rptSubDir);
        case 'dd'
            rmide.reqReport(fullPath,rptSubDir);
        case 'tm'
            rmitm.reqReport(fullPath,rptSubDir);
        otherwise
            rmiref.checkDoc(fullPath);
        end
    end

end
