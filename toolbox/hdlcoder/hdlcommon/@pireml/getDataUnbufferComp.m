function serializerComp=getDataUnbufferComp(hN,hInSignals,hOutSignals,ctrInitVal,compName)







    if nargin<5||isempty(compName)
        compName='unbuffer';
    end

    if nargin<4
        ctrInitVal=1;
    end


    hInType=hInSignals.Type;
    dimLenIn=double(max(hInType.getDimensions));


    hOutType=hOutSignals(1).Type;
    dimLenOut=double(max(hOutType.getDimensions));


    serLen=dimLenIn/dimLenOut;


    serWidth=dimLenOut;



    if dimLenIn==1||dimLenIn==dimLenOut
        serializerComp=pirelab.getWireComp(hN,hInSignals,hOutSignals(1));
    else

        hN.getClockBundle(hOutSignals(1),1,serLen,1);


        hDataType=hInType.BaseType;


        ctrSize=max(2,ceil(log2(dimLenIn+2)));

        if serWidth==1
            serializerComp=getUnbufferComp(hN,hInSignals,hOutSignals(1),ctrInitVal,ctrSize,compName);
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
                serializerComp=getUnbufferComp(hN,muxOutSigs,serialOutSigs(ii),ctrInitVal,ctrSize,compName);
            end


            pirelab.getMuxComp(hN,serialOutSigs,hOutSignals(1));

        end
    end




    function unbufferComp=getUnbufferComp(hN,hInSignals,hOutSignals,ctrInitVal,ctrSize,compName)

        if(nargin<5)
            compName='unbuffer';
        end


        unbufferComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'InputSignals',hInSignals,...
        'OutputSignals',hOutSignals,...
        'EMLFileName','hdleml_unbuffer',...
        'EMLParams',{ctrInitVal,ctrSize},...
        'EMLFlag_RunLoopUnrolling',false);

        if targetmapping.isValidDataType(hInSignals(1).Type)
            unbufferComp.setSupportTargetCodGenWithoutMapping(true);
        end
        [clock,enable,reset]=hN.getClockBundle(hInSignals,1,1,0);
        unbufferComp.connectClockBundle(clock,enable,reset);



