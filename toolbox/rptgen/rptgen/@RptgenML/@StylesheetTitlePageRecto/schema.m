function schema






    pkg=findpackage('RptgenML');

    clsH=schema.class(pkg,...
    'StylesheetTitlePageRecto',...
    pkg.findclass('StylesheetTitlePage'));

    rptgen.prop(clsH,'Format','MATLAB array');


