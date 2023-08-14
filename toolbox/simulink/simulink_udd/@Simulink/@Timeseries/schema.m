function schema



    p=findpackage('tsdata');
    c=schema.class(findpackage('Simulink'),'Timeseries',...
    findclass(p,'timeseries'));
    schema.prop(c,'BlockPath','string');
    schema.prop(c,'PortIndex','MATLAB array');
    schema.prop(c,'SignalName','string');
    schema.prop(c,'ParentName','string');
    schema.prop(c,'RegionInfo','handle');
    schema.prop(c,'ValueDimensions','MATLAB array');
