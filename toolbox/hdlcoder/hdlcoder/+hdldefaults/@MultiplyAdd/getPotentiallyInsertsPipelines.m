function ret=getPotentiallyInsertsPipelines(this,hC)



    pipelineDepthStr=getImplParams(this,'PipelineDepth');
    if isempty(pipelineDepthStr)
        pipelineDepthStr='auto';
    end

    if strcmpi(pipelineDepthStr,'auto')
        hwModeLatency=-1;
    else
        hwModeLatency=this.getHwModeLatency(hC);
    end

    if(hwModeLatency==-1)
        ret=true;
    else
        ret=false;
    end

end
