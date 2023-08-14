function v=baseValidateRetimingCompatibility(~,hN,hC)



    v=hdlvalidatestruct;

    if hN.getDistributedPipelining||hC.getConstrainedOutputPipeline
        v=hdlvalidatestruct(2,...
        message('hdlcoder:validate:illegalBlockInDistPipe'));
    end
