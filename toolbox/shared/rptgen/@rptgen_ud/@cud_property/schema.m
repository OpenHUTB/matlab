function schema






    pkgUD=findpackage('rptgen_ud');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgUD,'cud_property',pkgRG.findclass('rpt_var_display'));

    p=rptgen.makeProp(h,'UddType',rptgen_ud.enumObjectTypeAuto,'auto',...
    getString(message('rptgen:ru_cud_property:typeLabel')));

    p=rptgen.makeProp(h,'PropertyName',rptgen.makeStringType,'Name',...
    getString(message('rptgen:ru_cud_property:propertyLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'getDisplayName'
'getDisplayValue'
    });