function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_mdl_sim',...
    pkgRG.findclass('rptcomponent'));

    lic='SIMULINK_Report_Gen';


    p=rptgen.prop(h,'UseMdlIOParam','bool',true,...
    getString(message('RptgenSL:rsl_csl_mdl_sim:useModelIOVariableNamesLabel')),lic);


    p=rptgen.prop(h,'TimeOut','ustring','T',...
    getString(message('RptgenSL:rsl_csl_mdl_sim:timeLabel')),lic);


    p=rptgen.prop(h,'StatesOut','ustring','X',...
    getString(message('RptgenSL:rsl_csl_mdl_sim:statesLabel')),lic);


    p=rptgen.prop(h,'MatrixOut','ustring','Y',...
    getString(message('RptgenSL:rsl_csl_mdl_sim:outputLabel')),lic);


    p=rptgen.prop(h,'UseMdlTimespan','bool',true,...
    getString(message('RptgenSL:rsl_csl_mdl_sim:useModelTimespanLabel')));


    p=rptgen.prop(h,'StartTime','ustring','0',...
    getString(message('RptgenSL:rsl_csl_mdl_sim:startLabel')),lic);


    p=rptgen.prop(h,'EndTime','ustring','60',...
    getString(message('RptgenSL:rsl_csl_mdl_sim:stopLabel')),lic);


    p=rptgen.prop(h,'MessageDisplay',{
    'screen',getString(message('RptgenSL:rsl_csl_mdl_sim:displayToCommandLineLabel'))
    'msglist',getString(message('RptgenSL:rsl_csl_mdl_sim:displayToMessageListLabel'))
    'report',getString(message('RptgenSL:rsl_csl_mdl_sim:insertIntoReportLabel'))
    },'screen',getString(message('RptgenSL:rsl_csl_mdl_sim:simulationStatusMessageLabel')),lic);



    p=rptgen.prop(h,'SimParam','MATLAB array',{},...
    getString(message('RptgenSL:rsl_csl_mdl_sim:simulationParametersLabel')),lic);
    p.Visible='off';


    p=rptgen.prop(h,'CompileModel','bool',false,...
    getString(message('RptgenSL:rsl_csl_mdl_sim:preCompileLabel')),lic);


    rptgen.makeStaticMethods(h,{
    },{
'makeOptionStruct'
'preSimulateAction'
'postSimulateAction'
'dlgIOParameters'
'dlgTimespan'
'dlgSimOpt'
    });
