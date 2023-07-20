function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_sys_filter',pkgRG.findclass('rptcomponent'));

    lic='SIMULINK_Report_Gen';


    rptgen.prop(h,'minNumBlocks','double',0,...
    getString(message('RptgenSL:rsl_csl_sys_filter:atLeastNBlocksLabel')),lic);


    rptgen.prop(h,'minNumSubSystems','double',0,...
    getString(message('RptgenSL:rsl_csl_sys_filter:atLeastNSubsystemsLabel')),lic);


    rptgen.prop(h,'isMask',{
    'yes',getString(message('RptgenSL:rsl_csl_sys_filter:maskedLabel'))
    'no',getString(message('RptgenSL:rsl_csl_sys_filter:unmaskedLabel'))
    'either',getString(message('RptgenSL:rsl_csl_sys_filter:maskedOrUnmaskedLabel'))
    },'either',getString(message('RptgenSL:rsl_csl_sys_filter:maskTypeLabel')),lic);


    rptgen.prop(h,'customFilterCode','ustring',getString(message('RptgenSL:rsl_csl_sys_filter:customFilterCodeDefault')),...
    getString(message('RptgenSL:rsl_csl_sys_filter:customFilterCodeLabel')));



    rptgen.makeStaticMethods(h,{
    },{
'isTrue'
    });
