function schema







    pkg=findpackage('RptgenRMI');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'CReqTable',pkgRG.findclass('rptcomponent'));


    p=rptgen.prop(h,'Source',{
    'simulink',getString(message('Slvnv:RptgenRMI:ReqTable:schema:SimulinkObject'))
    'stateflow',getString(message('Slvnv:RptgenRMI:ReqTable:schema:StateflowObject'))
    },'simulink',...
    getString(message('Slvnv:RptgenRMI:ReqTable:schema:ShowRequirementsForCurrent')));


    p=rptgen.prop(h,'TitleType',{
    'none',getString(message('Slvnv:RptgenRMI:ReqTable:schema:NoTitle'))
    'name',getString(message('Slvnv:RptgenRMI:ReqTable:schema:ObjectName'))
    'manual',['Custom',':']
    },'name',...
    getString(message('Slvnv:RptgenRMI:ReqTable:schema:TableTitle')));


    p=rptgen.prop(h,'TableTitle',rptgen.makeStringType,getString(message('Slvnv:RptgenRMI:ReqTable:schema:Requirements')),'');


    p=rptgen.prop(h,'isDescription','bool',true,...
    getString(message('Slvnv:RptgenRMI:ReqTable:schema:Description')));


    p=rptgen.prop(h,'isDoc','bool',true,...
    getString(message('Slvnv:RptgenRMI:ReqTable:schema:DocumentName')));


    p=rptgen.prop(h,'isID','bool',true,...
    getString(message('Slvnv:RptgenRMI:ReqTable:schema:LocationsWithinDocument')));


    p=rptgen.prop(h,'isKeyword','bool',false,...
    getString(message('Slvnv:RptgenRMI:ReqTable:schema:RequirementKeyword')));


    p=rptgen.prop(h,'isLinked','bool',false,...
    getString(message('Slvnv:RptgenRMI:ReqTable:schema:LinkStatus')));
    p.Visible='off';


    rptgen.makeStaticMethods(h,{
    },{
    });
