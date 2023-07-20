function serializer1DComp=getSerializer1DComp(varargin)



















    CInfo=serializerArgs(varargin{:});
    hN=CInfo.hN;
    hInSignals=CInfo.hInSignals;
    hOutSignals=CInfo.hOutSignals;


    hInType=hInSignals(1).Type;
    dimLenIn=double(max(hInType.getDimensions));


    hOutType=hOutSignals(1).Type;
    dimLenOut=double(max(hOutType.getDimensions));


    serLen=CInfo.RatioValue;


    serWidth=dimLenOut;
    serLenWithIdle=serLen+CInfo.IdleCyclesValue;%#ok<NASGU>


    hInSignalsRatePropOthers=[];
    fastRate=hOutSignals(1).SimulinkRate;
    for i=2:length(hInSignals)
        control_in=hN.addSignal(hInSignals(i).Type,sprintf('control_in_%d',i));
        control_in.SimulinkRate=hOutSignals(1).SimulinkRate;
        pirelab.getWireComp(hN,hInSignals(i),control_in);
        hInSignalsRatePropOthers=[hInSignalsRatePropOthers,control_in];%#ok<AGROW>
    end



    hOutSignalsContl=hOutSignals(2:end);
    [SerializerContlComp,in_vld]=getSerializerContlComp(CInfo,hN,fastRate,hInSignalsRatePropOthers,hOutSignalsContl);
    [clock,enable,reset]=hN.getClockBundle(hOutSignals(1),1,1,0);
    SerializerContlComp.connectClockBundle(clock,enable,reset);

    if CInfo.RatioValue==1
        serializer1DComp=pirelab.getWireComp(hN,hInSignals(1),hOutSignals(1));
    else

        if serWidth==1

            serial_in=hN.addSignal(hInSignals(1).Type,'serial_in_1');
            serial_in.SimulinkRate=fastRate;
            pirelab.getWireComp(hN,hInSignals(1),serial_in);
            hInSignalsRateProp=[serial_in,hInSignalsRatePropOthers];

            serializer1DComp=getSerializerScalarComp(CInfo,hN,hInSignalsRateProp,hOutSignals(1),in_vld);

        else

            hDataType=hInType.BaseType;

            demuxOutSigs=hdlhandles(dimLenIn,1);
            for ii=1:dimLenIn
                demuxOutSigs(ii)=hN.addSignal(hDataType,sprintf('%s_in_%d',CInfo.compName,ii));
            end
            pirelab.getDemuxComp(hN,hInSignals(1),demuxOutSigs);


            muxOutType=pirelab.getPirVectorType(hDataType,serLen);


            serialOutSigs=hdlhandles(serWidth,1);

            if~isempty(hInSignalsRatePropOthers)
                inportNames={'InSignals','valid_in','ctrl_valid'};
                inportTypes=[muxOutType,in_vld.Type,hInSignals(2).Type];
                inportRates=[fastRate,fastRate,fastRate];
            else
                inportNames={'InSignals','valid_in'};
                inportTypes=[muxOutType,in_vld.Type];
                inportRates=[fastRate,fastRate];
            end

            hNewNet=pirelab.createNewNetwork(...
            'Network',hN,...
            'Name','SerializerSubNetwork',...
            'InportNames',inportNames,...
            'InportTypes',inportTypes,...
            'InportRates',inportRates,...
            'OutportNames',{'OutputSignal'},...
            'OutportTypes',hDataType);

            InSigs=hNewNet.PirInputSignals;
            OutSig=hNewNet.PirOutputSignals;

            if(length(InSigs)>2)
                getSerializerScalarComp(CInfo,hNewNet,[InSigs(1),InSigs(2)],OutSig,InSigs(3));
            else
                getSerializerScalarComp(CInfo,hNewNet,InSigs(1),OutSig,InSigs(2));
            end

            for ii=1:serWidth


                muxInSigs=hdlhandles(serLen,1);
                for jj=1:serLen
                    muxInSigs(jj)=demuxOutSigs(ii+(jj-1)*serWidth);
                end


                muxOutSigs=hN.addSignal(muxOutType,sprintf('%s_muxout',CInfo.compName));
                pirelab.getConcatenateComp(hN,muxInSigs,muxOutSigs,'Vector','1',sprintf('%s_mux',CInfo.compName));


                serialOutSigs(ii)=hN.addSignal(hDataType,sprintf('%s_out_%d',CInfo.compName,ii));

                serial_in=hN.addSignal(muxOutType,sprintf('serial_in_1_muxOut%d',ii));
                serial_in.SimulinkRate=hOutSignals(1).SimulinkRate;
                pirelab.getWireComp(hN,muxOutSigs,serial_in);
                hInSignalsRateProp=[serial_in,hInSignalsRatePropOthers];

                serializer1DComp=pirelab.instantiateNetwork(hN,hNewNet,[hInSignalsRateProp,in_vld],serialOutSigs(ii),[hNewNet.Name,'_inst']);
            end


            pirelab.getConcatenateComp(hN,serialOutSigs,hOutSignals(1),'Vector','1');

        end
    end

end


function[SerializerContlComp,in_vld]=getSerializerContlComp(CInfo,hN,fastRate,hInSignalsRatePropOthers,hOutSignalsContl)

    serializerContlParams={CInfo.RatioValue,CInfo.IdleCyclesValue,CInfo.hasValidInSignal,CInfo.hasStartOutSignal,CInfo.hasValidOutSignal};

    in_vld_Type=pir_boolean_t;
    in_vld=hN.addSignal(in_vld_Type,sprintf('%s_invldSignal',CInfo.compName));
    in_vld.SimulinkRate=fastRate;

    SerializerContlComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',sprintf('%s_contl',CInfo.compName),...
    'InputSignals',hInSignalsRatePropOthers,...
    'OutputSignals',[in_vld,hOutSignalsContl],...
    'EMLParams',serializerContlParams,...
    'EMLFileName','hdleml_serializer1DContl',...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false);

end



function serializerComp=getSerializerScalarComp(CInfo,hN,hInSignalsRateProp,DataOutSignals,in_vld)

    serializerParams={CInfo.RatioValue};


    serializerComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',CInfo.compName,...
    'InputSignals',[in_vld,hInSignalsRateProp],...
    'OutputSignals',DataOutSignals,...
    'EMLParams',serializerParams,...
    'EMLFileName','hdleml_serializer1D',...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false);

    if targetmapping.isValidDataType(DataOutSignals.Type)
        serializerComp.setSupportTargetCodGenWithoutMapping(true);
    end
    [clock,enable,reset]=hN.getClockBundle(hInSignalsRateProp(1),1,1,0);
    serializerComp.connectClockBundle(clock,enable,reset);

end


function CInfo=serializerArgs(varargin)


    persistent myParser;
    if isempty(myParser)
        myParser=inputParser;
        myParser.addParamValue('Network',[]);
        myParser.addParamValue('Name','Serializer1D');
        myParser.addParamValue('DatainSignal',[]);
        myParser.addParamValue('validInSignal',[]);
        myParser.addParamValue('DataoutSignal',[]);
        myParser.addParamValue('startOutSignal',[]);
        myParser.addParamValue('validOutSignal',[]);
        myParser.addParamValue('Ratio',1);
        myParser.addParamValue('IdleCycles',0);
    end

    myParser.parse(varargin{:});
    arg=myParser.Results;


    if isempty(arg.Network)||isempty(arg.DatainSignal)||isempty(arg.DataoutSignal)
        error(message('hdlcommon:hdlcommon:MissingInput1',arg.Name));
    end



    CInfo.hN=arg.Network;
    CInfo.compName=arg.Name;
    CInfo.hDatainSignal=arg.DatainSignal;
    CInfo.hValidInSignal=arg.validInSignal;
    CInfo.hDataoutSignal=arg.DataoutSignal;
    CInfo.hStartOutSignal=arg.startOutSignal;
    CInfo.hValidOutSignal=arg.validOutSignal;
    CInfo.RatioValue=arg.Ratio;
    CInfo.IdleCyclesValue=arg.IdleCycles;



    CInfo=initInputSignals(CInfo);
    CInfo=initOutputSignals(CInfo);

end


function CInfo=initInputSignals(CInfo)

    hInSignals=[];
    hInSignals=[hInSignals,CInfo.hDatainSignal];

    CInfo.hasValidInSignal=false;
    if~isempty(CInfo.hValidInSignal)
        CInfo.hasValidInSignal=true;
        hInSignals=[hInSignals,CInfo.hValidInSignal];
    end

    CInfo.hInSignals=hInSignals;

end



function CInfo=initOutputSignals(CInfo)

    hOutSignals=[];
    hOutSignals=[hOutSignals,CInfo.hDataoutSignal];

    CInfo.hasStartOutSignal=false;
    CInfo.hasValidOutSignal=false;

    if~isempty(CInfo.hStartOutSignal)
        CInfo.hasStartOutSignal=true;
        hOutSignals=[hOutSignals,CInfo.hStartOutSignal];
    end

    if~isempty(CInfo.hValidOutSignal)
        CInfo.hasValidOutSignal=true;
        hOutSignals=[hOutSignals,CInfo.hValidOutSignal];
    end

    CInfo.hOutSignals=hOutSignals;
end



