function[muxCount,readDelay,insertMuxPipelineRegister]=getMuxReadDelayCount(muxCount,readDelay,AXI4PipelineRatio)




    if(AXI4PipelineRatio>0)
        muxCount=muxCount+1;
    end


    if((mod(muxCount,AXI4PipelineRatio)==0)&&(AXI4PipelineRatio>0))
        readDelay=readDelay+1;
        insertMuxPipelineRegister=1;
    else
        insertMuxPipelineRegister=0;
    end

end
