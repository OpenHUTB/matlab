function report=convertToSingle(selectedSystemToScale)














    if nargin>0
        selectedSystemToScale=convertStringsToChars(selectedSystemToScale);
    end

    eng=DataTypeWorkflow.Single.Engine.getInstance;

    report=eng.run(selectedSystemToScale);
end
