function testAttr=getTestAttributesFromModel(modelName,harnessName)







    [modelToUse,deactivateHarness,currHarness,oldHarness,~,wasHarnessOpen]=stm.internal.util.resolveHarness(modelName,harnessName);

    testAttr=string.empty();
    if getInputs(modelToUse)
        testAttr{end+1}=getString(message('stm:QuickStart:SpecsInputsID'));
    end

    if hasParameters(modelName,harnessName)
        testAttr{end+1}=getString(message('stm:QuickStart:SpecsParametersID'));
    end

    testAttr{end+1}=getString(message('stm:QuickStart:SpecsComparisonID'));


    if~isempty(currHarness)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
        end
    end

end

function bl=getInputs(modelToUse)
    bl=1;

    if isempty(Simulink.iospecification.InportProperty.getInportProperties(modelToUse))
        if isempty(Simulink.iospecification.InportProperty.getEnableProperties(modelToUse))
            bl=~isempty(Simulink.iospecification.InportProperty.getTriggerProperties(modelToUse));
        end
    end
end

function bl=hasParameters(modelName,harnessName)
    bl=~isempty(stm.internal.Parameters.getModelParameters(modelName,harnessName));
end
