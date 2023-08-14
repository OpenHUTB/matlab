function schema






    pkgLO=findpackage('rptgen_lo');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgLO,'clo_while',pkgRG.findclass('rptcomponent'));

    rptgen.makeProp(h,'EvalInitString','ustring','',...
    getString(message('rptgen:rl_clo_while:initExpressionLabel')));

    rptgen.makeProp(h,'ConditionalString','ustring','false',...
    getString(message('rptgen:rl_clo_while:loopConditionLabel')));

    rptgen.makeProp(h,'isMaxIterations','bool',true,...
    getString(message('rptgen:rl_clo_while:maxLoopsLabel')));

    rptgen.makeProp(h,'MaxIterations','double',100,'');


    rptgen.makeStaticMethods(h,{
    },{
'isTrue'
    });