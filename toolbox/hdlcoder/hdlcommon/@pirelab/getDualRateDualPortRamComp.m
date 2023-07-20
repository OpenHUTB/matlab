function[RamNet,RamNetInstance]=getDualRateDualPortRamComp(hN,hInSignals,...
    hOutSignals,compName,readNewData,simulinkHandle)










    narginchk(3,6);

    if nargin<6||isempty(simulinkHandle)
        simulinkHandle=-1;
    end
    if nargin<5
        readNewData=1;
    end
    if nargin<4||isempty(compName)
        compName='dualClkPortRam';
    end


    RAMRateA=hInSignals(1).SimulinkRate;
    RAMRateB=hInSignals(4).SimulinkRate;
    if hOutSignals(1).SimulinkRate==0
        hOutSignals(1).SimulinkRate=RAMRateA;
    end
    if hOutSignals(2).SimulinkRate==0
        hOutSignals(2).SimulinkRate=RAMRateB;
    end


    hD=hdlcurrentdriver;
    if hInSignals(1).Type.getLeafType.WordLength==1
        singlebit=true;
    else
        singlebit=false;
    end
    signs='';
    if isempty(hD)
        inputStyle=1;
        outputStyle=1;
    else
        inputStyle=hD.getParameter('filter_input_type_std_logic');
        outputStyle=hD.getParameter('filter_output_type_std_logic');
    end
    if inputStyle~=1
        if hInSignals(1).Type.getLeafType.Signed
            signs=[signs,'s'];
        else
            signs=[signs,'u'];
        end
        if hInSignals(2).Type.getLeafType.Signed
            signs=[signs,'s'];
        else
            signs=[signs,'u'];
        end
    end
    if outputStyle~=1
        if hOutSignals(1).Type.getLeafType.Signed
            signs=[signs,'s'];
        else
            signs=[signs,'u'];
        end
        if hInSignals(5).Type.getLeafType.Signed
            signs=[signs,'s'];
        else
            signs=[signs,'u'];
        end
    end
    isComplexSig1=hInSignals(1).Type.isComplexType||hInSignals(1).Type.BaseType.isComplexType;
    isComplexSig4=hInSignals(4).Type.isComplexType||hInSignals(4).Type.BaseType.isComplexType;
    ramDescriptor=sprintf('dual_%d_%d_%d_%d_%s_%g_%g%s',...
    readNewData,isComplexSig1,...
    isComplexSig4,singlebit,signs,...
    RAMRateA,RAMRateB,hN.getCtxName);
    if~isempty(hD)
        RamNet=hD.getRamNetworkFromMap(ramDescriptor,[]);
        needWrapper=hD.getParameter('ramarchitecture')~=1;
        if needWrapper
            compName=[compName,'_Wrapper'];
        end
    else
        RamNet=[];
        needWrapper=false;
    end




    [RamNet,RamNetInstance]=pircore.getDualRateDualPortRamComp(hN,hInSignals,...
    hOutSignals,compName,readNewData,simulinkHandle,RamNet,needWrapper);
    if~isempty(hD)
        hD.saveRamNetworkToMap(ramDescriptor,RamNet);
    end
end
