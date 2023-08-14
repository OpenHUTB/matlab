function cplx=hdlsignaliscomplex(idx)








    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if hdlispirbased||~emitMode







        tpinfo=pirgetdatatypeinfo(idx.Type);
        cplx=~isempty(hdlsignalcomplex(idx))||tpinfo.iscomplex;
    else
        signalTable=hdlgetsignaltable;
        signalTable.checkSignalIndices(idx);
        cplx=all(signalTable.getComplex(idx)~=0);
    end
end
