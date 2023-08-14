function elabAddrDecoderStrobeModule(hN,hElab,hAddr)







    data_write=hN.PirInputSignals(1);
    addr_sel=hN.PirInputSignals(2);
    wr_enb=hN.PirInputSignals(3);


    portID=hAddr.AssignedPortName;
    addrStart=hAddr.AddressStart;

    if hAddr.AddressLength~=1
        error(message('hdlcommon:workflow:InvalidStrobeLength',sprintf('strobe_decoder_%s',portID)));
    end


    outPortName=sprintf('strobe_%s',portID);
    hDecoderNetOutSignal=hAddr.addPirSignal(hN,outPortName);
    outportType=hDecoderNetOutSignal.Type;



    needPipeReg=hAddr.AddrDecoderPipeline;
    strobe_reg=hN.addSignal(outportType,sprintf('strobe_reg_%s',portID));
    tInSignals=[data_write,addr_sel,wr_enb];
    pirtarget.getAddrDecoderStrobeRegComp(hN,tInSignals,strobe_reg,addrStart,portID,needPipeReg);
    pirelab.getWireComp(hN,strobe_reg,hDecoderNetOutSignal);


    hInternalSignals=hAddr.ElabInternalSignal;

    if hElab.hTurnkey.hD.isIPCoreGen
        pirtarget.connectSignals(hElab,...
        {hDecoderNetOutSignal},hInternalSignals,outPortName);
    else

        newSigName=sprintf('inst_%s',portID);
        pirtarget.connectSignalsWithHierarchy(...
        {hDecoderNetOutSignal},hInternalSignals,'up',outPortName,newSigName);
    end

end