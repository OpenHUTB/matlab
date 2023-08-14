function handle=hdlsignalhandle(idx)


    if hdlispirbased

        if isscalar(idx)
            handle=idx.SimulinkHandle;
        else
            handle=cell(1,length(idx));
            for n=1:length(idx)
                handle{n}=idx(n).SimulinkHandle;
            end
        end
    else
        signalTable=hdlgetsignaltable;
        signalTable.checkSignalIndices(idx);





        if isscalar(idx)
            handle=signalTable.PortHandles(idx);
        else
            handle=cell(1,length(idx));
            for n=1:length(idx)
                handle{n}=signalTable.PortHandles(idx(n));
            end
        end
    end
end
