function schema






    pkgRG=findpackage('rptgen');
    h=schema.class(pkgRG,'cfr_image',pkgRG.findclass('rpt_graphic'));


    rptgen.prop(h,'isTitle',{
    'none',getString(message('rptgen:r_cfr_image:noneLabel'))
    'filename',getString(message('rptgen:r_cfr_image:filenameLabel'))
    'local',getString(message('rptgen:r_cfr_image:customLabel'))
    },'none',getString(message('rptgen:r_cfr_image:titleLable')));


    rptgen.prop(h,'FileName','ustring','ngc6543a.jpg',...
    getString(message('rptgen:r_cfr_image:filenameLabel')),1);


    rptgen.prop(h,'isCopyFile','bool',true,...
    getString(message('rptgen:r_cfr_image:makeCopyLabel')));

    rptgen.makeStaticMethods(h,{
    },{
'gr_getTitle'
'gr_getIntrinsicSize'
'getDlgFileName'
    });
