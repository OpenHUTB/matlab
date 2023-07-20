function[RamNet,RamNetInstance]=getDualPortRamComp(hN,hInSignals,hOutSignals,...
    compName,numBanks,readNewData,simulinkHandle,initialVal,RAMDirective)










    narginchk(3,9);

    if nargin<9||isempty(RAMDirective)
        RAMDirective='';
    end
    if nargin<8||isempty(initialVal)
        initialVal='';
    end
    if nargin<7||isempty(simulinkHandle)
        simulinkHandle=-1;
    end
    if nargin<6
        readNewData=1;
    end
    if nargin<5
        numBanks=1;
    end
    if nargin<4||isempty(compName)
        compName='dualPortRam';
    end



    addrType=hInSignals(2).Type;
    initialVal=pirelab.convertRAMIV2Str(initialVal,addrType);
    if strcmp(initialVal,'0')
        initialVal='';
    end


    RAMRate=hInSignals(1).SimulinkRate;
    if hOutSignals(1).SimulinkRate==0
        hOutSignals(1).SimulinkRate=RAMRate;
    end
    if hOutSignals(2).SimulinkRate==0
        hOutSignals(2).SimulinkRate=RAMRate;
    end

    isUsingScalarExpansion=false;

    if numBanks>1
        writeDataDemuxComp=pirelab.getDemuxCompOnInput(hN,hInSignals(1));
        hWriteDataDemuxOutSignals=writeDataDemuxComp.PirOutputSignals;

        isUsingScalarExpansion=~hInSignals(2).Type.isArrayType;

        if~isUsingScalarExpansion

            writeAddrDemuxComp=pirelab.getDemuxCompOnInput(hN,hInSignals(2));
            hWriteAddrDemuxOutSignals=writeAddrDemuxComp.PirOutputSignals;

            writeEnDemuxComp=pirelab.getDemuxCompOnInput(hN,hInSignals(3));
            hWriteEnDemuxOutSignals=writeEnDemuxComp.PirOutputSignals;

            readAddrDemuxComp=pirelab.getDemuxCompOnInput(hN,hInSignals(4));
            hReadAddrDemuxOutSignals=readAddrDemuxComp.PirOutputSignals;
        else

            hWriteAddrDemuxOutSignals=hInSignals(2);
            hWriteEnDemuxOutSignals=hInSignals(3);
            hReadAddrDemuxOutSignals=hInSignals(4);
        end
    else

        hWriteDataDemuxOutSignals=hInSignals(1);
        hWriteAddrDemuxOutSignals=hInSignals(2);
        hWriteEnDemuxOutSignals=hInSignals(3);
        hReadAddrDemuxOutSignals=hInSignals(4);
    end


    hD=hdlcurrentdriver;
    if~isempty(hD)
        ramDescriptor=createRAMDescriptor(hD,hN,readNewData,hInSignals,...
        hOutSignals,initialVal,RAMDirective);
        RamNet=hD.getRamNetworkFromMap(ramDescriptor,[]);
        needWrapper=hD.getParameter('ramarchitecture')~=1;
        if needWrapper
            compName=[compName,'_Wrapper'];
        end
    else
        RamNet=[];
        needWrapper=false;
    end

    allBanksWriteOutSignals=hdlhandles(1,numBanks);
    allBanksReadOutSignals=hdlhandles(1,numBanks);
    [~,scalarOutType]=pirelab.getVectorTypeInfo(hOutSignals(1));
    for nn=1:numBanks




        if numBanks==1
            bankOutSignals=deal(hOutSignals);
        else
            bankOutSignals(1)=hN.addSignal(scalarOutType,'pre_wr_out');
            bankOutSignals(2)=hN.addSignal(scalarOutType,'pre_rd_out');


            bankOutSignals(1).SimulinkRate=hOutSignals(1).SimulinkRate;
            bankOutSignals(2).SimulinkRate=hOutSignals(2).SimulinkRate;
        end

        allBanksWriteOutSignals(nn)=bankOutSignals(1);
        allBanksReadOutSignals(nn)=bankOutSignals(2);

        if~isUsingScalarExpansion
            bankInSignals=[hWriteDataDemuxOutSignals(nn),hWriteAddrDemuxOutSignals(nn),...
            hWriteEnDemuxOutSignals(nn),hReadAddrDemuxOutSignals(nn)];
        else
            bankInSignals=[hWriteDataDemuxOutSignals(nn),hWriteAddrDemuxOutSignals,...
            hWriteEnDemuxOutSignals,hReadAddrDemuxOutSignals];
        end
        [RamNet,RamNetInstance]=pircore.getDualPortRamComp(hN,bankInSignals,bankOutSignals,...
        compName,numBanks,nn-1,readNewData,simulinkHandle,RamNet,needWrapper,...
        initialVal,RAMDirective);
        if~isempty(hD)
            hD.saveRamNetworkToMap(ramDescriptor,RamNet);
        end
    end

    if numBanks>1
        pirelab.getMuxComp(hN,allBanksWriteOutSignals,hOutSignals(1),'wr_out_concat');
        pirelab.getMuxComp(hN,allBanksReadOutSignals,hOutSignals(2),'rd_out_concat');
    end
end

function ramDescriptor=createRAMDescriptor(hD,hN,readNewData,hInSignals,...
    hOutSignals,initialVal,RAMDirective)
    if hInSignals(1).Type.getLeafType.WordLength==1
        singlebit=true;
    else
        singlebit=false;
    end
    signs='';
    inputStyle=hD.getParameter('filter_input_type_std_logic');
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
        if hInSignals(4).Type.getLeafType.Signed
            signs=[signs,'s'];
        else
            signs=[signs,'u'];
        end
    end
    outputStyle=hD.getParameter('filter_output_type_std_logic');
    if outputStyle~=1
        if hOutSignals(1).Type.getLeafType.Signed
            signs=[signs,'s'];
        else
            signs=[signs,'u'];
        end
    end
    isComplex=hInSignals(1).Type.isComplexType||...
    hInSignals(1).Type.BaseType.isComplexType;


    if~isempty(initialVal)
        ivstr=num2str(rand(1),10);
    else
        ivstr='';
    end
    ramDescriptor=sprintf('dual_%d_%d_%d_%s_%g%s%s%s',...
    readNewData,isComplex,singlebit,signs,...
    hInSignals(1).SimulinkRate,hN.getCtxName,ivstr,RAMDirective);
end


