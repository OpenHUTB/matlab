function populateExternalPorts(obj,hN,hChannel)





    if hChannel.ChannelDirType==hdlturnkey.IOType.OUT
        busOutPortList={...
        {'AWID',hChannel.AXIIDWidth,1},...
        {'AWADDR',obj.AddrWidth,1},...
        {'AWLEN',obj.AXILenWidth,1},...
        {'AWSIZE',3,1},...
        {'AWBURST',2,1},...
        {'AWLOCK',1,1},...
        {'AWCACHE',4,1},...
        {'AWPROT',3,1},...
        {'AWVALID',1,1},...
        {'WDATA',hChannel.AXIDataWidth,hChannel.AXIDataDimension},...
        {'WSTRB',hChannel.NumDataBytes,1},...
        {'WLAST',1,1},...
        {'WVALID',1,1},...
        {'BREADY',1,1},...
        };
        busInPortList={...
        {'AWREADY',1,1},...
        {'WREADY',1,1},...
        {'BID',hChannel.AXIIDWidth,1},...
        {'BRESP',2,1},...
        {'BVALID',1,1},...
        };

    else
        busOutPortList={...
        {'ARID',hChannel.AXIIDWidth,1},...
        {'ARADDR',obj.AddrWidth,1},...
        {'ARLEN',obj.AXILenWidth,1},...
        {'ARSIZE',3,1},...
        {'ARBURST',2,1},...
        {'ARLOCK',1,1},...
        {'ARCACHE',4,1},...
        {'ARPROT',3,1},...
        {'ARVALID',1,1},...
        {'RREADY',1,1},...
        };
        busInPortList={...
        {'RDATA',hChannel.AXIDataWidth,hChannel.AXIDataDimension},...
        {'RLAST',1,1},...
        {'RVALID',1,1},...
        {'RID',hChannel.AXIIDWidth,1},...
        {'RRESP',2,1},...
        {'ARREADY',1,1},...
        };
    end

    hChannel.populateBusPortList(busInPortList,busOutPortList);


    hChannel.ExtInportWidthsFlattened=upgradeWidth(obj,...
    numel(hChannel.ExtInportNames),...
    hChannel.ExtInportDimensions,...
    hChannel.ExtInportWidthsFlattened);
    hChannel.ExtOutportWidthsFlattened=upgradeWidth(obj,...
    numel(hChannel.ExtOutportNames),...
    hChannel.ExtOutportDimensions,...
    hChannel.ExtOutportWidthsFlattened);


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
        inportType=pir_ufixpt_t(hChannel.ExtInportWidths{ii},0);
        inportDim=hChannel.ExtInportDimensions{ii};
        inportName=hChannel.ExtInportNames{ii};
        inportBitwidth=hChannel.ExtInportWidths{ii};

        if(inportDim>1)
            port_rdata=hInterfaceSignal.hInportSignals(ii);
            muxInSigs=hdlhandles(1,inportDim);
            for jj=1:inportDim
                muxInName=sprintf('%s_%d',inportName,jj-1);
                muxInSigs(jj)=hN.addSignal(inportType,muxInName);
                pirelab.getBitSliceComp(hN,port_rdata,muxInSigs(jj),...
                inportBitwidth*jj-1,inportBitwidth*(jj-1));
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
        outportType=pir_ufixpt_t(hChannel.ExtOutportWidths{ii},0);
        outportDim=hChannel.ExtOutportDimensions{ii};
        outportName=hChannel.ExtOutportNames{ii};

        if(outportDim>1)

            port_wdata=hInterfaceSignal.hOutportSignals(ii);
            bitConcatInType=pirelab.getPirVectorType(outportType,outportDim);
            bitConcatInName=sprintf('%s_Vec',outportName);
            bitConcatInSigs(ii)=hN.addSignal(bitConcatInType,bitConcatInName);

            expandWidth=hChannel.ExtOutportWidthsFlattened{ii};
            orgWidth=hChannel.ExtOutportWidths{ii}*hChannel.ExtOutportDimensions{ii};
            zeroSigWidth=expandWidth-orgWidth;









            if(zeroSigWidth>0)





                constMaxBitWidth=128;
                ceilDim=ceil(zeroSigWidth/constMaxBitWidth);
                residualBitWidth=mod(zeroSigWidth,constMaxBitWidth);

                demuxOutSigs=hdlhandles(1,outportDim+ceilDim);
                demuxOutSigs(1)=hN.addSignal(pir_ufixpt_t(residualBitWidth,0),'zeroSig');
                pirelab.getConstComp(hN,demuxOutSigs(1),0);

                for jj=2:ceilDim
                    zeroSigName=sprintf('zeroSig_%d',jj-1);
                    demuxOutSigs(jj)=hN.addSignal(pir_ufixpt_t(constMaxBitWidth,0),zeroSigName);
                    pirelab.getConstComp(hN,demuxOutSigs(jj),0);
                end

                if(isempty(jj))
                    prev_jj=2;
                else
                    prev_jj=jj+1;
                end
                startInd=prev_jj;
                endInd=outportDim+ceilDim;
            else
                demuxOutSigs=hdlhandles(1,outportDim);
                startInd=1;
                endInd=outportDim;
            end


            for jj=startInd:endInd
                demuxInName=sprintf('%s_%d',outportName,jj-startInd);
                demuxOutSigs(jj)=hN.addSignal(outportType,demuxInName);
            end
            pirelab.getDemuxComp(hN,bitConcatInSigs(ii),flip(demuxOutSigs(startInd:endInd)));
            pirelab.getBitConcatComp(hN,demuxOutSigs,port_wdata);

        else
            bitConcatInSigs(ii)=hInterfaceSignal.hOutportSignals(ii);
        end
    end



    hChannel.ExtTopInportSignals=muxOutSigs;
    hChannel.ExtTopOutportSignals=bitConcatInSigs;

end





