function schema







    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_blk_loop',pkgRG.findclass('rpt_looper'));

    lic='SIMULINK_Report_Gen';


    rptgen.prop(h,'LoopType',{
    'auto',getString(message('RptgenSL:rsl_csl_blk_loop:autoListLabel'))
    'list',getString(message('RptgenSL:rsl_csl_blk_loop:customLabel'))
    },'auto','',lic);


    rptgen.prop(h,'ObjectList','MATLAB array',{},...
    '',lic);


    rptgen.prop(h,'SortBy',{
    'alphabetical',getString(message('RptgenSL:rsl_csl_blk_loop:alphabeticalByNameLabel'))
    'systemalpha',getString(message('RptgenSL:rsl_csl_blk_loop:alphabeticalBySystemNameLabel'))
    'fullpathalpha',getString(message('RptgenSL:rsl_csl_blk_loop:alphabeticalBySLPathLabel'))
    'blocktype',getString(message('RptgenSL:rsl_csl_blk_loop:byBlockTypeLabel'))
    'depth',getString(message('RptgenSL:rsl_csl_blk_loop:byBlockDepthLabel'))
    'lefttoright',getString(message('RptgenSL:rsl_csl_blk_loop:byLayoutLTRLabel'))
    'toptobottom',getString(message('RptgenSL:rsl_csl_blk_loop:byLayoutTTBLabel'))
    'none',getString(message('RptgenSL:rsl_csl_blk_loop:byTraversalOrderLabel'))
    'runtime',getString(message('RptgenSL:rsl_csl_blk_loop:bySimulationOrderLabel'))
    },'alphabetical',getString(message('RptgenSL:rsl_csl_blk_loop:sortBlocksLabel')),lic);


    rptgen.prop(h,'isFilterList','bool',false,...
    [getString(message('RptgenSL:rsl_csl_blk_loop:searchForSLPropertiesLabel')),':'],lic);


    p=rptgen.prop(h,'FilterTerms','MATLAB array',{'BlockType','Gain'},...
    '',lic);




    p.Visible='off';




    rptgen.makeStaticMethods(h,{
    },{
'getLoopBlocks'
'loop_getDialogSchema'
'loop_getContextString'
'loop_getLoopObjects'
'loop_getPropSrc'
'loop_restoreState'
'loop_saveState'
'loop_setState'
'parseList'
'sortBlocks'
    });
