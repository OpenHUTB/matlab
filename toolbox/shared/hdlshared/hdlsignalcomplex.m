function cplx=hdlsignalcomplex(idx)








    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if hdlispirbased||~emitMode

        if isscalar(idx)
            cplx=idx.Imag;
            if isempty(cplx)
                cplx=[];
            end
        else
            for n=1:length(idx)
                cplxSig=idx(n).Imag;
                if isempty(cplxSig)
                    cplx(n)=[];
                else
                    cplx(n)=cplxSig;
                end
            end
        end
    else
        signalTable=hdlgetsignaltable;
        signalTable.checkSignalIndices(idx);
        cplx=signalTable.getComplex(idx);
    end
end
