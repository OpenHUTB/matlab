function schema






    pkgSF=findpackage('rptgen_sf');
    pkgDA=findpackage('RptgenDA');

    h=schema.class(pkgSF,'CDialogSnapshot',pkgDA.findclass('RptDialogSnapshot'));



    rptgen.makeStaticMethods(h,{
    },{
    });


