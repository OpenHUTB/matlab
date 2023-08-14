function latencyInfo=getHwModeLatency(this,hC)%#ok




    pipelinedepth=getImplParams(this,'PipelineDepth');


    if isempty(pipelinedepth)
        pipelinedepth='auto';
    end


    if strcmpi(pipelinedepth,'auto')
        latencyInfo=0;
        return;
    end


    latencyInfo=str2double(pipelinedepth);
    if(isnan(latencyInfo))
        latencyInfo=0;
    end


    in1signal=hC.PirInputPorts(1).Signal;
    in2signal=hC.PirInputPorts(2).Signal;
    if(hdlsignalisdouble(in1signal)||hdlsignalisdouble(in2signal))
        latencyInfo=0;
    end



