function schema





    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');
    this=schema.class(pkg,'csl_ws_var_loop',pkgRG.findclass('rpt_looper'));

    lic='SIMULINK_Report_Gen';


    rptgen.prop(this,'LoopType',{
    'auto',msg('WdgtValLoopTypeAuto')
    'list',msg('WdgtValLoopTypeList')
    },'auto','',lic);


    rptgen.prop(this,'SortBy',{
    'alpha',msg('WdgtValSortByAlpha')
    'datatype',msg('WdgtValSortByDataType')
    },'alpha',msg('WdgtLblSortBy'),lic);


    rptgen.prop(this,'isFilterList','bool',false,...
    [msg('WdgtLblIsFilterList'),':'],lic);


    rptgen.prop(this,'FilterTerms','MATLAB array',{'Name','.+'},'',lic);


    rptgen.makeStaticMethods(this,{
    },{
'loop_getContextString'
'loop_getLoopObjects'
'loop_getPropSrc'
'loop_restoreState'
'loop_saveState'
'loop_setState'
    });

    function translation=msg(key)
        translation=getString(message(['RptgenSL:csl_ws_var_loop:',key]));
