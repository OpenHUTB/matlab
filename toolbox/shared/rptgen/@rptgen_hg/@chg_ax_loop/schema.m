function schema






    pkg=findpackage('rptgen_hg');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'chg_ax_loop',pkgRG.findclass('rpt_looper'));


    p=rptgen.prop(h,'Looptype',{
    'all',getString(message('rptgen:rh_chg_ax_loop:allAxesLabel'))
    'current',getString(message('rptgen:rh_chg_ax_loop:currentAxesLabel'))
    },'all',getString(message('rptgen:rh_chg_ax_loop:loopTypeLabel')));


    p=rptgen.prop(h,'IncludeHidden',{
    'findobj',getString(message('rptgen:rh_chg_ax_loop:loopOnVisibleLabel'))
    'findall',getString(message('rptgen:rh_chg_ax_loop:loopOnAllLabel'))
    },'findobj','');


    p=rptgen.prop(h,'ExcludeSubclasses','bool',true,...
    getString(message('rptgen:rh_chg_ax_loop:excludeAxesSubclassLabel')));


    p=rptgen.prop(h,'SearchTerms','string vector',{},...
    getString(message('rptgen:rh_chg_ax_loop:searchTermsLabel')));




    p.Visible='off';





    rptgen.makeStaticMethods(h,{
    },{
'loop_getContextString'
'loop_getDialogSchema'
'loop_getLoopObjects'
'loop_getPropSrc'
'loop_restoreState'
'loop_saveState'
'loop_setState'
    });
