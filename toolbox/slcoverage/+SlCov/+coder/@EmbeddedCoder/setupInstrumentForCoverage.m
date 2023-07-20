function instrumentationUpToDate=setupInstrumentForCoverage...
    (modelName,instrumentationUpToDate,moduleName,lAnchorFolder,...
    instrumOptions)







    trDataFile=SlCov.coder.EmbeddedCoder.getCodeCovDataFilesDuringBuild...
    (moduleName,modelName,lAnchorFolder);


    if isfile(trDataFile)
        traceabilityData=codeinstrum.internal.TraceabilityData(trDataFile);
        try
            status=instrumOptions.isCompatibleWith...
            (internal.cxxfe.instrum.InstrumOptions.load(traceabilityData));
        catch
            status=false;
        end
        if status
            status=~isempty(traceabilityData.getModule(moduleName));
            delete(traceabilityData);
        else
            delete(traceabilityData);
            delete(trDataFile);
        end
    else
        status=false;
    end

    if~status
        instrumentationUpToDate=false;
    end
