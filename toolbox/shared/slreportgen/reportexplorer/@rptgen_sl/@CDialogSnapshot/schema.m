function schema






    pkgSL=findpackage('rptgen_sl');
    pkgDA=findpackage('RptgenDA');

    h=schema.class(pkgSL,'CDialogSnapshot',pkgDA.findclass('RptDialogSnapshot'));



    rptgen.makeStaticMethods(h,{
    },{
    });


