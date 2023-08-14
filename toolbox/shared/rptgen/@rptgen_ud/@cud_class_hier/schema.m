function schema






    pkg=findpackage('rptgen_ud');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cud_class_hier',...
    pkgRG.findclass('rpt_list'));


    p=rptgen.makeProp(h,'TreeType',{
    'package',getString(message('rptgen:ru_class_hier:packageClassesLabel'))
    'class',getString(message('rptgen:ru_class_hier:classParentsLabel'))
    'auto',getString(message('rptgen:ru_class_hier:autoLabel'))
    },'auto',...
    getString(message('rptgen:ru_class_hier:treeSourceLabel')));





    rptgen.makeStaticMethods(h,{
    },{
'list_getContent'
    });