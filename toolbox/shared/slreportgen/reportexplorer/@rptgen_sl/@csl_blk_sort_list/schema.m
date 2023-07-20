function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_blk_sort_list',pkgRG.findclass('rptcomponent'));


    p=rptgen.prop(h,'ListTitleMode',rptgen.enumAutoManual,'auto',...
    getString(message('RptgenSL:rsl_csl_blk_sort_list:listTitleLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'ListTitle',rptgen.makeStringType,'',...
    '','SIMULINK_Report_Gen');





    p=rptgen.prop(h,'isBlockType','bool',true,...
    getString(message('RptgenSL:rsl_csl_blk_sort_list:includeTypeInfoLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'FollowNonVirtual',{
    'on',getString(message('RptgenSL:rsl_csl_blk_sort_list:onLabel'))
    'off',getString(message('RptgenSL:rsl_csl_blk_sort_list:offLabel'))
    'auto',getString(message('RptgenSL:rsl_csl_blk_sort_list:autoLabel'))
    },'auto',getString(message('RptgenSL:rsl_csl_blk_sort_list:lookUnderConcreteLabel')),'SIMULINK_Report_Gen');






    rptgen.makeStaticMethods(h,{
    },{
    });
