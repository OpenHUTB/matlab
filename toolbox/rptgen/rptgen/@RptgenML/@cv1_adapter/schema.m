function schema






    pkgRG=findpackage('rptgen');
    pkg=findpackage('RptgenML');

    h=schema.class(pkg,'cv1_adapter',pkgRG.findclass('rptcomponent'));


    p=rptgen.prop(h,'OldComponent','MATLAB array',[]);
    p.Visible='off';
