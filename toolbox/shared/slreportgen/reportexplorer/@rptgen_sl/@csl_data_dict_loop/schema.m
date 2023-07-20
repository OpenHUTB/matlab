function schema




    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');
    this=schema.class(pkg,'csl_data_dict_loop',pkgRG.findclass('rpt_looper'));

    lic='SIMULINK_Report_Gen';


    rptgen.prop(this,'LoopType',{
    'auto',msg('WdgtValLoopTypeAuto')
    'list',msg('WdgtValLoopTypeList')
    },'auto','',lic);


    rptgen.prop(this,'DictionariesList','MATLAB array',{},...
    '',lic);



    rptgen.makeStaticMethods(this,{
    },{
'loop_getDialogSchema'
'loop_getContextString'
'loop_getLoopObjects'
'loop_restoreState'
'loop_saveState'
'loop_setState'
    });

    function translation=msg(key)
        translation=getString(message(['RptgenSL:csl_data_dict_loop:',key]));

