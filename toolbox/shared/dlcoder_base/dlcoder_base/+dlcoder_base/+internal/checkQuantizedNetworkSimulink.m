function checkQuantizedNetworkSimulink(net,ctx)






    buildWorkflow=dlcoder_base.internal.getBuildWorkflow(ctx);
    assert(~isempty(net));
    map=deep.internal.quantization.getQuantizationInfoComposite(net);
    if(~isempty(map))&&(strcmpi(buildWorkflow,'simulink')||strcmpi(buildWorkflow,'simulation'))

        if dlcoderfeature("QulNetInSL")==0
            error(message('dlcoder_spkg:simulink:SimulinkNotSupportQuantizedNet'));
        end
    end

end

