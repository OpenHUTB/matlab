function schema






    pkgLO=findpackage('rptgen_lo');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgLO,'rpt_if_comp',pkgRG.findclass('rptcomponent'));


    rptgen.prop(h,'TrueText','ustring','',...
    getString(message('rptgen:rl_rpt_if_comp:insertOnEmptyLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'getTrueTextOutlineString'
'qe_if_test'
    });