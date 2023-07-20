function serializerComp=getSerializerComp(hN,hInSignals,hOutSignals,compName,idleCycles)





















    if nargin<4
        compName='serializer';
    end

    if nargin<5||isempty(idleCycles)
        idleCycles=0;
    end


    hInType=hInSignals.Type;
    dimLenIn=double(max(hInType.getDimensions));


    hOutType=hOutSignals(1).Type;
    dimLenOut=double(max(hOutType.getDimensions));


    serLen=dimLenIn/dimLenOut;
    serLenWithIdle=serLen+idleCycles;


    serWidth=dimLenOut;


    if dimLenIn==1||dimLenIn==dimLenOut
        serializerComp=pirelab.getWireComp(hN,hInSignals,hOutSignals(1));
    else

        [~,in_vld]=hN.getClockBundle(hOutSignals(1),1,serLenWithIdle,1);


        hDataType=hInType.BaseType;

        if serWidth==1
            serializerComp=getSerializerScalarComp(hN,hInSignals,hOutSignals(1),...
            in_vld,serLenWithIdle,idleCycles,compName);

        else

            demuxOutSigs=hdlhandles(dimLenIn,1);
            for ii=1:dimLenIn
                demuxOutSigs(ii)=hN.addSignal(hDataType,sprintf('%s_in_%d',compName,ii));
            end
            pirelab.getDemuxComp(hN,hInSignals,demuxOutSigs);


            muxOutType=pirelab.getPirVectorType(hDataType,serLen);


            serialOutSigs=hdlhandles(serWidth,1);
            for ii=1:serWidth


                muxInSigs=hdlhandles(serLen,1);
                for jj=1:serLen
                    muxInSigs(jj)=demuxOutSigs(ii+(jj-1)*serWidth);
                end


                muxOutSigs=hN.addSignal(muxOutType,sprintf('%s_muxout',compName));
                pirelab.getMuxComp(hN,muxInSigs,muxOutSigs,sprintf('%s_mux',compName));


                serialOutSigs(ii)=hN.addSignal(hDataType,sprintf('%s_out_%d',compName,ii));
                serializerComp=getSerializerScalarComp(hN,muxOutSigs,serialOutSigs(ii),...
                in_vld,serLenWithIdle,idleCycles,compName);
            end


            pirelab.getMuxComp(hN,serialOutSigs,hOutSignals(1));

        end
    end


    need_dvalid=length(hOutSignals)>1;
    if need_dvalid
        pirelab.getWireComp(hN,in_vld,hOutSignals(2));
    end



    function serializerComp=getSerializerScalarComp(hN,hInSignals,hOutSignals,in_vld,serLen,idleCycles,compName)


        serial_in=hN.addSignal(hInSignals.Type,'serial_in');
        serial_in.SimulinkRate=hInSignals.SimulinkRate/serLen;
        pirelab.getWireComp(hN,hInSignals,serial_in);


        in_vld_bypass=hN.addSignal(in_vld.Type,'in_vld');
        [~,hByPassEnb]=hN.getClockBundle(serial_in,1,1,1);
        pireml.getBypassRegisterComp(hN,in_vld,in_vld_bypass,hByPassEnb,sprintf('%s_bypass',compName));

        scalarZero=pirelab.getTypeInfoAsFi(serial_in.Type.BaseType);
        len=serial_in.Type.Dimensions+idleCycles-1;
        initValue=repmat(scalarZero,len,1);

        serializerComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'InputSignals',[serial_in,in_vld_bypass],...
        'OutputSignals',hOutSignals,...
        'EMLParams',{idleCycles,initValue},...
        'EMLFileName','hdleml_serializer',...
        'EMLFlag_RunLoopUnrolling',false);

        if targetmapping.isValidDataType(hOutSignals(1).Type)
            serializerComp.setSupportTargetCodGenWithoutMapping(true);
        end
        [clock,enable,reset]=hN.getClockBundle(serial_in,1,1,0);
        serializerComp.connectClockBundle(clock,enable,reset);



