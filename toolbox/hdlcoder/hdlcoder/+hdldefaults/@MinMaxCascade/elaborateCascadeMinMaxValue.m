function elaborateCascadeMinMaxValue(this,hN,hC)




    slbh=hC.SimulinkHandle;

    [fcnString,compType,blockType,idxBase,rndMode,satMode]=this.getBlockInfo(slbh);

    opName=compType;
    casName=sprintf('---- Cascade %s implementation ----',opName);

    if strcmp(compType,'min')
        ipf='hdleml_min';
    else
        ipf='hdleml_max';
    end
    bmp={};


    numInports=length(hC.PirInputPorts);
    hCInSignal=hN.PirInputSignals(1);
    [dimLen,hcInType]=pirelab.getVectorTypeInfo(hCInSignal);


    hCOutSignal=hN.PirOutputSignals(1);


    if strcmp(blockType,'builtin')
        dtcInSignal=this.insertDTCComp(hN,hC,hcInType,hCOutSignal,rndMode,satMode);
    else
        dtcInSignal=hCOutSignal;
    end


    isDspVectorOut=this.isDspMinmaxVectorOut(slbh,hCInSignal,blockType);


    if numInports==1
        if dimLen==1||isDspVectorOut

            valWire=pirelab.getWireComp(hN,hCInSignal,dtcInSignal);


            valWire.copyComment(hC);

        else

            this.cascadeExpandCgirComp(hN,hC,opName,hcInType,ipf,bmp,hCInSignal,dtcInSignal,casName);
        end

    else

        if dimLen==1

            tSignalsIn=hN.PirInputSignals;

            this.cascadeExpandCgirComp(hN,hC,opName,hcInType,ipf,bmp,tSignalsIn,dtcInSignal,casName);
        else

            for ii=1:numInports

                demuxComp(ii)=pirelab.getDemuxCompOnInput(hN,hN.PirInputSignals(ii));%#ok<AGROW>
                hDemuxOutSignals{ii}=demuxComp(ii).PirOutputSignals;%#ok<AGROW>
            end


            demuxComp(1).addComment(casName);

            for ii=1:dimLen

                for jj=1:numInports
                    tSignalsIn(jj)=hDemuxOutSignals{jj}(ii);%#ok<AGROW>
                end

                compName=this.getCompName(hC,opName);
                tSignalsOut(ii)=hN.addSignal(hcInType,[compName,'_mux']);%#ok<AGROW>

                casPartName=sprintf('---- Cascade %s implementation number %d ----',opName,ii);
                this.cascadeExpandCgirComp(hN,hC,opName,hcInType,ipf,bmp,tSignalsIn',tSignalsOut(ii),casPartName,ii)
            end


            pirelab.getMuxComp(hN,tSignalsOut,dtcInSignal,'mux');
        end
    end


    pirOutSigs=hN.PirOutputSignals;
    for ii=1:length(pirOutSigs)
        hN.PirOutputSignals(ii).SimulinkRate=hN.PirInputSignals(1).SimulinkRate;
    end
