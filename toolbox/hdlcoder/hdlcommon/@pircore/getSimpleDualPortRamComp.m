function[RamNet,RamNetInstance]=getSimpleDualPortRamComp(hN,hInSignals,...
    hOutSignals,compName,numBanks,bankNo,simulinkHandle,RamNet,ramCorePrefix,...
    needWrapper,initialVal,RAMDirective)







    narginchk(12,12);


    dataType=hInSignals(1).Type;
    addrType=hInSignals(2).Type;
    ramIsComplex=hInSignals(1).Type.isComplexType;


    addrBits=addrType.getLeafType.WordLength;
    dataBits=dataType.getLeafType.WordLength;


    addrName='AddrWidth';
    dataName='DataWidth';
    genericType=pir_unsigned_t(32);

    if isempty(RamNet)||numBanks>1
        if~ramIsComplex&&dataBits==1
            postfix='singlebit';
        else
            postfix='generic';
        end
        compName=sprintf('%s_%s',compName,postfix);
    end


    if isempty(RamNet)

        ufix1Type=pir_ufixpt_t(1,0);


        ramCoreName=sprintf('%sSimpleDualPortRAM_%s',ramCorePrefix,postfix);


        if needWrapper
            ramNetworkName=compName;
        else
            ramNetworkName=ramCoreName;
        end
        RamNet=pirelab.createNewNetwork(...
        'Network',hN,...
        'Name',ramNetworkName,...
        'InportNames',{'wr_din','wr_addr','wr_en','rd_addr'},...
        'InportTypes',[dataType,addrType,ufix1Type,addrType],...
        'InportRates',...
        [hInSignals(1).SimulinkRate,...
        hInSignals(2).SimulinkRate,...
        hInSignals(3).SimulinkRate,...
        hInSignals(4).SimulinkRate],...
        'OutportNames',{'rd_dout'},...
        'OutportTypes',dataType);


        RamNet.PirOutputSignals.SimulinkRate=hOutSignals.SimulinkRate;

        if needWrapper

            [RamInstNet,instNIC]=instantiateRamInstNetwork(RamNet,dataType,addrType,...
            ufix1Type,ramCoreName);
        else
            RamInstNet=RamNet;
            instNIC=[];
        end


        input=RamInstNet.PirInputSignals;
        output=RamInstNet.PirOutputSignals;
        hRamDT=input(1).Type;

        if needWrapper
            ramNetworkName=compName;
        else
            ramNetworkName=ramCoreName;
        end
        ramcomp=RamInstNet.addComponent2(...
        'kind','ram_simple_dual_comp',...
        'name',ramNetworkName,...
        'InputSignals',input,...
        'OutputSignals',output,...
        'Complex',ramIsComplex,...
        'InitialVal',initialVal,...
        'RamDataType',hRamDT,...
        'RAMDirective',RAMDirective);

        ramcomp.setGMHandle(simulinkHandle);
        ramcomp.setSupportAlteraMegaFunctions(true);
        ramcomp.setSupportXilinxCoreGen(true);


        RamNet.addGenericPort(addrName,convertMaskValueToInt(1),genericType);
        RamNet.PirInputPorts(2).setGenericNameForType(addrName);
        RamNet.PirInputPorts(4).setGenericNameForType(addrName);
        if needWrapper
            RamInstNet.addGenericPort(addrName,convertMaskValueToInt(1),genericType);
            RamInstNet.PirInputPorts(2).setGenericNameForType(addrName);
            RamInstNet.PirInputPorts(4).setGenericNameForType(addrName);
            instNIC.addGenericPort(addrName,convertMaskValueToInt(addrName),genericType);
            instNIC.PirInputPorts(2).setGenericNameForType(addrName);
            instNIC.PirInputPorts(4).setGenericNameForType(addrName);
        end


        RamNet.addGenericPort(dataName,convertMaskValueToInt(1),genericType);
        if needWrapper
            RamInstNet.addGenericPort(dataName,convertMaskValueToInt(1),genericType);
            instNIC.addGenericPort(dataName,convertMaskValueToInt(dataName),genericType);
        end

        if dataBits>1
            RamNet.PirInputPorts(1).setGenericNameForType(dataName);
            RamNet.PirOutputPorts(1).setGenericNameForType(dataName);
            if needWrapper
                RamInstNet.PirInputPorts(1).setGenericNameForType(dataName);
                RamInstNet.PirOutputPorts(1).setGenericNameForType(dataName);
                instNIC.PirInputPorts(1).setGenericNameForType(dataName);
                instNIC.PirOutputPorts(1).setGenericNameForType(dataName);
            end
        end
    else
        if numel(RamNet.Components)==1
            ramcomp=RamNet.Components;
        else

            ramcomp=[];

            for i=1:numel(RamNet.Components)
                comp=RamNet.Components(i);

                if isempty(ramcomp)&&isa(comp,'hdlcoder.ram_simple_dual_comp')
                    ramcomp=comp;
                else
                    assert(isa(comp,'hdlcoder.buffer_comp'));
                end
            end
        end
    end

    if simulinkHandle>0
        ramInstName=get_param(simulinkHandle,'Name');
    else
        ramInstName=compName;
    end


    if numBanks>1
        ramInstName=[ramInstName,'_bank',int2str(bankNo)];
    end


    RamNetInstance=pirelab.instantiateNetwork(hN,RamNet,hInSignals,...
    hOutSignals,ramInstName);
    RamNetInstance.addGenericPort(addrName,convertMaskValueToInt(addrBits),genericType);
    RamNetInstance.PirInputPorts(2).setGenericNameForType(addrName);
    RamNetInstance.PirInputPorts(4).setGenericNameForType(addrName);
    RamNetInstance.addGenericPort(dataName,convertMaskValueToInt(dataBits),genericType);
    if dataBits>1
        RamNetInstance.PirInputPorts(1).setGenericNameForType(dataName);
        RamNetInstance.PirOutputPorts(1).setGenericNameForType(dataName);
    end


    pircore.setRAMNetworkFlags(RamNetInstance,ramcomp);
end


function[RamInstNet,instNIC]=instantiateRamInstNetwork(RamNet,dataType,...
    addrType,ufix1Type,ramCoreName)
    RamInstNet=pirelab.createNewNetwork(...
    'Network',RamNet,...
    'Name',ramCoreName,...
    'InportNames',{'wr_din','wr_addr','wr_en','rd_addr'},...
    'InportTypes',[dataType,addrType,ufix1Type,addrType],...
    'InportRates',...
    [RamNet.PirInputSignals(1).SimulinkRate,...
    RamNet.PirInputSignals(2).SimulinkRate,...
    RamNet.PirInputSignals(3).SimulinkRate,...
    RamNet.PirInputSignals(4).SimulinkRate],...
    'OutportNames',{'rd_dout'},...
    'OutportTypes',dataType);

    RamInstNet.setRAM(true);

    RamInstNet.PirOutputSignals.SimulinkRate=RamNet.PirOutputSignals.SimulinkRate;

    instNIC=pirelab.instantiateNetwork(RamNet,RamInstNet,...
    RamNet.PirInputSignals,RamNet.PirOutputSignals,ramCoreName);
end


