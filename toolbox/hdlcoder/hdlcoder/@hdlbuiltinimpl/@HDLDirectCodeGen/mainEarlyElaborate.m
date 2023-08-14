function mainEarlyElaborate(this,hN,hC)

























    if elaborateInPhase1(this,hN,hC)

        hPreElabC=preElab(this,hN,hC);



        numInPipes=hPreElabC.getInputPipeline;
        numOutPipes=hPreElabC.getOutputPipeline;
        hPreElabC.insertPipelinePlaceholders;

        hPostElabC=elaborate(this,hN,hPreElabC);

        postElab(this,hN,hPreElabC,hPostElabC);

        if ishandle(hPostElabC)
            hPostElabC.setRequestedInputPipeline(numInPipes);
            hPostElabC.setRequestedOutputPipeline(numOutPipes);
        end

        setPseudoElabSettings(this,hN,hPreElabC,hPostElabC);
    else
        lat=getTotalCompLatency(this,hC);

        if lat.outputDelay>0
            hC.setHasInternalPipelineDelay(lat.outputDelay);
        end

        oversam=getMaxOversampling(this,hC);
        if oversam>0
            hC.setMaxOversampling(oversam);
        end

        usesSLBH=usesSimulinkHandleForModelGen(this,hN,hC);
        hC.setUsesSimulinkHandleForModelGen(usesSLBH);
        hC.setPotentiallyInsertsPipelines(getPotentiallyInsertsPipelines(this,hC));
    end
end

function yes=elaborateInPhase1(this,hN,hC)

    yes=false;

    if hasDesignDelay(this,hN,hC)
        yes=true;
    end

    if mustElaborateInPhase1(this,hN,hC)
        yes=true;
    end

    if isAdaptivePipeliningCompatible(this,hC)
        yes=true;
    end
end



