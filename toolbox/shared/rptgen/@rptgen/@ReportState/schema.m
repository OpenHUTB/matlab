function schema




    pkg=findpackage('rptgen');

    h=schema.class(pkg,...
    'ReportState');


    p=schema.prop(h,'Language','ustring');

    p=schema.prop(h,'Debug','MATLAB array');

    p=schema.prop(h,'ReportComponent','handle');

    p=schema.prop(h,'DestroyedListener','handle');
    p.Visible='off';
