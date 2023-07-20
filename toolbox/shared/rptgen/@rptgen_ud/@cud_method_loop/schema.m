function schema






    pkgUD=findpackage('rptgen_ud');

    h=schema.class(pkgUD,'cud_method_loop',pkgUD.findclass('udd_loop'));


    p=rptgen.prop(h,'LoopType',{
    'auto',getString(message('rptgen:ru_cud_method_loop:autoLabel'))
    'manual',getString(message('rptgen:ru_cud_method_loop:listedLabel'))
    },'auto',...
    getString(message('rptgen:ru_cud_method_loop:showCurrentLabel')));


    p=rptgen.prop(h,'ReportedMethods','string vector',{},'');


    p=rptgen.prop(h,'UddType',rptgen_ud.enumObjectTypeAuto,'auto',...
    getString(message('rptgen:ru_cud_method_loop:loopOnCurrentLabel')));

    p=rptgen.prop(h,'LocalMethodsOnly','bool',logical(0),...
    getString(message('rptgen:ru_cud_method_loop:ignoreInheritedLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'loop_getContextString'
'loop_getDialogSchema'
'loop_getLoopObjects'
'loop_getPropSrc'
    });