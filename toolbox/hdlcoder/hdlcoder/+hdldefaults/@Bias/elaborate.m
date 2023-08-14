
function hBiasComp=elaborate(this,hN,hC)
    slbh=hC.SimulinkHandle;
    blkname=get_param(slbh,'Name');
    biasVal=this.getBlockDialogValue(slbh);

    saturate=strcmp(get_param(slbh,'SaturateOnIntegerOverflow'),'on');
    if saturate
        ovMode='Saturate';
    else
        ovMode='Wrap';
    end

    hBiasComp=pirelab.getBiasComp(hN,hC.PirInputSignals,hC.PirOutputSignals,biasVal,blkname,ovMode);
    return
end
