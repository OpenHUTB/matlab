function result=isComponentPlotLookupTable2DSupported(componentPath)




    result=any(strcmp(componentPath,{
    'foundation.physical_signal.lookup_tables.two_dimensional';
    'foundation.signal.lookup_tables.two_dimensional'}));
end
