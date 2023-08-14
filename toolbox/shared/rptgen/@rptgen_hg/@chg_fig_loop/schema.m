function schema






    pkg=findpackage('rptgen_hg');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'chg_fig_loop',pkgRG.findclass('rpt_looper'));


    p=rptgen.prop(h,'LoopType',{
    'CURRENT',getString(message('rptgen:rh_chg_fig_loop:currentOnlyLabel'))
    'ALL',getString(message('rptgen:rh_chg_fig_loop:visibleFiguresLabel'))
    'TAG',getString(message('rptgen:rh_chg_fig_loop:taggedFiguresLabel'))
    },'CURRENT',getString(message('rptgen:rh_chg_fig_loop:includeFiguresLabel')));


    p=rptgen.prop(h,'isDataFigureOnly','bool',true,...
    getString(message('rptgen:rh_chg_fig_loop:figuresOnlyLabel')));


    p=rptgen.prop(h,'UseRegexp','bool',true,...
    getString(message('rptgen:rh_chg_fig_loop:regularExpressionLabel')));


    p=rptgen.prop(h,'TagList','string vector',{});




    rptgen.makeStaticMethods(h,{
    },{
'loop_getDialogSchema'
'loop_getContextString'
'loop_getLoopObjects'
'loop_getPropSrc'
'loop_restoreState'
'loop_saveState'
'loop_setState'
    });
