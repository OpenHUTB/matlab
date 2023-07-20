function[rndMode,ovMode,hwModeLatency,signs,nfpOptions,fused]=getBlockInfo(this,slbh,hC)



    sat=get_param(slbh,'DoSatur');
    if strcmp(sat,'on')
        ovMode='Saturate';
    else
        ovMode='Wrap';
    end

    rndMode=get_param(slbh,'RndMeth');

    pipelineDepthStr=getImplParams(this,'PipelineDepth');
    if isempty(pipelineDepthStr)
        pipelineDepthStr='auto';
    end

    if strcmpi(pipelineDepthStr,'auto')
        hwModeLatency=-1;
    else
        hwModeLatency=this.getHwModeLatency(hC);
    end


    signs=get_param(slbh,'Function');
    if(strcmp(signs,'c-(a.*b)')==1)
        signs='+-';
    elseif(strcmp(signs,'c+(a.*b)')==1)
        signs='++';
    elseif(strcmp(signs,'(a.*b)-c')==1)
        signs='-+';
    end


    nfpOptions=getNFPBlockInfo(this);

    fusedStr=get_param(slbh,'FMA');

    if strcmp(fusedStr,'on')
        fused=true;
    else
        fused=false;
    end

end


