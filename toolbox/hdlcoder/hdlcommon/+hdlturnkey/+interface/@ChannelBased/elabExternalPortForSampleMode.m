function elabExternalPortForSampleMode(hN,hChannel)



    hChannel.FlattenExtportsWidthsandDimensions;


    hInterfaceSignal=pirelab.addIOPortToNetwork(...
    'Network',hN,...
    'InportNames',hChannel.ExtInportNames,...
    'InportWidths',hChannel.ExtInportWidthsFlattened,...
    'InportDimensions',hChannel.ExtInportDimensionsFlattened,...
    'OutportNames',hChannel.ExtOutportNames,...
    'OutportWidths',hChannel.ExtOutportWidthsFlattened,...
    'OutportDimensions',hChannel.ExtOutportDimensionsFlattened);


    hChannelExtInportNums=numel(hChannel.ExtInportNames);
    muxOutSigs=hdlhandles(1,hChannelExtInportNums);
    for ii=1:hChannelExtInportNums
        ElementWidth=hChannel.ExtInportWidths{ii};
        inportType=pir_ufixpt_t(ElementWidth,0);
        inportDim=hChannel.ExtInportDimensions{ii};
        inportName=hChannel.ExtInportNames{ii};
        ChannelWidth=hChannel.ExtInportWidthsFlattened{ii};
        hSubPort=hChannel.getDataPort;
        if hSubPort.isAssigned
            isComplexPort=hSubPort.getAssignedPort.isComplex;
        else
            isComplexPort=0;
        end


        if(inportDim>1)
            port_rdata=hInterfaceSignal.hInportSignals(ii);
            muxInSigs=hdlhandles(1,inportDim);
            PackingMode=hChannel.PackingMode;
            if isComplexPort
                portDimension=inportDim/2;
            else
                portDimension=inportDim;
            end



            [~,TotalElementWidth,totalPortDimension]=hdlshared.internal.VectorStreamUtils.getPackedDataWidth(...
            ElementWidth,portDimension,isComplexPort,PackingMode);


            assert(TotalElementWidth<=ChannelWidth,...
            'Insufficient Channel width specified. Channel width must be more when compared to portWidth of a vector element multiplied by its dimension.');


            lsb=0;
            msb=lsb+ElementWidth-1;


            for jj=1:totalPortDimension
                muxInName=sprintf('%s_%d',inportName,jj-1);
                muxInSigs(jj)=hN.addSignal(inportType,muxInName);
                pirelab.getBitSliceComp(hN,port_rdata,muxInSigs(jj),msb,lsb);



                lsb=lsb+TotalElementWidth;
                msb=lsb+ElementWidth-1;
            end
            muxOutType=pirelab.getPirVectorType(inportType,inportDim);
            muxOutName=sprintf('%s_Vec',inportName);
            muxOutSigs(ii)=hN.addSignal(muxOutType,muxOutName);
            pirelab.getMuxComp(hN,muxInSigs,muxOutSigs(ii));
        else
            muxOutSigs(ii)=hInterfaceSignal.hInportSignals(ii);
        end
    end


    hChannelExtOutportNums=numel(hChannel.ExtOutportNames);
    bitConcatInSigs=hdlhandles(1,hChannelExtOutportNums);
    for ii=1:hChannelExtOutportNums
        portWidth=hChannel.ExtOutportWidths{ii};
        totalPortDimension=hChannel.ExtOutportDimensions{ii};
        outportType=pir_ufixpt_t(portWidth,0);
        outportName=hChannel.ExtOutportNames{ii};
        hSubPort=hChannel.getDataPort;
        if hSubPort.isAssigned
            isComplexPort=hSubPort.getAssignedPort.isComplex;
        else
            isComplexPort=0;
        end

        if(totalPortDimension>1)
            outport_AXIMasterTDATA=hInterfaceSignal.hOutportSignals(ii);
            bitConcatInType=pirelab.getPirVectorType(outportType,totalPortDimension);
            bitConcatInName=sprintf('%s_Vec',outportName);
            bitConcatInSigs(ii)=hN.addSignal(bitConcatInType,bitConcatInName);

            ChannelWidth=hChannel.ExtOutportWidthsFlattened{ii};
            constMaxBitWidth=128;




















            PackingMode=hChannel.PackingMode;
            if isComplexPort
                portDimension=totalPortDimension/2;
            else
                portDimension=totalPortDimension;
            end


            [totalDataWidth,totalPortWidth]=hdlshared.internal.VectorStreamUtils.getPackedDataWidth(...
            portWidth,portDimension,isComplexPort,PackingMode);


            assert(totalDataWidth<=ChannelWidth,...
            'Insufficient Channel width specified. Channel width must be more when compared to portWidth of a vector element multiplied by its dimension.');


            demuxOutSignals=hdlhandles(1,0);
            dutSignals=hdlhandles(1,0);








            portPadWidth=totalPortWidth-portWidth;
            for ll=1:totalPortDimension
                demuxInName=sprintf('%s_%d',outportName,ll-1);
                dutSignals(end+1)=hN.addSignal(outportType,demuxInName);


                demuxOutSignals=[demuxOutSignals,dutSignals(end)];



                zeroSigPrefix=sprintf('zeroSig_element%dPad',ll-1);
                demuxOutSignals=hChannel.leftextend(portPadWidth,hN,zeroSigPrefix,demuxOutSignals);
            end







            dataWidth=totalPortWidth*totalPortDimension;
            byteBoundaryPadWidth=totalDataWidth-dataWidth;



            zeroSigPrefix=sprintf('zeroSig_byteBoundaryPad');
            demuxOutSignals=hChannel.leftextend(byteBoundaryPadWidth,hN,zeroSigPrefix,demuxOutSignals);








            channelPadWidth=ChannelWidth-totalDataWidth;



            zeroSigPrefix=sprintf('zeroSig_ChannelPad');
            demuxOutSignals=hChannel.leftextend(channelPadWidth,hN,zeroSigPrefix,demuxOutSignals);
            pirelab.getDemuxComp(hN,bitConcatInSigs(ii),dutSignals);


            pirelab.getBitConcatComp(hN,flip(demuxOutSignals),outport_AXIMasterTDATA);
        else
            bitConcatInSigs(ii)=hInterfaceSignal.hOutportSignals(ii);
        end
    end


    hChannel.ExtTopInportSignals=muxOutSigs;
    hChannel.ExtTopOutportSignals=bitConcatInSigs;

end