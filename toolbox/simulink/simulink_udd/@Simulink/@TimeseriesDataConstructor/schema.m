function schema








    c=schema.class(findpackage('Simulink'),'TimeseriesDataConstructor');


    c.Handle='off';

    schema.prop(c,'Constructor','MATLAB array');
    schema.prop(c,'Data','MATLAB array');
