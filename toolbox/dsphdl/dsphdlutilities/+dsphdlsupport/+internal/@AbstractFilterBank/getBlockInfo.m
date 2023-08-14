function blockInfo=getBlockInfo(this,hC)






    blockInfo=struct();
    blockInfo.XILINX_MAXOUTPUT_WORDLENGTH=48;
    blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH=44;
    blockInfo.DELAYLINELIMIT2MAP2RAM=64;
    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;

        blockInfo.inMode=[true,...
        sysObjHandle.ResetInputPort];

        blockInfo.outMode=[sysObjHandle.StartOutputPort;
        sysObjHandle.EndOutputPort];

        blockInfo.Architecture=sysObjHandle.Architecture;
        blockInfo.ComplexMultiplication=sysObjHandle.ComplexMultiplication;
        blockInfo.FFTLength=sysObjHandle.FFTLength;


        blockInfo.RoundingMethod=sysObjHandle.RoundingMethod;
        blockInfo.OverflowAction=sysObjHandle.OverflowAction;
        blockInfo.Normalize=sysObjHandle.Normalize;

        blockInfo.BitReversedInput=sysObjHandle.BitReversedInput;
        blockInfo.BitReversedOutput=sysObjHandle.BitReversedOutput;

        if isa(sysObjHandle,'dsphdl.FFT')
            blockInfo.inverseFFT=false;
        else
            blockInfo.inverseFFT=true;
        end

        if sysObjHandle.Normalize
            blockInfo.BitGrowthVector=zeros(log2(sysObjHandle.FFTLength),1);
        else
            blockInfo.BitGrowthVector=ones(log2(sysObjHandle.FFTLength),1);
        end

    else

        slHandle=hC.Simulinkhandle;

        blockInfo.inMode=[true;...
        strcmpi(get_param(slHandle,'ResetInputPort'),'on')];

        blockInfo.outMode=[strcmpi(get_param(slHandle,'StartOutputPort'),'on');
        strcmpi(get_param(slHandle,'EndOutputPort'),'on')];

        blockInfo.Architecture=get_param(slHandle,'Architecture');
        blockInfo.ComplexMultiplication=get_param(slHandle,'ComplexMultiplication');

        blockInfo.RoundingMethod=get_param(slHandle,'RoundingMode');
        blockInfo.OverflowAction='Wrap';
        blockInfo.Normalize=strcmpi(get_param(slHandle,'Normalize'),'on');

        blockInfo.BitReversedInput=strcmpi(get_param(slHandle,'BitReversedInput'),'on');
        blockInfo.BitReversedOutput=strcmpi(get_param(slHandle,'BitReversedOutput'),'on');


        if strcmpi(hdlgetblocklibpath(slHandle),sprintf('dsphdlxfrm2/FFT'))
            blockInfo.inverseFFT=false;
        else
            blockInfo.inverseFFT=true;
        end
        if blockInfo.Normalize
            blockInfo.BitGrowthVector=zeros(log2(blockInfo.FFTLength),1);
        else
            blockInfo.BitGrowthVector=ones(log2(blockInfo.FFTLength),1);
        end
    end








    blockInfo.resetnone=false;

