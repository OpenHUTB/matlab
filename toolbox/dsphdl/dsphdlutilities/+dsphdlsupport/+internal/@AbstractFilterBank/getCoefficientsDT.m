function DT=getCoefficientsDT(this,blockInfo)




    hFIR=dsphdl.private.AbstractFilterBank('FilterStructure','Direct form transposed',...
    'CoefficientsDataType',blockInfo.CoefficientsDataType,...
    'FilterOutputDataType',blockInfo.FilterOutputDataType,...
    'FilterCoefficients',blockInfo.FilterCoefficient);

    inputDT=getInputDT(hFIR,blockInfo.CompiledInputDT);
    DT=getCoefficientsDT(hFIR,inputDT);


    release(hFIR);
    delete(hFIR);
end
