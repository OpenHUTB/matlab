function deserializer1DComp=getDeserializer1DComp(varargin)




















    CInfo=deserializerArgs(varargin{:});
    hN=CInfo.hN;
    hInSignals=CInfo.hInSignals;
    hOutSignals=CInfo.hOutSignals;


    hInType=hInSignals(1).Type;
    dimLenIn=double(max(hInType.getDimensions));


    hOutType=hOutSignals(1).Type;
    dimLenOut=double(max(hOutType.getDimensions));


    deserLen=CInfo.RatioValue;


    deserWidth=dimLenIn;

    Contl_Type=pir_boolean_t;


    hInSignalsOthers=[];
    if length(hInSignals)>1
        hInSignalsOthers=hInSignals(2:end);
    end
    if CInfo.hasValidOutSignal
        hOutSignalsContl=hN.addSignal(Contl_Type,sprintf('%s_hOutSignalsContl',CInfo.compName));
        hOutSignalsContl.SimulinkRate=hInSignals(1).SimulinkRate;
    else
        hOutSignalsContl=[];
    end

    [DeserializerContlComp,innerReg_en,innerRegCtrol_en,outBypass_en,tapDelay_en]=...
    getDeserializerContlComp(CInfo,hN,hInSignals(1).SimulinkRate,...
    hInSignalsOthers,hOutSignalsContl,Contl_Type);
    [clock,enable,reset]=hN.getClockBundle(hInSignals(1),1,1,0);
    DeserializerContlComp.connectClockBundle(clock,enable,reset);

    tapDelay_en_toggle=hN.addSignal(Contl_Type,sprintf('%s_tapDelayEn',CInfo.compName));
    pireml.getLogicComp(hN,[enable,tapDelay_en],tapDelay_en_toggle,'&');

    if CInfo.hasValidOutSignal
        outProcess(CInfo,hN,hOutSignalsContl,hOutSignals(2),innerRegCtrol_en,outBypass_en,0);
    end


    if deserWidth==1
        deserializer1DComp=getDeserializerScalarComp(CInfo,hN,hInSignals(1),...
        hOutSignals(1),innerReg_en,tapDelay_en_toggle,outBypass_en);

    else

        hDataType=hOutType.BaseType;


        indemuxOutSigs=hdlhandles(dimLenIn,1);
        for ii=1:dimLenIn
            indemuxOutSigs(ii)=hN.addSignal(hDataType,sprintf('%s_in_%d',CInfo.compName,ii));
        end
        pirelab.getDemuxComp(hN,hInSignals,indemuxOutSigs);


        deserOutType=pirelab.getPirVectorType(hDataType,deserLen);

        fastRate=hInSignals(1).SimulinkRate;

        hNewNet=pirelab.createNewNetwork(...
        'Network',hN,...
        'Name','DeserializerSubNetwork',...
        'InportNames',{'InSignal','innerReg_en','tapDelay_en_toggle','outBypass_en'},...
        'InportTypes',[hDataType,Contl_Type,Contl_Type,Contl_Type],...
        'InportRates',[fastRate,fastRate,fastRate,fastRate],...
        'OutportNames',{'OutputSignal'},...
        'OutportTypes',deserOutType);

        InSigs=hNewNet.PirInputSignals;
        OutSig=hNewNet.PirOutputSignals;


        getDeserializerScalarComp(CInfo,hNewNet,InSigs(1),OutSig,InSigs(2),InSigs(3),InSigs(4));


        outdemuxOutSigs=hdlhandles(deserWidth,1);
        for ii=1:deserWidth
            outdemuxOutSigs(ii)=hN.addSignal(deserOutType,sprintf('%s_out_%d',CInfo.compName,ii));
        end


        for ii=1:deserWidth


            deserialOutSigs=hN.addSignal(deserOutType,sprintf('%s_deser_%d',CInfo.compName,ii));

            hInSignalsProp=indemuxOutSigs(ii);

            deserializer1DComp=pirelab.instantiateNetwork(hN,hNewNet,[hInSignalsProp,innerReg_en,tapDelay_en_toggle,outBypass_en],deserialOutSigs,[hNewNet.Name,'_inst']);

            outdemuxOutSigs(ii)=deserialOutSigs;

        end

        if deserLen==1
            pirelab.getConcatenateComp(hN,outdemuxOutSigs,hOutSignals(1),'Vector','1');
        else








            concatType=pirelab.createPirArrayType(hDataType,[deserOutType.Dimensions,deserWidth]);
            transposeType=pirelab.createPirArrayType(hDataType,[deserWidth,deserOutType.Dimensions]);

            concatout=hN.addSignal(concatType,sprintf('%s_out_%d',CInfo.compName,ii));
            transposeOut=hN.addSignal(transposeType,sprintf('%s_out_%d',CInfo.compName,ii));

            pirelab.getConcatenateComp(hN,outdemuxOutSigs,concatout,'Multidimensional array','2');

            pireml.getTransposeComp(hN,concatout,transposeOut,[CInfo.compName,'_transpose']);

            pirelab.getReshapeComp(hN,transposeOut,hOutSignals(1),[CInfo.compName,'_Reshape']);
        end

    end

end



function[DeserializerContlComp,innerReg_en,innerRegCtrol_en,...
    outBypass_en,tapDelay_en]=...
    getDeserializerContlComp(CInfo,hN,fastRate,hInSignalsOthers,hOutSignalsContl,Contl_Type)

    deserializerContlParams={CInfo.RatioValue,CInfo.IdleCyclesValue,CInfo.hasStartInSignal,...
    CInfo.hasValidInSignal,CInfo.hasValidOutSignal};

    innerReg_en=hN.addSignal(Contl_Type,sprintf('%s_innerRegEn',CInfo.compName));
    innerReg_en.SimulinkRate=fastRate;
    innerRegCtrol_en=hN.addSignal(Contl_Type,sprintf('%s_innerRegCtrolEn',CInfo.compName));
    innerRegCtrol_en.SimulinkRate=fastRate;
    outBypass_en=hN.addSignal(Contl_Type,sprintf('%s_outBypassEn',CInfo.compName));
    outBypass_en.SimulinkRate=fastRate;
    tapDelay_en=hN.addSignal(Contl_Type,sprintf('%s_tapDelayEn',CInfo.compName));
    tapDelay_en.SimulinkRate=fastRate;

    DeserializerContlComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',sprintf('%s_contl',CInfo.compName),...
    'InputSignals',hInSignalsOthers,...
    'OutputSignals',[innerReg_en,innerRegCtrol_en,outBypass_en,tapDelay_en,hOutSignalsContl],...
    'EMLParams',deserializerContlParams,...
    'EMLFileName','hdleml_deserializer1DContl',...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false);
end


function deserializer1DComp=getDeserializerScalarComp(CInfo,hN,hInSignalsProp,...
    DataOutSignals,innerReg_en,tapDelay_en_toggle,outBypass_en)


    tapdelayLength=CInfo.RatioValue-1;

    initValScalar=CInfo.InitialValue(1);

    if tapdelayLength>0
        tapdelayOutType=pirelab.getPirVectorType(hInSignalsProp.Type,tapdelayLength);
        tapdelay_out=hN.addSignal(tapdelayOutType,sprintf('%s_tapout',CInfo.compName));

        initVal=repmat(initValScalar,1,tapdelayLength);
        initVal=reshape(pirelab.getTypeInfoAsFi(hInSignalsProp.Type,...
        'Floor','Wrap',initVal,false),1,tapdelayLength);
        hN.setHasSLHWFriendlySemantics(true);
        deserializer1DComp=pireml.getTapDelayEnabledResettableComp(hN,hInSignalsProp,...
        tapdelay_out,tapdelayLength,sprintf('%s_tapDelayComp',CInfo.compName),...
        initVal,true,false,false,tapDelay_en_toggle);
    end

    if tapdelayLength>0
        muxInSigs=[tapdelay_out,hInSignalsProp];
    else
        muxInSigs=hInSignalsProp;
    end

    signalsToOut=hN.addSignal(DataOutSignals.Type,sprintf('%s_muxOut',CInfo.compName));
    muxComp=pirelab.getConcatenateComp(hN,muxInSigs,signalsToOut,'Vector','1');

    if tapdelayLength==0
        deserializer1DComp=muxComp;
    end

    if targetmapping.isValidDataType(hInSignalsProp.Type)
        deserializer1DComp.setSupportTargetCodGenWithoutMapping(true);
    end

    outProcess(CInfo,hN,signalsToOut,DataOutSignals,innerReg_en,outBypass_en,initValScalar);
end



function outProcess(CInfo,hN,prevOut,OutSignals,innerReg_en,outBypass_en,initVal)

    hT=OutSignals.Type;
    [dimlen,~]=pirelab.getVectorTypeInfo(OutSignals);

    if isscalar(dimlen)
        dimlen=[1,dimlen];
    end
    initVal=repmat(initVal,dimlen);
    initVal=reshape(pirelab.getTypeInfoAsFi(hT,'Floor','Wrap',initVal),dimlen);

    if~CInfo.hasStartInSignal&&~CInfo.hasValidInSignal
        if CInfo.IdleCyclesValue==0

            pireml.getUnitDelayEnabledComp(hN,prevOut,OutSignals,innerReg_en,...
            sprintf('%s_regComp',CInfo.compName),initVal);
        else
            deserInnerOut=hN.addSignal(prevOut.Type,sprintf('%s_deserInnerOut',CInfo.compName));

            pireml.getUnitDelayEnabledComp(hN,prevOut,deserInnerOut,innerReg_en,...
            sprintf('%s_innerRegComp',CInfo.compName),initVal);


            pireml.getUnitDelayEnabledComp(hN,deserInnerOut,OutSignals,...
            outBypass_en,sprintf('%s_OutRegComp',CInfo.compName),initVal);

        end
    else
        deserInnerOut=hN.addSignal(prevOut.Type,sprintf('%s_deserInnerOut',CInfo.compName));

        pireml.getUnitDelayEnabledComp(hN,prevOut,deserInnerOut,innerReg_en,...
        sprintf('%s_innerRegComp',CInfo.compName),initVal);


        outBypassComp=pireml.getBypassRegisterComp(hN,deserInnerOut,OutSignals,...
        outBypass_en,sprintf('%s_OutRegComp',CInfo.compName),initVal);
        [clock,enable,reset]=hN.getClockBundle(prevOut(1),1,1,0);
        outBypassComp.connectClockBundle(clock,enable,reset);
    end


    deserLenWithIdle=CInfo.RatioValue+CInfo.IdleCyclesValue;
    OutSignals.SimulinkRate=prevOut(1).SimulinkRate*deserLenWithIdle;
end



function CInfo=deserializerArgs(varargin)


    persistent myParser;
    if isempty(myParser)
        myParser=inputParser;
        myParser.addParameter('Network',[]);
        myParser.addParameter('Name','Deserializer1D');
        myParser.addParameter('DatainSignal',[]);
        myParser.addParameter('startInSignal',[]);
        myParser.addParameter('validInSignal',[]);
        myParser.addParameter('DataoutSignal',[]);
        myParser.addParameter('validOutSignal',[]);
        myParser.addParameter('Ratio',1);
        myParser.addParameter('IdleCycles',0);
        myParser.addParameter('InitialValue',0);
    end

    myParser.parse(varargin{:});
    arg=myParser.Results;


    if isempty(arg.Network)||isempty(arg.DatainSignal)||isempty(arg.DataoutSignal)
        error(message('hdlcommon:hdlcommon:MissingInput1',arg.Name));
    end


    CInfo.hN=arg.Network;
    CInfo.compName=arg.Name;
    CInfo.hDatainSignal=arg.DatainSignal;
    CInfo.hStartInSignal=arg.startInSignal;
    CInfo.hValidInSignal=arg.validInSignal;
    CInfo.hDataoutSignal=arg.DataoutSignal;
    CInfo.hValidOutSignal=arg.validOutSignal;
    CInfo.RatioValue=arg.Ratio;
    CInfo.IdleCyclesValue=arg.IdleCycles;
    CInfo.InitialValue=arg.InitialValue;



    CInfo=initInputSignals(CInfo);
    CInfo=initOutputSignals(CInfo);
end



function CInfo=initInputSignals(CInfo)

    hInSignals=[];
    hInSignals=[hInSignals,CInfo.hDatainSignal];

    CInfo.hasStartInSignal=false;
    CInfo.hasValidInSignal=false;

    if~isempty(CInfo.hStartInSignal)
        CInfo.hasStartInSignal=true;
        hInSignals=[hInSignals,CInfo.hStartInSignal];
    end

    if~isempty(CInfo.hValidInSignal)
        CInfo.hasValidInSignal=true;
        hInSignals=[hInSignals,CInfo.hValidInSignal];
    end

    CInfo.hInSignals=hInSignals;
end



function CInfo=initOutputSignals(CInfo)
    hOutSignals=[];
    hOutSignals=[hOutSignals,CInfo.hDataoutSignal];

    CInfo.hasValidOutSignal=false;

    if~isempty(CInfo.hValidOutSignal)
        CInfo.hasValidOutSignal=true;
        hOutSignals=[hOutSignals,CInfo.hValidOutSignal];
    end

    CInfo.hOutSignals=hOutSignals;
end


