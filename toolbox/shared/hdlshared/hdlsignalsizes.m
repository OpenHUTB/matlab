function sizes=hdlsignalsizes(idx)


    if hdlispirbased

        if isscalar(idx)
            sltype=getslsignaltype(idx.Type);
            [size,bp,signed]=hdlwordsize(sltype.native);
            sizes=[size,bp,signed];
        else
            numSigs=length(idx);
            sizes=zeros(numSigs,3);
            for n=1:numSigs
                sltype=getslsignaltype(idx(n).Type);
                [size,bp,signed]=hdlwordsize(sltype.native);
                sizes(n,:)=[size,bp,signed];
            end
        end
    else
        signalTable=hdlgetsignaltable;
        signalTable.checkSignalIndices(idx);
        sizes=signalTable.getSizes(idx);
    end
end
