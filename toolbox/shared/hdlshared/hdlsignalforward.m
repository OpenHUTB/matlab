function forward=hdlsignalforward(idx)


    if hdlispirbased

        if isscalar(idx)
            forward=idx.Forward;
            if isempty(forward)
                forward=0;
            end
        else
            forward=zeros(1,length(idx));
            for n=1:length(idx)
                f=idx(n).Forward;
                if isempty(f)
                    f=0;
                end
                forward(n)=f;
            end
        end
    else
        signalTable=hdlgetsignaltable;
        signalTable.checkSignalIndices(idx);
        forward=signalTable.getForwards(idx);
    end
end
