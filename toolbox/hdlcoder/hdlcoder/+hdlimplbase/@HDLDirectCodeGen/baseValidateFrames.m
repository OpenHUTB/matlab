function v=baseValidateFrames(this,hC)






















    v=hdlvalidatestruct;


    blkFrameMode=this.getBlockFrameMode;


    switch(lower(blkFrameMode))
    case 'inputproc'
        opMode=1;
    case 'rateopt'
        opMode=2;
    case 'inputprocandrateopt'
        opMode=3;
    otherwise
        opMode=1;
    end


    switch(opMode)
    case 1
        v=baseValidateFramesInputProc(this,hC);
    case 2
        v=baseValidateFramesRateOpt(this,hC);
    case 3
        v=baseValidateFramesInputProcandRateOpt(this,hC);
    end





