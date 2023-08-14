function schema






    pkg=findpackage('rptgen_hg');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'chg_obj_loop',pkgRG.findclass('rpt_looper'));


    p=rptgen.prop(h,'IncludeHidden',{
    'findobj',getString(message('rptgen:rh_chg_obj_loop:loopOnVisibleLabel'))
    'findall',getString(message('rptgen:rh_chg_obj_loop:loopOnAllLabel'))
    },'findobj','');


    p=rptgen.prop(h,'ExcludeGUI','bool',logical(1),...
    getString(message('rptgen:rh_chg_obj_loop:excludeGUILabel')));


    p=rptgen.prop(h,'SearchTerms','string vector',{},...
    getString(message('rptgen:rh_chg_obj_loop:searchForLabel')));




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
