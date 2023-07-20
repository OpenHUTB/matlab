function checkBoxState=simulateWithDelay()





    blockPath=gcb;
    if FunctionApproximation.internal.approximationblock.isCreatedByFunctionApproximation(blockPath)
        currentString=get_param(blockPath,'AttributesFormatString');
        latencyString='Latency:%<Latency>';
        if~contains(currentString,latencyString)
            if isempty(currentString)
                newString=[latencyString,'\n'];
            else
                newString=[currentString,'\n',latencyString,'\n'];
            end
            set_param(blockPath,'AttributesFormatString',newString)
        end
        schema=FunctionApproximation.internal.approximationblock.BlockSchema();
        approximatePath=schema.getNameForApproximate(blockPath,1);
        delayHandles=Simulink.findBlocksOfType(approximatePath,'Delay');
        checkBoxState=get_param(gcb,schema.SimulateWithDelayParameterName);
        originalPath=schema.getNameForOriginal(blockPath);
        delayHandles=[delayHandles;Simulink.findBlocksOfType(originalPath,'Delay')];
        if strcmp(checkBoxState,'on')
            FunctionApproximation.internal.datatomodeladapter.HDLLUTModelInfo.setCommentState(delayHandles,'off');
            set_param(blockPath,'Latency',get_param(blockPath,'simulationLatency'));
        else
            FunctionApproximation.internal.datatomodeladapter.HDLLUTModelInfo.setCommentState(delayHandles,'through');
            set_param(blockPath,'Latency','0');
        end
    end
end
