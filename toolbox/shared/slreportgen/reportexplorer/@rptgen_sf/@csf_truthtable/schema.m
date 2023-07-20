function schema









    pkg=findpackage('rptgen_sf');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csf_truthtable',pkgRG.findclass('rptcomponent'));

    lic='SIMULINK_Report_Gen';


    p=rptgen.prop(h,'TitleMode',{
    'none',getString(message('RptgenSL:rsf_csf_truthtable:noTitleLabel'))
    'auto',getString(message('RptgenSL:rsf_csf_truthtable:useSFNameLabel'))
    'manual',[getString(message('RptgenSL:rsf_csf_truthtable:customLabel')),':']
    },'none',...
    getString(message('RptgenSL:rsf_csf_truthtable:titleLabel')),lic);


    p=rptgen.prop(h,'Title',rptgen.makeStringType,getString(message('RptgenSL:rsf_csf_truthtable:truthTableLabel')),...
    '',lic);


    p=rptgen.prop(h,'ShowConditionHeader','bool',false,...
    getString(message('RptgenSL:rsf_csf_truthtable:showHeaderLabel')),lic);


    p=rptgen.prop(h,'ShowConditionNumber','bool',false,...
    getString(message('RptgenSL:rsf_csf_truthtable:showNumberLabel')),lic);


    p=rptgen.prop(h,'ShowConditionCode','bool',false,...
    getString(message('RptgenSL:rsf_csf_truthtable:showConditionLabel')),lic);


    p=rptgen.prop(h,'ShowConditionDescription','bool',true,...
    getString(message('RptgenSL:rsf_csf_truthtable:showDescriptionLabel')),lic);


    p=rptgen.prop(h,'ConditionWrapLimit','int32',20,...
    getString(message('RptgenSL:rsf_csf_truthtable:wrapIfColumnCountGreaterThanLabel')),lic);


    p=rptgen.prop(h,'ShowActionHeader','bool',false,...
    getString(message('RptgenSL:rsf_csf_truthtable:showHeaderLabel')),lic);


    p=rptgen.prop(h,'ShowActionNumber','bool',true,...
    getString(message('RptgenSL:rsf_csf_truthtable:showNumberLabel')),lic);


    p=rptgen.prop(h,'ShowActionCode','bool',true,...
    getString(message('RptgenSL:rsf_csf_truthtable:showActionLabel')),lic);


    p=rptgen.prop(h,'ShowActionDescription','bool',false,...
    getString(message('RptgenSL:rsf_csf_truthtable:showDescriptionLabel')),lic);








    p=rptgen.prop(h,'RuntimeTruthTable','mxArray',[],...
    '',2);


    rptgen.makeStaticMethods(h,{
'makeConditionCells'
'makeActionCells'
'findTruthTables'
    },{
'makeTable'
    });
