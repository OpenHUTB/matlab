function sltype=hdlsignalsltype(idx)


    if hdlispirbased

        tpinfo=pirgetdatatypeinfo(idx.Type);
        sltype=tpinfo.sltype;
    else
        signalTable=hdlgetsignaltable;
        signalTable.checkSignalIndices(idx);
        sltype=signalTable.getSLType(idx);
    end
end
