function schema






    pkgLO=findpackage('rptgen_lo');

    h=schema.class(pkgLO,'clo_if',pkgLO.findclass('rpt_if_comp'));


    rptgen.makeProp(h,'ConditionalString','ustring','true',...
    getString(message('rptgen:rl_clo_if:testExpressionLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'isTrue'
    });