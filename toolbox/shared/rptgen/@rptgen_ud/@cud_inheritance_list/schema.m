function schema






    pkg=findpackage('rptgen_ud');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cud_inheritance_list',pkgRG.findclass('rptcomponent'));


    p=rptgen.makeProp(h,'ListType',{
    'methods',getString(message('rptgen:ru_cud_inheritance_list:methodsLabel'))
    'properties',getString(message('rptgen:ru_cud_inheritance_list:propertiesLabel'))
    },'methods',...
    getString(message('rptgen:ru_cud_inheritance_list:displayInListLabel')));


    p=rptgen.makeProp(h,'ShowLocal','bool',logical(0),...
    getString(message('rptgen:ru_cud_inheritance_list:showLocalNonInheritedMPLabel')));


    p=rptgen.makeProp(h,'ShowInherited','bool',logical(1),...
    getString(message('rptgen:ru_cud_inheritance_list:showLocalInheritedMPLabel')));


    rptgen.makeStaticMethods(h,{
    },{
    });