function[RAMType,readNewData,IV,numBanks,RAMDirective]=getBlockInfo(this,hC)



    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        [RAMType,readNewData,IV,RAMDirective]=getSysObjInfo(sysObjHandle);
    else
        [RAMType,readNewData,IV,RAMDirective]=getSysBlockInfo(this,hC.SimulinkHandle);
    end


    hT=hC.PirInputSignals(1).Type;
    if hT.isArrayType
        numBanks=hT.Dimensions;
    else
        numBanks=1;
    end
end



function[RAMType,readNewData,IV,RAMDirective]=getSysObjInfo(sysObjHandle)
    RAMType=sysObjHandle.RAMType;
    if strcmpi(RAMType,'Simple dual port')
        readNewData=[];
    else
        readNewData=strcmpi(sysObjHandle.WriteOutputValue,'New data');
    end
    IV=sysObjHandle.RAMInitialValue;
    RAMDirective=sysObjHandle.RAMDirective;
end



function[RAMType,readNewData,IV,RAMDirective]=getSysBlockInfo(this,slbh)
    RAMType=get_param(slbh,'RAMType');

    if strcmpi(RAMType,'Simple dual port')
        readNewData=[];
    else
        readNewData=strcmpi(get_param(slbh,'WriteOutputValue'),'New data');
    end
    IV=get_param(slbh,'RAMInitialValue');
    RAMDirective=getImplParams(this,'RAMDirective');
end
