function schema






    pkgLO=findpackage('rptgen_lo');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgLO,'clo_for',pkgRG.findclass('rptcomponent'));


    rptgen.makeProp(h,'LoopType',{
    'increment',getString(message('rptgen:rl_clo_for:incIndicesLabel'))
    'vector',getString(message('rptgen:rl_clo_for:vectorOfIndicesLabel'))
    },'increment',...
    getString(message('rptgen:rl_clo_for:loopTypeLabel')));


    rptgen.makeProp(h,'LoopVector','ustring','[1 2 3 4 5]',...
    getString(message('rptgen:rl_clo_for:vectorText')));


    rptgen.makeProp(h,'StartNumber','ustring','1',...
    getString(message('rptgen:rl_clo_for:startText')));


    rptgen.makeProp(h,'IncrementNumber','ustring','1',...
    getString(message('rptgen:rl_clo_for:incrementText')));


    rptgen.makeProp(h,'EndNumber','ustring','5',...
    getString(message('rptgen:rl_clo_for:endText')));


    rptgen.makeProp(h,'isUseVariable','bool',true,...
    getString(message('rptgen:rl_clo_for:showIndexValLabel')));


    rptgen.makeProp(h,'VariableName','ustring','RPTGEN_LOOP',...
    getString(message('rptgen:rl_clo_for:varNameLabel')));


    rptgen.makeProp(h,'isCleanup','bool',true,...
    getString(message('rptgen:rl_clo_for:cleanupOnFinishLabel')));


    rptgen.makeStaticMethods(h,{
    },{
    });