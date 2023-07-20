function schema













    p=findpackage('Simulink');
    c=schema.class(p,'TimeseriesArray',...
    findclass(findpackage('tsdata'),'timeseriesArray'));


    schema.prop(c,'Dataconstructor','MATLAB array');




