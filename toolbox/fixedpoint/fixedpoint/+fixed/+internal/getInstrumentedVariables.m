function[instrumentedVariables,CompilationReport]=getInstrumentedVariables(key)




    results=fixed.internal.InstrumentationManager.getResults(key,'getInstrumentedVariables');
    opts=fixed.internal.getDefaultInstrumentationOptions();
    [CompilationReport,instrumentedVariables]=fixed.internal.processInstrumentedMxInfoLocations(results,opts);


end
