function schema






    p=findpackage('Simulink');
    c=schema.class(p,'RegionInfo');


    schema.prop(c,'StartIndex','int32');
    schema.prop(c,'NumElements','int32');

