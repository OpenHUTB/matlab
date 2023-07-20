function schema





    pkgDA=findpackage('RptgenDA');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgDA,'RptDialogSnapshot',pkgRG.findclass('rpt_graphic'));


    rptgen.prop(h,'ImageFormat',{
    'auto',getString(message('rptgen:RptDialogSnapshot:Auto'))
    'bmp',getfield(imformats('bmp'),'description')
    'tif',getfield(imformats('tif'),'description')
    'png',getfield(imformats('png'),'description')
    'jpg',getfield(imformats('jpg'),'description')
    },'auto',...
    getString(message('rptgen:RptDialogSnapshot:ImageFormat')));%#ok

    rptgen.prop(h,'CaptureTabs','bool',true,...
    getString(message('rptgen:RptDialogSnapshot:ShowAllTabs')));

    rptgen.prop(h,'TimeDelay','double',0.4,...
    getString(message('rptgen:RptDialogSnapshot:DelayTime')));



    rptgen.makeStaticMethods(h,{
    },{
'traverseTabs'
'captureDialog'
'gr_getFileName'
'gr_getIntrinsicSize'
    });


















