function success=runTransforms(gp,p,addStreamingMatrixTagsToInputs)





    gp.checkDelayBalancing(true);



    gp.removeAllElabHelpers;



    ignoreElementWiseComps=true;
    p.removeMatrixReshapes(ignoreElementWiseComps);



    if addStreamingMatrixTagsToInputs
        hN=p.getTopNetwork;
        for i=1:numel(hN.PirInputPorts)
            hPort=hN.PirInputPorts(i);

            if hPort.Signal.Type.isArrayType
                hPort.getStreamingMatrixTag;
            end
        end
    end



    success=p.StreamingMatrixTransform;

    if~success
        return
    end




    applyReductionNW=streamingmatrix.processReductionComps(p);

    portInfo=streamingmatrix.getStreamedPorts(p.getTopNetwork);
    assert(isempty(portInfo.nonStreamedOutPorts),...
    'currently all outputs must be streamed in the streaming matrix workflow');


    p.doNPUSubsystemTransformation;





    streamingmatrix.postProcessReductionComps(p,applyReductionNW);


    gp.doDeadLogicElimination;


    p.doStreamingMatrixValidInsertion;


    gp.doDeadLogicElimination;


    streamingmatrix.terminateSignals(p);



    streamingmatrix.setAllShouldDraw(p);

end


