
function[rndMode,ovMode,accType,inputsigns]=getBlockInfo(this,hC)
    slbh=hC.SimulinkHandle;
    sat=get_param(slbh,'DoSatur');
    if strcmp(sat,'on')
        ovMode='Saturate';
    else
        ovMode='Wrap';
    end
    rndMode=get_param(slbh,'RndMeth');
    accType=getAccType(hC);


    inputsigns=this.getInputSigns(slbh);
end


function accTp=getAccType(hC)

    outType=hC.PirOutputSignals(1).Type;
    if outType.isArrayType||outType.isComplexType
        outType=outType.getLeafType;
    end
    if outType.isFloatType
        accTp=outType;
    else
        T=getaccumforsum(hC.SimulinkHandle,outType.WordLength,outType.FractionLength,outType.Signed);
        accTp=pir_fixpt_t(T.signed,T.size,-T.bp);
    end
end


