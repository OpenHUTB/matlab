function hNewC=elabNFPSparseConstMultiply(hN,hC,constMatrix,...
    sharingFactor,earlyElaborate,multiplyAddMap,nfpCustomLatency,useRAM)




    if nargin<8
        useRAM='off';
    end





    [activeElements,activeRowPositions,activeColumnPositions]=sschdloptimizations.getActiveElements(constMatrix,sharingFactor);


    hNNew=pirelab.createNewNetworkWithInterface('Network',hN,'RefComponent',hC);

    hNNewInSignals=hNNew.PirInputSignals;
    hNNewOutSignals=hNNew.PirOutputSignals;
    hNNewOutSignals.SimulinkRate=hC.PirOutputSignals.SimulinkRate;

    hNNew.setSharingFactor(sharingFactor)


    inSignal=hNNewInSignals(1);

    selSignal=hNNewInSignals(2);

    if isempty(activeElements{1})

        pirelab.getConstComp(hNNew,hNNewOutSignals,0);

        nilComp=pirelab.getNilComp(hNNew,inSignal,[],'terminator');


        nilComp.setPreserve(true);

        nilComp=pirelab.getNilComp(hNNew,selSignal,[],'terminator');


        nilComp.setPreserve(true);
    else


        numConfigurations=numel(activeElements);



        activeElementsSignals=hdlhandles(1,numConfigurations);

        constValue=activeElements{1};
        constType=pirelab.convertSLType2PirType(class(constValue));
        inSignalType=getPirSignalLeafType(inSignal.Type);
        if numel(constValue)>1

            constType=pirelab.getPirVectorType(constType,numel(constValue));
            inSignalType=pirelab.getPirVectorType(inSignalType,numel(constValue));
        end



        activeConfigurationSignal=hNNew.addSignal(inSignalType,'active_configuration');
        activeConfigurationSignal.SimulinkRate=inSignal.SimulinkRate;

        if(strcmp(useRAM,'on'))
            numConfigurations=numel(activeElements);
            dataTypeVal=nextpow2((2*numConfigurations));
            if numConfigurations==1
                dataTypeVal=nextpow2((2*numConfigurations)+1);
            end

            ramRdWraddressDT=dataTypeVal;
            ramSize=2^dataTypeVal;
            ramVals=cell(1,1);
            inSignalLeafType=getPirSignalLeafType(inSignal.Type);



            fixdptType=pir_unsigned_t(ramRdWraddressDT);


            booleanType=pir_boolean_t;

            ipSig1Leaf=hN.addSignal(inSignalLeafType,'matrixrateSignal');
            ipSig1Leaf.SimulinkRate=(inSignal.SimulinkRate);


            rdRamAddIncSig=hNNew.addSignal(fixdptType,'rdRamAddIncSig');
            rdRamAddIncSig.SimulinkRate=inSignal.SimulinkRate;


            wrRamAddressSig=hNNew.addSignal(rdRamAddIncSig);


            rdRamAddressSig=hNNew.addSignal(rdRamAddIncSig);



            constModeShiftSig=hNNew.addSignal(rdRamAddIncSig);


            ramDataportSig=hNNew.addSignal(ipSig1Leaf);


            boolSignal=hNNew.addSignal(booleanType,'booleansig');
            boolSignal.SimulinkRate=inSignal.SimulinkRate;



            constModeShiftComp=pirelab.getConstComp(hNNew,constModeShiftSig,2,'constModeShift',[],[],[],[],[]);%#ok<*NASGU>




            modeMulComp=pirelab.getMulComp(hNNew,[selSignal,constModeShiftSig],wrRamAddressSig);


            constRamWrenComp=pirelab.getConstComp(hNNew,boolSignal,0,'boolconst',[],[],[],[],[]);

            ramDataInComp=pirelab.getConstComp(hNNew,ramDataportSig,0,'singleConst',[],[],[],[],[]);


            rdRamAddIncComp=pirelab.getConstComp(hNNew,rdRamAddIncSig,1,'fixedptConst',[],[],[],[],[]);
            AddConstOut=pirelab.getAddComp(hNNew,[rdRamAddIncSig,wrRamAddressSig],rdRamAddressSig,...
            'Floor','Wrap','Add','Single','++');

            for ii=1:numConfigurations
                constValue=activeElements{ii};
                if(mod(numel(constValue),2)==0)
                    newConstValue(1:numel(constValue),ii)=constValue;%#ok<AGROW>
                    nconstValue=constValue;
                else
                    nconstValue(numel(constValue)+1)=0;
                    newConstValue(1:numel(constValue),ii)=constValue;%#ok<AGROW>
                    newConstValue((numel(constValue)+1),ii)=0;%#ok<AGROW>
                end
            end

            k=1;
            for j=1:2:numel(nconstValue)
                ramKVal=newConstValue(j:j+1,:);
                ramVals{k}=ramKVal(:);
                k=k+1;
            end
            noofRams=k-1;


            ramAddress=1;
            for i=1:1:noofRams
                ramVal=ramVals{i};
                ramOutSigWr=hNNew.addSignal(ipSig1Leaf);
                ramOutSigRd=hNNew.addSignal(ipSig1Leaf);
                [newRam(i),newRamNIC(i)]=pirelab.getDualPortRamComp(hNNew,...
                [ramDataportSig,wrRamAddressSig,boolSignal,rdRamAddressSig],...
                [ramOutSigWr,ramOutSigRd],...
                'DualPortRAM_generic',1,...
                1,-1,...
                ramVal,'block');%#ok
                newRam(i).Components(1).setOutputDelay(1);
                ramoutSignals(ramAddress)=ramOutSigWr;%#ok<AGROW>
                ramoutSignals(ramAddress+1)=ramOutSigRd;%#ok<AGROW>
                ramAddress=ramAddress+2;
            end


            activeConfigurationSignal=hNNew.addSignal(inSignalType,'active_configuration');
            activeConfigurationSignal.SimulinkRate=inSignal.SimulinkRate;



            if(mod(numel(constValue),2)==0)
                conCatComp=pirelab.getConcatenateComp(hNNew,...
                ramoutSignals(1:(ramAddress-1)),...
                activeConfigurationSignal,...
                'Vector',...
                1,...
                'muxC');
            else
                gndComp=pirelab.getNilComp(hNNew,...
                ramoutSignals(ramAddress-1),...
                [],...
                'terminator');
                conCatComp=pirelab.getConcatenateComp(hNNew,...
                ramoutSignals(1:(ramAddress-2)),...
                activeConfigurationSignal,...
                'Vector',...
                1,...
                'muxC');
            end

        else





            for ii=1:numConfigurations
                constValue=activeElements{ii};
                activeElementsSignals(ii)=hNNew.addSignal(constType,['configuration',num2str(ii)]);
                activeElementsSignals(ii).SimulinkRate=inSignal.SimulinkRate;
                pirelab.getConstComp(hNNew,activeElementsSignals(ii),constValue);
            end



            isSameTypeConstMatrixInSignal=...
            isEqual(getPirSignalLeafType(constType),getPirSignalLeafType(inSignalType));

            if numConfigurations>1


                if isSameTypeConstMatrixInSignal

                    pirelab.getMultiPortSwitchComp(hNNew,[selSignal,activeElementsSignals],...
                    activeConfigurationSignal,1,'Zero-based contiguous');
                else


                    dtcSignal=hNNew.addSignal(constType,'configuration');
                    pirelab.getMultiPortSwitchComp(hNNew,[selSignal,activeElementsSignals],...
                    dtcSignal,1,'Zero-based contiguous');

                    if earlyElaborate
                        dtcComp=pirelab.getDTCComp(hNNew,dtcSignal,activeConfigurationSignal);
                    else
                        dtcComp=hNNew.addComponent2(...
                        'kind','target_conv_comp',...
                        'SimulinkHandle',-1,...
                        'name','DTC',...
                        'InputSignals',dtcSignal,...
                        'OutputSignals',activeConfigurationSignal);
                    end
                    dtcComp.setRoundingMode('Nearest');
                    dtcComp.setConversionMode('RWV');
                    dtcComp.setOverflowMode('Wrap');
                    dtcComp.setNFPLatency(int8(3));
                    dtcComp.setNFPCustomLatency(0);
                end

            else


                if isSameTypeConstMatrixInSignal
                    activeConfigurationSignal=activeElementsSignals(1);
                else


                    if earlyElaborate
                        dtcComp=pirelab.getDTCComp(hNNew,activeElementsSignals(1),...
                        activeConfigurationSignal,'Nearest');
                    else
                        dtcComp=hNNew.addComponent2(...
                        'kind','target_conv_comp',...
                        'SimulinkHandle',-1,...
                        'name','DTC',...
                        'InputSignals',activeElementsSignals(1),...
                        'OutputSignals',activeConfigurationSignal);
                    end
                    dtcComp.setRoundingMode('Nearest');
                    dtcComp.setConversionMode('RWV');
                    dtcComp.setOverflowMode('Wrap');
                    dtcComp.setNFPLatency(int8(3));
                    dtcComp.setNFPCustomLatency(0);
                end


                nilComp=pirelab.getNilComp(hNNew,selSignal,[],'terminator');


                nilComp.setPreserve(true);
            end
        end

        numSelSignals=cellfun(@(x)numel(x),activeRowPositions);

        selOut=cellfun(@(x)~isempty(x),activeRowPositions);


        rowSignals=getSelOutSignals(hNNew,numSelSignals,inSignal,'row');

        activeRowPositions=activeRowPositions(selOut);

        for ii=1:numel(rowSignals)
            pirelab.getSelectorComp(hNNew,activeConfigurationSignal,...
            rowSignals(ii),'One-based',{'Index vector (dialog)'},...
            activeRowPositions(ii),{1},'1',strcat('SelectRows',num2str(ii)));
        end


        columnSignals=getSelOutSignals(hNNew,numSelSignals,inSignal,'col');

        activeColumnPositions=activeColumnPositions(selOut);

        for ii=1:numel(columnSignals)
            pirelab.getSelectorComp(hNNew,inSignal,columnSignals(ii),...
            'One-based',{'Index vector (dialog)'},activeColumnPositions(ii),...
            {1},'1',strcat('SelectCols',num2str(ii)));
        end


        if earlyElaborate
            numDelays=0;
        else
            numDelays=hC.getFPDelays;
        end


        dotProductSignals=transformnfp.scmMultiplyAndAdd(hNNew,rowSignals,...
        columnSignals,selOut,numDelays,earlyElaborate,multiplyAddMap,nfpCustomLatency);


        pirelab.getConcatenateComp(hNNew,dotProductSignals,hNNewOutSignals,'Vector','1');
    end

    hNewC=pirelab.instantiateNetwork(hN,hNNew,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end

function selOutSignals=getSelOutSignals(hN,numSelSignals,inSignal,signalPrefix)




    selOutSignals=[];
    signalType=getPirSignalLeafType(inSignal.Type);
    signalRate=inSignal.SimulinkRate;

    for ii=1:numel(numSelSignals)
        numselSignalii=numSelSignals(ii);
        if numselSignalii>0

            selOutType=signalType;

            if numselSignalii>1

                selOutType=pirelab.getPirVectorType(signalType,numselSignalii);
            end

            selOutSignal=hN.addSignal(selOutType,[signalPrefix,num2str(ii)]);
            selOutSignal.SimulinkRate=signalRate;
            selOutSignals=[selOutSignals,selOutSignal];%#ok<AGROW>
        end
    end
end
