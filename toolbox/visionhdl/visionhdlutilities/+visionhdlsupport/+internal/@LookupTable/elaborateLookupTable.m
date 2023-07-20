function topNet=elaborateLookupTable(~,topNet,blockInfo,insignals,outsignals)







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


    [Wl,Fl,Si]=visionhdlshared.hdlgetwordsizefromdata_nt(blockInfo.LUT);
    hT=dataIn.Type;

    if hT.isArrayType


        if Si
            LUTOutType=pirelab.createPirArrayType(pir_sfixpt_t(Wl,-Fl),hT.Dimensions);
        else
            LUTOutType=pirelab.createPirArrayType(pir_ufixpt_t(Wl,-Fl),hT.Dimensions);
        end


        LUTAddrType=pirelab.createPirArrayType(pir_ufixpt_t(dataIn.Type.BaseType.WordLength,0),hT.Dimensions);
    else
        LUTAddrType=pir_ufixpt_t(dataIn.Type.WordLength,0);
        if Si
            LUTOutType=pir_sfixpt_t(Wl,-Fl);
        else
            LUTOutType=pir_ufixpt_t(Wl,-Fl);
        end
    end
    lutaddr=topNet.addSignal2('Type',LUTAddrType);
    lutoutput=topNet.addSignal2('Type',LUTOutType);
    lutoutreg=topNet.addSignal2('Type',LUTOutType);
    lutoutreg1=topNet.addSignal2('Type',LUTOutType);

    regcomp=pirelab.getDTCComp(topNet,dataIn,lutaddr,'Nearest','Wrap','SI');
    regcomp.addComment('convert dataIn to LUT address');

    [tabledata,tableidx,bpType,oType,fType]=ComputeLUT(blockInfo.LUT,Wl,Fl,Si,dataIn.Type.BaseType.WordLength);

    if lutaddr.Type.BaseType.WordLength==1

        if lutaddr.Type.Dimensions==4
            lutaddr1=topNet.addSignal2('Type',lutaddr.Type.BaseType);
            lutaddr2=topNet.addSignal2('Type',lutaddr.Type.BaseType);
            lutaddr3=topNet.addSignal2('Type',lutaddr.Type.BaseType);
            lutaddr4=topNet.addSignal2('Type',lutaddr.Type.BaseType);
            lutout1=topNet.addSignal2('Type',lutoutput.Type.BaseType);
            lutout2=topNet.addSignal2('Type',lutoutput.Type.BaseType);
            lutout3=topNet.addSignal2('Type',lutoutput.Type.BaseType);
            lutout4=topNet.addSignal2('Type',lutoutput.Type.BaseType);
            regcomp=pirelab.getDemuxComp(topNet,lutaddr,[lutaddr1,lutaddr2,lutaddr3,lutaddr4],'Demux');
            regcomp.addComment('split input');
            regcomp=pirelab.getDemuxComp(topNet,lutoutput,[lutout1,lutout2,lutout3,lutout4],'Demux');
            regcomp.addComment('split output');
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr1,lutout1,...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('switch1');
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr2,lutout2,...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('switch2');
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr3,lutout3,...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('switch3');
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr4,lutout4,...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('switch4');
            regcomp=pirelab.getMuxComp(topNet,[lutout1,lutout2,lutout3,lutout4],lutoutput,'mux');
            regcomp.addComment('MuxComp');
        end

        if lutaddr.Type.Dimensions==8
            lutaddr1=topNet.addSignal2('Type',lutaddr.Type.BaseType);
            lutaddr2=topNet.addSignal2('Type',lutaddr.Type.BaseType);
            lutaddr3=topNet.addSignal2('Type',lutaddr.Type.BaseType);
            lutaddr4=topNet.addSignal2('Type',lutaddr.Type.BaseType);
            lutaddr5=topNet.addSignal2('Type',lutaddr.Type.BaseType);
            lutaddr6=topNet.addSignal2('Type',lutaddr.Type.BaseType);
            lutaddr7=topNet.addSignal2('Type',lutaddr.Type.BaseType);
            lutaddr8=topNet.addSignal2('Type',lutaddr.Type.BaseType);
            lutout1=topNet.addSignal2('Type',lutoutput.Type.BaseType);
            lutout2=topNet.addSignal2('Type',lutoutput.Type.BaseType);
            lutout3=topNet.addSignal2('Type',lutoutput.Type.BaseType);
            lutout4=topNet.addSignal2('Type',lutoutput.Type.BaseType);
            lutout5=topNet.addSignal2('Type',lutoutput.Type.BaseType);
            lutout6=topNet.addSignal2('Type',lutoutput.Type.BaseType);
            lutout7=topNet.addSignal2('Type',lutoutput.Type.BaseType);
            lutout8=topNet.addSignal2('Type',lutoutput.Type.BaseType);

            regcomp=pirelab.getDemuxComp(topNet,lutaddr,[lutaddr1,lutaddr2,lutaddr3,lutaddr4,lutaddr5,lutaddr6,lutaddr7,lutaddr8],'Demux');
            regcomp.addComment('split input');
            regcomp=pirelab.getDemuxComp(topNet,lutoutput,[lutout1,lutout2,lutout3,lutout4,lutout5,lutout6,lutout7,lutout8],'Demux');
            regcomp.addComment('split output');
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr1,lutout1,...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('switch1');
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr2,lutout2,...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('switch2');
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr3,lutout3,...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('switch3');
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr4,lutout4,...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('switch4');
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr5,lutout5,...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('switch5');
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr6,lutout6,...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('switch6');
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr7,lutout7,...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('switch7');
            regcomp=pirelab.getLookupNDComp(topNet,lutaddr8,lutout8,...
            tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('switch8');
            regcomp=pirelab.getMuxComp(topNet,[lutout1,lutout2,lutout3,lutout4,lutout5,lutout6,lutout7,lutout8],lutoutput,'mux');
            regcomp.addComment('MuxComp');
        end
    else
        regcomp=pirelab.getLookupNDComp(topNet,lutaddr,lutoutput,...
        tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
        regcomp.addComment('Lookup Table')
    end
    regcomp=pirelab.getUnitDelayComp(topNet,lutoutput,lutoutreg,'LUTRegister',0,blockInfo.resetnone);
    if blockInfo.resetnone
        regcomp.addComment('To infer a RAM, the register following LUT is set to ResetNone');
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

    if blockInfo.delay-2>0
        pirelab.getIntDelayComp(topNet,lutoutreg,lutoutreg1,blockInfo.delay-2,'vEnd');
    else
        lutoutreg1=lutoutreg;
    end

    zeroconst=topNet.addSignal2('Type',LUTOutType);

    pirelab.getConstComp(topNet,zeroconst,0);
    switchout=topNet.addSignal2('Type',LUTOutType);
    pirelab.getSwitchComp(topNet,[zeroconst,lutoutreg1],switchout,dins(1),'holdmux');
    pirelab.getUnitDelayComp(topNet,switchout,dataOut);
    regcomp.addComment('dataOut maintains zero when validIn is low');

    function[tabledata,tableidx,bpType,oType,fType]=ComputeLUT(LUT,Wl,Fl,Si,Addr_Wl)

        oType=fi(0,Si,Wl,Fl);
        fType=fi(0,0,32,31);


        bpType=fi(0,0,Addr_Wl,0);
        tableidx={fi((0:2^Addr_Wl-1),bpType.numerictype)};

        Fsat=fimath('RoundMode','Nearest',...
        'OverflowMode','Saturate',...
        'SumMode','KeepLSB',...
        'SumWordLength',Wl,...
        'SumFractionLength',Fl,...
        'CastBeforeSum',true);

        tabledata=fi(LUT,oType.numerictype,Fsat);
    end
end
