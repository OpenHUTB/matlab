function schema




    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'crg_empty',pkgRG.findclass('rptcomponent'));



    p=rptgen.makeProp(h,'DescString','ustring');
    p.AccessFlags.Init='on';
    p.AccessFlags.PublicGet='off';
    p.FactoryValue='';


    rptgen.makeStaticMethods(h,{
    },{
    });