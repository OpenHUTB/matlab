function schema






    pkgUD=findpackage('rptgen_ud');

    h=schema.class(pkgUD,'cud_pkg_loop',pkgUD.findclass('udd_loop'));


    p=rptgen.prop(h,'LoopType',{
    'directory',getString(message('rptgen:ru_cud_pkg_loop:allPackagesLabel'))
    'manual',getString(message('rptgen:ru_cud_pkg_loop:manualLabel'))
    },'directory',...
    getString(message('rptgen:ru_cud_pkg_loop:loopEnabledLabel')));




    p=rptgen.prop(h,'DirectoryName',rptgen.makeStringType,'%<pwd>','');


    p=rptgen.prop(h,'PackageList','string vector',{},'');


    rptgen.makeStaticMethods(h,{
    },{
'loop_getContextString'
'loop_getDialogSchema'
'loop_getLoopObjects'
'loop_getPropSrc'
    });