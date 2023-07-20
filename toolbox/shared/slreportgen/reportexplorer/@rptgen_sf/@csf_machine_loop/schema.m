function schema






    pkg=findpackage('rptgen_sf');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csf_machine_loop',pkgRG.findclass('rpt_looper'));








    p=rptgen.prop(h,'isSFFilterList','bool',false,...
    getString(message('RptgenSL:rsf_csf_machine_loop:searchStateflowLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'SFFilterTerms','MATLAB array',{'Tag','MyTag'},...
    '','SIMULINK_Report_Gen');
    p.Visible='off';


    rptgen.makeStaticMethods(h,{
    },{
'loop_getContextString'
'loop_getLoopObjects'
'loop_getObjectType'
'loop_getPropSrc'
'loop_restoreState'
'loop_saveState'
'loop_setState'
    });
