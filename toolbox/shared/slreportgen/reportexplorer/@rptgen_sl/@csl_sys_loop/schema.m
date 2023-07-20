function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_sys_loop',pkgRG.findclass('rpt_looper'));

    lic='SIMULINK_Report_Gen';


    rptgen.prop(h,'HierarchicalSectionNumbering','bool',false,...
    getString(message('RptgenSL:rsl_csl_sys_loop:numberBySystemHierarchyLabel')),lic);


    rptgen.prop(h,'LoopType',{
    'auto',getString(message('RptgenSL:rsl_csl_sys_loop:autoSelectSystemsLabel'))
    'list',getString(message('RptgenSL:rsl_csl_sys_loop:customLabel'))
    },'auto',getString(message('RptgenSL:rsl_csl_sys_loop:loopOnSystemsLabel')),lic);


    rptgen.prop(h,'ObjectList','MATLAB array',{'%<gcs>'},...
    '',lic);


    rptgen.prop(h,'SortBy',{
    'numBlocks',getString(message('RptgenSL:rsl_csl_sys_loop:byNumberOfBlocksLabel'))
    'systemalpha',getString(message('RptgenSL:rsl_csl_sys_loop:alphabeticallyBySystemNameLabel'))
    'depth',getString(message('RptgenSL:rsl_csl_sys_loop:byDepthLabel'))
    'none',getString(message('RptgenSL:rsl_csl_sys_loop:byTraversalOrderLabel'))
    },'systemalpha',getString(message('RptgenSL:rsl_csl_sys_loop:sortSystemsLabel')),lic);


    rptgen.prop(h,'isFilterList','bool',false,...
    [getString(message('RptgenSL:rsl_csl_sys_loop:searchForLabel')),':'],lic);






    rptgen.prop(h,'IncludeSLFunctions','bool',true,...
    getString(message('RptgenSL:rsl_csl_sys_loop:includeSLFuncLabel')),lic);


    p=rptgen.prop(h,'FilterTerms','MATLAB array',{'MaskType','.+'},...
    '',lic);




    p.Visible='off';



    rptgen.makeStaticMethods(h,{
    },{
'loop_getContextString'
'loop_getLoopObjects'
'loop_getPropSrc'
'loop_restoreState'
'loop_saveState'
'loop_setState'
'dlgSectionOptions'
'loop_makeSection'
    });
