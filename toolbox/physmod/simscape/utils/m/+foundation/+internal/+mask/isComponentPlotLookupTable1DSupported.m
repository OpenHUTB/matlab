function result=isComponentPlotLookupTable1DSupported(componentPath)




    result=any(strcmp(componentPath,{
    'foundation.physical_signal.lookup_tables.one_dimensional';
    'foundation.signal.lookup_tables.one_dimensional'}));
end
