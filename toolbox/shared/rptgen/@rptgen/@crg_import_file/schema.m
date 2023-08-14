function schema




    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'crg_import_file',pkgRG.findclass('rpt_importer'));


    rptgen.makeProp(h,'FileName','ustring','',...
    getString(message('rptgen:r_crg_import_file:filenameLabel')));


    rptgen.makeStaticMethods(h,{
    },{
    });