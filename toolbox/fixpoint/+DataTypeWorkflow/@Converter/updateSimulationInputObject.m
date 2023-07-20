function simIn=updateSimulationInputObject(this,simIn)





    try
        simIn.validate;
    catch







        analyzerReport=this.getAnalyzerReport;
        unsupportedConstructs=DataTypeWorkflow.Advisor.internal.utils.Utils.getUnsupportedConstructs(analyzerReport);
        if~isempty(unsupportedConstructs)
            simIn=DataTypeWorkflow.Utils.updateSimulationInputObject(simIn,unsupportedConstructs);
        end
    end
end
