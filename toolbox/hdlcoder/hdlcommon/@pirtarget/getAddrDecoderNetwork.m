function[hDecoderNet,muxCounter,readDelayCount]=getAddrDecoderNetwork(...
    hN,topInSignals,topOutSignals,hElab,hAddrLists,networkName,readInitZ)













    if nargin<7
        readInitZ=false;
    end


    top_data_write=topInSignals(1);
    top_addr_sel=topInSignals(2);
    top_wr_enb=topInSignals(3);
    top_rd_enb=topInSignals(4);
    top_data_read=topOutSignals(1);


    hPirInstance=hElab.BoardPirInstance;
    hDecoderNet=pirelab.createNewNetwork(...
    'PirInstance',hPirInstance,...
    'Network',hN,...
    'Name',networkName,...
    'InportNames',{'data_write','addr_sel','wr_enb','rd_enb'},...
    'InportTypes',[top_data_write.Type,top_addr_sel.Type,top_wr_enb.Type,top_rd_enb.Type],...
    'InportRates',[top_data_write.SimulinkRate,top_addr_sel.SimulinkRate,top_wr_enb.SimulinkRate,top_rd_enb.SimulinkRate],...
    'OutportNames',{'data_read'},...
    'OutportTypes',[top_data_read.Type]...
    );
    data_read=hDecoderNet.PirOutputSignals(1);


    pirelab.instantiateNetwork(hN,hDecoderNet,topInSignals,...
    topOutSignals,sprintf('%s_inst',networkName));


    readDataType=top_data_read.Type;

    if readInitZ

        const_z=hDecoderNet.addSignal(readDataType,'const_z');
        pirelab.getConstSpecialComp(hDecoderNet,const_z,'Z');
        hDecodeReadSignal=const_z;
    else

        const_0=hDecoderNet.addSignal(readDataType,'const_0');
        pirelab.getConstComp(hDecoderNet,const_0,0);
        hDecodeReadSignal=const_0;
    end

    muxCounter=0;
    readDelayCount=0;


    for ii=1:length(hAddrLists)
        hAddrList=hAddrLists(ii);

        [hDecodeReadSignal,muxCounter,readDelayCount]=pirtarget.elabAddrDecoderModules(hDecoderNet,...
        hElab,hAddrList,hDecodeReadSignal,muxCounter,readDelayCount);
    end


    pirelab.getWireComp(hDecoderNet,hDecodeReadSignal,data_read);

end


