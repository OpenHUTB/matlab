function hdlsignalsetvtype(idx,vtype)


    if hdlispirbased

        for ii=1:length(idx)
            hS=idx(ii);
            hS.VType(vtype);
        end
    else
        signalTable=hdlgetsignaltable;
        signalTable.checkSignalIndices(idx);
        signalTable.setVType(idx,vtype);
    end
end
