function deserializerComp=getDeserializerComp(hN,hInSignals,hOutSignals,compName,idleCycles)












    if(nargin<4)
        compName='deserializer';
    end

    if nargin<5||isempty(idleCycles)
        idleCycles=0;
    end


    hInType=hInSignals.Type;
    dimLenIn=double(max(hInType.getDimensions));


    hOutType=hOutSignals.Type;
    dimLenOut=double(max(hOutType.getDimensions));


    deserLen=dimLenOut/dimLenIn;
    deserLenWithIdle=deserLen+idleCycles;


    deserWidth=dimLenIn;


    if dimLenOut==1||dimLenIn==dimLenOut
        deserializerComp=pirelab.getWireComp(hN,hInSignals,hOutSignals);
    else

        [~,out_vld]=hN.getClockBundle(hInSignals,1,deserLenWithIdle,1);

        if deserWidth==1
            deserializerComp=getDeserializerScalarComp(hN,hInSignals,hOutSignals,...
            out_vld,deserLenWithIdle,idleCycles,compName);

        else

            hDataType=hOutType.BaseType;


            indemuxOutSigs=hdlhandles(dimLenIn,1);
            for ii=1:dimLenIn
                indemuxOutSigs(ii)=hN.addSignal(hDataType,sprintf('%s_in_%d',compName,ii));
            end
            pirelab.getDemuxComp(hN,hInSignals,indemuxOutSigs);


            deserOutType=pirelab.getPirVectorType(hDataType,deserLen);


            muxInSigs=hdlhandles(dimLenOut,1);
            for ii=1:dimLenOut
                muxInSigs(ii)=hN.addSignal(hDataType,sprintf('%s_out_%d',compName,ii));
            end


            for ii=1:deserWidth


                deserialOutSigs=hN.addSignal(deserOutType,sprintf('%s_deser_%d',compName,ii));
                deserializerComp=getDeserializerScalarComp(hN,indemuxOutSigs(ii),deserialOutSigs,...
                out_vld,deserLenWithIdle,idleCycles,compName);


                outdemuxOutSigs=hdlhandles(deserLen,1);
                for jj=1:deserLen
                    outdemuxOutSigs(jj)=muxInSigs(ii+(jj-1)*deserWidth);
                end
                pirelab.getDemuxComp(hN,deserialOutSigs,outdemuxOutSigs);
            end


            pirelab.getMuxComp(hN,muxInSigs,hOutSignals);

        end
    end


    function deserializerComp=getDeserializerScalarComp(hN,hInSignals,hOutSignals,out_vld,deserLen,idleCycles,compName)


        hOutType=hOutSignals.Type;

        fullSize=hOutType.getDimensions+idleCycles;
        fullType=pirelab.getPirVectorType(hOutType.BaseType,fullSize);
        tapdelay_out=hN.addSignal(fullType,sprintf('%s_tapout',compName));


        deserializerComp=pireml.getTapDelayComp(hN,hInSignals,tapdelay_out,deserLen,sprintf('%s_tap',compName));


        if idleCycles>0
            ignoreType=pirelab.getPirVectorType(hOutType.BaseType,idleCycles);
            deserOut=hN.addSignal(hOutType,sprintf('%s_deser',compName));
            ignoreOut=hN.addSignal(ignoreType,sprintf('%s_ignore',compName));
            hDemuxOutSignals=[deserOut,ignoreOut];
            pirelab.getDemuxComp(hN,tapdelay_out,hDemuxOutSignals,sprintf('%s_demux',compName));
        else
            deserOut=tapdelay_out;
        end


        pireml.getBypassRegisterComp(hN,deserOut,hOutSignals,out_vld);
        if targetmapping.isValidDataType(hInSignals(1).Type)
            deserializerComp.setSupportTargetCodGenWithoutMapping(true);
        end


        hOutSignals.SimulinkRate=hInSignals.SimulinkRate*deserLen;



