function title=sectionTitle(option)




    switch option
    case 'contents'
        title=getString(message('Slvnv:rmiml:ProjectContents'));
    case 'data'
        title=getString(message('Slvnv:rmiml:RptLabelSectionDataDict'));
    case 'ddlinksection'
        title=getString(message('Slvnv:RptgenRMI:getType:DDReqSection'));
    case 'doctable'
        title=getString(message('Slvnv:RptgenRMI:NoReqDoc:getName:RequirementsDocumentsTable'));
    case 'info'
        title=getString(message('Slvnv:rmiml:RptLabelGeneralInfo'));
    case 'matlab'
        title=getString(message('Slvnv:rmiml:RptLabelSectionMatlab'));
    case 'mllinksection'
        title=getString(message('Slvnv:RptgenRMI:getType:MlReqSection'));
    case 'nolinks'
        title=getString(message('Slvnv:rmiml:RptLabelSectionNone'));
    case 'other'
        title=getString(message('Slvnv:rmiml:RptLabelSectionOther'));
    case 'simulink'
        title=getString(message('Slvnv:rmiml:RptLabelSectionSimulink'));
    case 'subtitle'
        title=getString(message('Slvnv:rmiml:ProjRptSubtitle',rmiprj.currentProject('name')));
    case 'test'
        title=getString(message('Slvnv:rmiml:RptLabelSectionTestFile'));
    case 'title'
        title=getString(message('Slvnv:rmiml:ProjRptTitle',rmiprj.currentProject('name')));
    case 'tmlinksection'
        title=getString(message('Slvnv:RptgenRMI:getType:TMReqSection'));
    otherwise
        filename=option;
        [fDir,fName,fExt]=fileparts(filename);
        if any(strcmp(fExt,{'.m','.sldd','.mldatx'}))
            title=getString(message('Slvnv:rmiml:MlRptTitle',[fName,fExt]));
        elseif strcmp(fExt,'._links_')
            sourceFile=fullfile(fDir,fName);
            linksFile=slreq.map(sourceFile);
            title=getString(message('Slvnv:rmiml:ReqDataFrom',linksFile));
        elseif strcmp(fExt,'._nolinks_')
            sourceFile=fullfile(fDir,fName);
            linksFile=slreq.map(sourceFile);
            title=getString(message('Slvnv:RptgenRMI:option:NoLinksIn',linksFile));
        else
            title=getString(message('Slvnv:rmiml:ReqDataFrom',filename));
        end
    end
end