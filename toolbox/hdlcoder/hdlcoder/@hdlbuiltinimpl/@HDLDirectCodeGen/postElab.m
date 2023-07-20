function postElab(this,hN,hPreElabC,hPostElabC)


    if ishandle(hPostElabC)&&ishandle(hPreElabC)
        hPostElabC.OrigModelHandle=hPreElabC.SimulinkHandle;
    end

    if(hPreElabC==hPostElabC)
        return;
    end

    if~strcmp(hPostElabC.ClassName,'black_box_comp')

        if~ishandle(hPreElabC)
            return;
        end
        if(hPostElabC.isDelay&&~hPreElabC.isDelay&&hPreElabC.getConstrainedOutputPipeline)


            assert(length(hPostElabC.PirOutputPorts)==1);
            hPostElabC=hPostElabC.PirOutputPorts.insertBufferOnSrc;
        end

        hPostElabC.copyComment(hPreElabC);
        hPostElabC.setConstrainedOutputPipeline(hPreElabC.getConstrainedOutputPipeline);
        hPostElabC.setTargetCodeGenerationLatency(hPreElabC.getTargetCodeGenerationLatency);

        if hPreElabC.hasGeneric
            hPostElabC.copyGenericsFrom(hPreElabC);
        end

        setHasFixedSLRateParam(hPostElabC);
        p=pir(hN.getCtxName());
        p.registerAsAncestor(hPreElabC,hPostElabC);
    end

    setDelayTags(this,hPreElabC,hPostElabC);


    function setHasFixedSLRateParam(hPostElabC)

        if(ishandle(hPostElabC.OrigModelHandle))
            if(isprop(hPostElabC.OrigModelHandle,'SampleTime'))
                if(slResolve(get_param(hPostElabC.OrigModelHandle,'SampleTime'),hPostElabC.OrigModelHandle)~=-1)
                    hPostElabC.hasFixedSLRate=true;
                end
            end
        end
