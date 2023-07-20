function schema




    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    lic='SIMULINK_Report_Gen';

    this=schema.class(pkg,'csl_ws_variable',pkgRG.findclass('rpt_var_display'));


    rptgen.prop(this,'PropSrc','MATLAB array',[],msg('WdgtLblPropSrc'));


    rptgen.prop(this,'Variables','MATLAB array',[],msg('WdgtLblVars'));

    rptgen.prop(this,'ShowUsedByBlocks','bool',true,...
    msg('WdgtLblShowUsedBy'),lic);

    rptgen.prop(this,'ShowWorkspace','bool',true,...
    msg('WdgtLblShowWorkspace'),lic);

    rptgen.prop(this,'acceptedProps','MATLAB array',{});
    rptgen.prop(this,'filteredProps','MATLAB array',{});
    rptgen.prop(this,'filteredPropHash','MATLAB array',{});
    rptgen.prop(this,'currFilterClass','ustring','');
    rptgen.prop(this,'customFilteringEnabled','bool',false,msg('customFilterToggleLabel'));
    rptgen.prop(this,'customFilteringCode','ustring',getString(message('rptgen:rpt_var_display:PropertyFilterCodeDefault')),...
    getString(message('rptgen:rpt_var_display:PropertyFilterCodeLabel')));



    rptgen.makeStaticMethods(this,{
    },{
'getDisplayName'
'getDisplayValue'
    });

    function translation=msg(key)
        translation=getString(message(['RptgenSL:csl_ws_variable:',key]));