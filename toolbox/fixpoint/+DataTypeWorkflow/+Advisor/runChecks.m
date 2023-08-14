function report=runChecks(selectedSystemToScale,enumWorkflow,topModel)















    if nargin>0
        selectedSystemToScale=convertStringsToChars(selectedSystemToScale);
    end

    eng=DataTypeWorkflow.Advisor.Engine.getInstance;



    if(enumWorkflow==0)
        report=eng.runSimBasedChecks(selectedSystemToScale,topModel);
    else
        report=eng.runDerivedBasedChecks(selectedSystemToScale,topModel);
    end

end
