function postElab(this,hN,hPreElabC,hPostElabC)








    if hPreElabC==hPostElabC
        return;
    end

    if~strcmp(hPostElabC.ClassName,'black_box_comp')
        hPostElabC.copyComment(hPreElabC);
        hPostElabC.setConstrainedOutputPipeline(hPreElabC.getConstrainedOutputPipeline);

        if hPreElabC.hasGeneric
            hPostElabC.copyGenericsFrom(hPreElabC);
        end
    end

    setDelayTags(this,hPreElabC,hPostElabC);

end
