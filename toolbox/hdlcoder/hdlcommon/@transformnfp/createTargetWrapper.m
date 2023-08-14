function hNew=createTargetWrapper(hN,hC,hNfpNwk,compName,isSingle,compositeNFPOptions)



    sigT=[];
    if(isempty(compositeNFPOptions))

        if hC.NumberOfPirInputPorts>0
            sigT=hC.PirInputSignals(1).Type.getLeafType;
        end

        if~isempty(sigT)&&~(sigT.isFloatType)&&...
            (hC.NumberOfPirOutputPorts>0)
            sigT=hC.PirOutputSignals(1).Type.getLeafType;
        end
    end

    if(~isempty(sigT))
        isHalf=sigT.isHalfType;
    else
        isHalf=false;
    end




    hNew=createTopWrapper(hN,hC,compName,hNfpNwk,isSingle,isHalf,compositeNFPOptions);
    hInSignals=hNew.PirInputSignals;
    hOutSignals=hNew.PirOutputSignals;

    nfpCompInSigs=hNfpNwk.PirInputSignals;
    unpackSigs=[];

    for ii=1:numel(nfpCompInSigs)
        compSig=nfpCompInSigs(ii);
        sig=addSignal(hNew,compSig.Name,compSig.Type,compSig.SimulinkRate);
        unpackSigs=[unpackSigs,sig];
    end

    nfpCompOutSigs=hNfpNwk.PirOutputSignals;
    packSigs=[];

    if~strcmp(compName,'nfp_relop_comp')
        for ii=1:numel(nfpCompOutSigs)
            compSig=nfpCompOutSigs(ii);
            sig=addSignal(hNew,compSig.Name,compSig.Type,compSig.SimulinkRate);
            packSigs=[packSigs,sig];
        end
    end

    if isSingle
        dtcSigType=pir_ufixpt_t(32,0);
    elseif isHalf
        dtcSigType=pir_ufixpt_t(16,0);
    else
        dtcSigType=pir_ufixpt_t(64,0);
    end

    for ii=1:numel(hInSignals)
        dtcSigName=[hInSignals(ii).Name,'_unpack'];
        dtcSig=addSignal(hNew,dtcSigName,dtcSigType,hInSignals(ii).SimulinkRate);
        pirelab.getDTCComp(hNew,hInSignals(ii),dtcSig);
        if isSingle
            transformnfp.getSingleUnpackComp(hNew,dtcSig,unpackSigs((3*ii-2):(3*ii)),'add_unpack');
        elseif isHalf
            transformnfp.getHalfUnpackComp(hNew,dtcSig,unpackSigs((3*ii-2):(3*ii)),'add_unpack');
        else
            transformnfp.getDoubleUnpackComp(hNew,dtcSig,unpackSigs((3*ii-2):(3*ii)),'add_unpack');
        end
    end

    if~strcmp(compName,'nfp_relop_comp')
        for ii=1:numel(hOutSignals)
            dtcSigName=[hOutSignals(ii).Name,'_pack'];
            dtcSig=addSignal(hNew,dtcSigName,dtcSigType,hOutSignals(ii).SimulinkRate);
            pirelab.getDTCComp(hNew,dtcSig,hOutSignals(ii));
            if isSingle
                transformnfp.getSinglePackComp(hNew,packSigs((3*ii-2):(3*ii)),dtcSig,'add_pack');
            elseif isHalf
                transformnfp.getHalfPackComp(hNew,packSigs((3*ii-2):(3*ii)),dtcSig,'add_pack');
            else
                transformnfp.getDoublePackComp(hNew,packSigs((3*ii-2):(3*ii)),dtcSig,'add_pack');
            end
        end

        if strcmp(compName,'nfp_add2_comp')

            helperNtwk1=transformnfp.addNfpNZUminusComp(hN,['NZUminus_',num2str(1)],packSigs(1).SimulinkRate,isSingle,isHalf);
            helperNtwk2=transformnfp.addNfpNZUminusComp(hN,['NZUminus_',num2str(2)],packSigs(2).SimulinkRate,isSingle,isHalf);
            tmpSigs=[];
            for ii=1:numel(unpackSigs)
                compSig=unpackSigs(ii);
                sig=addSignal(hNew,compSig.Name,compSig.Type,compSig.SimulinkRate);
                tmpSigs=[tmpSigs,sig];
            end
            pirelab.instantiateNetwork(hNew,hNfpNwk,tmpSigs,packSigs,['u_',hNfpNwk.Name]);
            pirelab.instantiateNetwork(hNew,helperNtwk1,unpackSigs(1:3),tmpSigs(1:3),['u1_',helperNtwk1.Name]);
            pirelab.instantiateNetwork(hNew,helperNtwk2,unpackSigs(4:6),tmpSigs(4:6),['u2_',helperNtwk2.Name]);
        else
            pirelab.instantiateNetwork(hNew,hNfpNwk,unpackSigs,packSigs,['u_',hNfpNwk.Name]);
        end
    else
        pirelab.instantiateNetwork(hNew,hNfpNwk,unpackSigs,hOutSignals,['u_',hNfpNwk.Name]);
    end

end


function hNew=createTopWrapper(hN,hC,compName,hNfpNwk,isSingle,isHalf,compositeNFPOptions)
    if~isempty(compositeNFPOptions)





        assert(mod(hNfpNwk.NumberOfPirInputPorts,3)==0);
        hNumInports=hNfpNwk.NumberOfPirInputPorts/3;
        hInSignals=[];
        hCInputPorts=[];
        for ii=1:hNumInports
            hInSignals=[hInSignals,hNfpNwk.PirInputSignals(3*ii)];
            hCInputPorts=[hCInputPorts,hNfpNwk.PirInputPorts(3*ii)];%#ok<*AGROW>
        end
    else
        hInSignals=hC.PirInputSignals;
        hNumInports=hC.NumberOfPirInputPorts;
        hCInputPorts=hC.PirInputPorts;
    end
    hInportNames=cell(1,hNumInports);
    hInportTypes=hdlhandles(1,hNumInports);
    hInportRates=zeros(1,hNumInports);
    hInportKinds=cell(1,hNumInports);

    if~isempty(compositeNFPOptions)


        hOutSignals=[];
        hCOutputPorts=[];
        if~(strcmp(compName,'nfp_relop_comp'))
            assert(mod(hNfpNwk.NumberOfPirOutputPorts,3)==0);
            hNumOutports=hNfpNwk.NumberOfPirOutputPorts/3;
            for ii=1:hNumOutports
                hOutSignals=[hOutSignals,hNfpNwk.PirOutputSignals(3*ii)];
                hCOutputPorts=[hCOutputPorts,hNfpNwk.PirOutputPorts(3*ii)];
            end
        else
            hNumOutports=hNfpNwk.NumberOfPirOutputPorts;
            for ii=1:hNumOutports
                hOutSignals=[hOutSignals,hNfpNwk.PirOutputSignals(ii)];
                hCOutputPorts=[hCOutputPorts,hNfpNwk.PirOutputPorts(ii)];
            end
        end
    else
        hOutSignals=hC.PirOutputSignals;
        hNumOutports=hC.NumberOfPirOutputPorts;
    end
    hOutportNames=cell(1,hNumOutports);
    hOutportTypes=hdlhandles(1,hNumOutports);
    inSigPrefix='nfp_in';
    outSigPrefix='nfp_out';

    for ii=1:hNumInports
        if hNumInports>1
            hInportNames{ii}=[inSigPrefix,num2str(ii)];
        else
            hInportNames{ii}=inSigPrefix;
        end
        if isSingle
            hInportTypes(ii)=pir_ufixpt_t(32,0);
        elseif isHalf
            hInportTypes(ii)=pir_ufixpt_t(16,0);
        else
            hInportTypes(ii)=pir_ufixpt_t(64,0);
        end
        if~isempty(compositeNFPOptions)
            hInportRates(ii)=hC.PirInputSignals(1).SimulinkRate;
        else
            hInportRates(ii)=hInSignals(ii).SimulinkRate;
        end
        hInportKinds{ii}=hCInputPorts(ii).Kind;
    end

    if strcmp(compName,'nfp_relop_comp')
        hOutSignals=hNfpNwk.PirOutputSignals;
        hNumOutports=hNfpNwk.NumberOfPirOutputPorts;
        hOutportNames=cell(1,hNumOutports);
        hOutportTypes=hdlhandles(1,hNumOutports);
        for ii=1:hNumOutports
            hOutportNames{ii}=[outSigPrefix,num2str(ii)];
            hOutportTypes(ii)=pir_ufixpt_t(1,0);
        end
    elseif strcmp(compName,'nfp_trig_comp')||strcmp(compName,'nfp_minmax_comp')
        for ii=1:2
            hOutportNames{ii}=[outSigPrefix,num2str(ii)];
            if isSingle
                hOutportTypes(ii)=pir_ufixpt_t(32,0);
            elseif isHalf
                hOutportTypes(ii)=pir_ufixpt_t(16,0);
            else
                hOutportTypes(ii)=pir_ufixpt_t(64,0);
            end
        end
    else
        for ii=1:hNumOutports
            if hNumOutports>1
                hOutportNames{ii}=[outSigPrefix,num2str(ii)];
            else
                hOutportNames{ii}=outSigPrefix;
            end
            if isSingle
                hOutportTypes(ii)=pir_ufixpt_t(32,0);
            elseif isHalf
                hOutportTypes(ii)=pir_ufixpt_t(16,0);
            else
                hOutportTypes(ii)=pir_ufixpt_t(64,0);
            end
        end
    end


    nfpCompName=extractBefore(compName,'_comp');
    if(isSingle)
        networkName=[nfpCompName,'_single'];
    elseif(isHalf)
        networkName=[nfpCompName,'_half'];
    else
        networkName=[nfpCompName,'_double'];
    end

    hNew=pirelab.createNewNetwork(...
    'Network',hN,...
    'Name',networkName,...
    'InportNames',hInportNames,...
    'InportTypes',hInportTypes,...
    'InportRates',hInportRates,...
    'InportKinds',hInportKinds,...
    'OutportNames',hOutportNames,...
    'OutportTypes',hOutportTypes);
    hNew.setNfpNetwork(true);
    hNewOutSigs=hNew.PirOutputSignals;
    if strcmp(compName,'nfp_trig_comp')||strcmp(compName,'nfp_minmax_comp')
        hNewOutSigs(1).SimulinkRate=hOutSignals(1).SimulinkRate;
        hNewOutSigs(2).SimulinkRate=hOutSignals(1).SimulinkRate;
    else
        for ii=1:numel(hNewOutSigs)
            hNewOutSigs(ii).SimulinkRate=hOutSignals(ii).SimulinkRate;
        end
    end
end


function hS=addSignal(hN,sigName,pirTyp,slrate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=0;
    hS.SimulinkRate=slrate;
end


