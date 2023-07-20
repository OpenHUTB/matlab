function vtype=hdlsignalvtype(idx)


    if hdlispirbased

        if isscalar(idx)
            vtype=idx.VType;
        else
            vtype=cell(1,length(idx));
            for n=1:length(idx)
                vtype{n}=idx(n).VType;
            end
        end

    else
        signalTable=hdlgetsignaltable;
        signalTable.checkSignalIndices(idx);
        vtype=signalTable.getVType(idx);
    end
end
