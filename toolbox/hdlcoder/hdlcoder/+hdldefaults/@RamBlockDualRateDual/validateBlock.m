function v=validateBlock(~,hC)


    v=hdlvalidatestruct;


    hInSignals=hC.PirInputSignals;
    hInRates=arrayfun(@(x)x.SimulinkRate,hInSignals);
    portARates=hInRates(1:3);
    portBRates=hInRates(4:6);
    if numel(unique(portARates))~=1
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:DualRateDualPortRAMPortRatesMismatch','A'));
    end
    if numel(unique(portBRates))~=1
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:DualRateDualPortRAMPortRatesMismatch','B'));
    end

    hInIsComplex=arrayfun(@(x)x.Type.isComplexType,hInSignals);
    portAIsComplex=hInIsComplex(1:3);
    portBIsComplex=hInIsComplex(4:6);

    if find(arrayfun(@(x,curidx)xor(x,portBIsComplex(curidx)),portAIsComplex,[1:3]')>0)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:DualRateDualPortRAMMixedRealComplexPorts'));
    end


    weType=hInSignals(3).Type;
    isweufix1=weType.isWordType&&weType.Signed==0&&weType.WordLength==1&&weType.FractionLength==0;
    if~weType.isBooleanType&&~isweufix1
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:RAMweType'));
    end

end


