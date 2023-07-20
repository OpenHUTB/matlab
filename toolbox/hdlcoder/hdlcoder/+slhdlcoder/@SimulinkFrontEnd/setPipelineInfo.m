function setPipelineInfo(~,hC,impl)



    ipl=impl.getImplParams('InputPipeline');
    opl=impl.getImplParams('OutputPipeline');
    cpl=impl.getImplParams('ConstrainedOutputPipeline');

    isPipelineAtInput=(~isempty(ipl)&&isnumeric(ipl)&&ipl>0&&floor(ipl)==ipl);
    isPipelineAtOutput=(~isempty(opl)&&isnumeric(opl)&&opl>0&&floor(opl)==opl);
    isConstrainedPipelineAtOutput=(~isempty(cpl)&&isnumeric(cpl)&&cpl>0&&floor(cpl)==cpl);

    if(isPipelineAtInput)
        hC.setInputPipeline(ipl);
    end

    if(isPipelineAtOutput)
        hC.setOutputPipeline(opl);
    end

    if(isConstrainedPipelineAtOutput)
        hC.setConstrainedOutputPipeline(cpl);
    end


end
