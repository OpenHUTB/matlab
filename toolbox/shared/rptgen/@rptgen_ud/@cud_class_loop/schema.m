function schema






    pkgUD=findpackage('rptgen_ud');

    h=schema.class(pkgUD,'cud_class_loop',pkgUD.findclass('udd_loop'));


    p=rptgen.prop(h,'LoopType',{
    'auto',getString(message('rptgen:ru_cud_class_loop:autoFromContextLabel'))
    'manual',[getString(message('rptgen:ru_cud_class_loop:customClassListLabel')),':']
    },'auto',...
    getString(message('rptgen:ru_cud_class_loop:loopEnabledLabel')));


    p=rptgen.prop(h,'ClassList','string vector',{'hg.figure','hg.axes'},'');


    rptgen.makeStaticMethods(h,{
    },{
'loop_getContextString'
'loop_getDialogSchema'
'loop_getLoopObjects'
'loop_getPropSrc'
    });
