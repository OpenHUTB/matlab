function schema









    pkg=findpackage('RptgenRMI');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'ReqDocTable',pkgRG.findclass('rptcomponent'));


    p=rptgen.prop(h,'Source',{
    'all',getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:SimulinkAndStateflowObjects'))
    'simulink',getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:SimulinkObjects'))
    'stateflow',getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:StateflowObjects'))
    },'all',...
    getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:ShowDocumentsLinkedTo')));


    p=rptgen.prop(h,'TitleType',{
    'none',getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:NoTitle'))
    'name',getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:ModelName'))
    'manual',['Custom',':']
    },'name',...
    getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:TableTitle')));


    p=rptgen.prop(h,'TableTitle',rptgen.makeStringType,getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:RequirementsDocuments')),'');


    p=rptgen.prop(h,'checkPaths','bool',true,...
    getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:ReportUnresolvedDuplicatePaths')));


    p=rptgen.prop(h,'includeDate','bool',true,...
    getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:IncludeDocumentModificationTime')));


    p=rptgen.prop(h,'includeCount','bool',true,...
    getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:CountOfReferencesToEachDocument')));


    p=rptgen.prop(h,'useIDs','bool',false,...
    getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:ReplaceFileNamesWithDocIDs')));


    p=rptgen.prop(h,'useDOORS','bool',false,...
    getString(message('Slvnv:RptgenRMI:NoReqDoc:schema:QueryAdditionalInfoForDOORSLinks')));


    rptgen.makeStaticMethods(h,{
    },{
    });
