function hNewInstance=elaborate(this,hN,hC)


    [readNewData,RAMDirective]=getBlockInfo(this,hC);
    ramName='SinglePortRAM';
    [~,hNewInstance]=pirelab.getSinglePortRamComp(hN,hC.PirInputSignals,...
    hC.PirOutputSignals,ramName,1,readNewData,hC.SimulinkHandle,'',RAMDirective);
end

function[readNewData,RAMDirective]=getBlockInfo(this,hC)
    if strcmp(get_param(hC.SimulinkHandle,'dout_type'),'New data')
        readNewData=true;
    else
        readNewData=false;
    end
    RAMDirective=getImplParams(this,'RAMDirective');
end


