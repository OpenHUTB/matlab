function schema





    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_sys_list',...
    pkgRG.findclass('rpt_list'));

    lic='SIMULINK_Report_Gen';


    rptgen.prop(h,'StartSys',{
    'fromloop',getString(message('RptgenSL:rsl_csl_sys_list:currentSystemLabel'))
    'top',getString(message('RptgenSL:rsl_csl_sys_list:currentModelLabel'))
    },'fromloop',getString(message('RptgenSL:rsl_csl_sys_list:buildListFromLabel')),lic);


    rptgen.prop(h,'HighlightStartSys','bool',true,...
    getString(message('RptgenSL:rsl_csl_sys_list:emphasizeCurrentSystemLabel')));


    rptgen.prop(h,'isPeers','bool',true,...
    getString(message('RptgenSL:rsl_csl_sys_list:displayCurrentSystemPeersLabel')),lic);


    rptgen.prop(h,'ParentDepth','int32',1,...
    getString(message('RptgenSL:rsl_csl_sys_list:showNumberParentsLabel')),lic);


    rptgen.prop(h,'ChildDepth','int32',1,...
    getString(message('RptgenSL:rsl_csl_sys_list:showChildrenToDepthLabel')),lic);


    rptgen.makeStaticMethods(h,{
    },{
'list_getContent'
    });
