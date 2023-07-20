function schema






    pkgRG=findpackage('rptgen');

    h=schema.class(pkgRG,'rpt_name',pkgRG.findclass('rptcomponent'));

    p=rptgen.makeProp(h,'RenderAs',{
    'n',getString(message('rptgen:r_rpt_name:nameLabel'))
    't n',getString(message('rptgen:r_rpt_name:typeSpaceNameLabel'))
    't-n',getString(message('rptgen:r_rpt_name:typeDashNameLabel'))
    't:n',getString(message('rptgen:r_rpt_name:typeNameLabel'))
    },'n',...
    getString(message('rptgen:r_rpt_name:displayAsLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'name_getGenericType'
'name_getName'
'name_getObject'
'name_getPropSrc'
    });