function topNet=elaborateGamma(~,topNet,blockInfo,insignals,outsignals)





    dataIn=insignals(1);
    hStartIn=insignals(2);
    hEndIn=insignals(3);
    vStartIn=insignals(4);
    vEndIn=insignals(5);
    validIn=insignals(6);


    dataOut=outsignals(1);
    hStartOut=outsignals(2);
    hEndOut=outsignals(3);
    vStartOut=outsignals(4);
    vEndOut=outsignals(5);
    validOut=outsignals(6);


    rateIn=dataIn.SimulinkRate;
    dataOut.SimulinkRate=rateIn;
    hStartOut.SimulinkRate=rateIn;
    hEndOut.SimulinkRate=rateIn;
    vStartOut.SimulinkRate=rateIn;
    vEndOut.SimulinkRate=rateIn;
    validOut.SimulinkRate=rateIn;


    signalType=dataIn.Type;


    if signalType.isArrayType
        for ii=1:dataIn.Type.Dimensions
            signal(ii)=dataSignal(topNet,sprintf('signal%d',ii),signalType.BaseType,rateIn);%#ok<AGROW> 
            pirelab.getSelectorComp(topNet,dataIn,signal(ii),'One-based',{'Index vector (dialog)','Select all'},{ii},{'Inherit from "Index"'},'2',sprintf('Selector%d',ii));
        end
    end

    Wl=dataIn.Type.BaseType.Wordlength;
    Fl=dataIn.Type.BaseType.Fractionlength;
    Si=dataIn.Type.BaseType.Signed;

    if Si
        LUTOutType=pir_sfixpt_t(Wl,Fl);
    else
        LUTOutType=pir_ufixpt_t(Wl,Fl);
    end
    LUTAddrType=pir_ufixpt_t(Wl,0);

    if signalType.isArrayType


        for ii=1:dataIn.Type.Dimensions(1)
            lutaddr(ii)=topNet.addSignal(LUTAddrType,sprintf('lutaddr%d',ii));%#ok<AGROW>
            lutoutput(ii)=topNet.addSignal(LUTOutType,sprintf('lutoutput%d',ii));%#ok<AGROW>
            lutoutreg(ii)=topNet.addSignal(LUTOutType,sprintf('lutoutreg%d',ii));%#ok<AGROW>
            regcomp=pirelab.getDTCComp(topNet,signal(ii),lutaddr(ii),'Nearest','Wrap','SI');
        end
    else
        lutaddr=topNet.addSignal2('Type',LUTAddrType);
        lutoutput=topNet.addSignal2('Type',LUTOutType);
        lutoutreg=topNet.addSignal2('Type',LUTOutType);
        regcomp=pirelab.getDTCComp(topNet,dataIn,lutaddr,'Nearest','Wrap','SI');
    end
    regcomp.addComment('convert dataIn to LUT address');
    [tabledata,tableidx,bpType,oType,fType]=ComputeLUT(blockInfo.LUT,Wl,-Fl,Si);


    if signalType.isArrayType
        for ii=1:dataIn.Type.Dimensions(1)
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr(ii),lutoutput(ii),...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment(sprintf('Gamma Curve Table%d',ii));
            regcomp=pirelab.getUnitDelayComp(topNet,lutoutput(ii),lutoutreg(ii),sprintf('LUTRegister%d',ii),0,blockInfo.resetnone);
        end
    else
        regcomp=pirelab.getLookupNDComp(topNet,lutaddr,lutoutput,...
        tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
        regcomp.addComment('Gamma Curve Table');
        regcomp=pirelab.getUnitDelayComp(topNet,lutoutput,lutoutreg,'LUTRegister',0,blockInfo.resetnone);
    end

    if blockInfo.resetnone
        regcomp.addComment('To infer a RAM, the register following LUT is set to ResetNone');
    end

    if signalType.isArrayType

        lutoutreg_comb=topNet.addSignal2('Type',pirelab.createPirArrayType(LUTOutType,[dataIn.Type.Dimensions(1),1]));
        pirelab.getConcatenateComp(topNet,[lutoutreg(1:dataIn.Type.Dimensions(1))],lutoutreg_comb,'Multidimensional array','1');
    end


    if signalType.isArrayType

        lutoutreg1=topNet.addSignal2('Type',pirelab.createPirArrayType(LUTOutType,[dataIn.Type.Dimensions(1),1]));
    else
        lutoutreg1=topNet.addSignal2('Type',LUTOutType);
    end


    ufix1Type=pir_ufixpt_t(1,0);
    vType=pirelab.getPirVectorType(ufix1Type,blockInfo.delay);
    sreg=topNet.addSignal(vType,'sregout');

    dins=[];
    for ii=1:blockInfo.delay-1
        temp=topNet.addSignal(ufix1Type,'Enable');
        dins=[dins,temp];%#ok
    end
    dins=topNet.addSignal(ufix1Type,'Enable');
    pirelab.getDemuxComp(topNet,sreg,[validOut,dins]);

    regcomp=pirelab.getIntDelayComp(topNet,hStartIn,hStartOut,blockInfo.delay,'hStart');
    regcomp.addComment([num2str(blockInfo.delay),' clock delays for hStart']);

    regcomp=pirelab.getIntDelayComp(topNet,hEndIn,hEndOut,blockInfo.delay,'hEnd');
    regcomp.addComment([num2str(blockInfo.delay),' clock delays for hEnd']);

    regcomp=pirelab.getIntDelayComp(topNet,vStartIn,vStartOut,blockInfo.delay,'vStart');
    regcomp.addComment([num2str(blockInfo.delay),' clock delays for vStart']);

    regcomp=pirelab.getIntDelayComp(topNet,vEndIn,vEndOut,blockInfo.delay,'vEnd');
    regcomp.addComment([num2str(blockInfo.delay),' clock delays for vEnd']);

    regcomp=pirelab.getTapDelayComp(topNet,validIn,sreg,blockInfo.delay,'valid');
    regcomp.addComment([num2str(blockInfo.delay),' clock delays for valid']);


    if signalType.isArrayType
        if blockInfo.delay-2>0
            pirelab.getIntDelayComp(topNet,lutoutreg_comb,lutoutreg1,blockInfo.delay-2,'vEnd');
        else
            lutoutreg1=lutoutreg_comb;
        end
    else
        if blockInfo.delay-2>0
            pirelab.getIntDelayComp(topNet,lutoutreg,lutoutreg1,blockInfo.delay-2,'vEnd');
        else
            lutoutreg1=lutoutreg;
        end
    end

    if signalType.isArrayType

        zeroconst=topNet.addSignal2('Type',pirelab.createPirArrayType(LUTOutType,[dataIn.Type.Dimensions(1),1]));
        pirelab.getConstComp(topNet,zeroconst,0);
        switchout=topNet.addSignal2('Type',pirelab.createPirArrayType(LUTOutType,[dataIn.Type.Dimensions(1),1]));
    else
        zeroconst=topNet.addSignal2('Type',LUTOutType);
        pirelab.getConstComp(topNet,zeroconst,0);
        switchout=topNet.addSignal2('Type',LUTOutType);
    end

    pirelab.getSwitchComp(topNet,[zeroconst,lutoutreg1],switchout,dins(1),'holdmux');
    pirelab.getUnitDelayComp(topNet,switchout,dataOut);
    regcomp.addComment('dataOut maintains zero when validIn is low');

end


function[tabledata,tableidx,bpType,oType,fType]=ComputeLUT(LUT,Wl,Fl,Si)

    oType=fi(0,Si,Wl,Fl);
    fType=fi(0,0,32,31);
    bpType=fi(0,0,Wl,0);
    tableidx={fi((0:2^Wl-1),bpType.numerictype)};

    Fsat=fimath('RoundMode','Nearest',...
    'OverflowMode','Saturate',...
    'SumMode','KeepLSB',...
    'SumWordLength',Wl,...
    'SumFractionLength',Fl,...
    'CastBeforeSum',true);

    tabledata=fi(LUT,oType.numerictype,Fsat);
end


function signal=dataSignal(topNet,name,inType,rate)
    signal=topNet.addSignal(inType,name);
    signal.SimulinkRate=rate;
end
