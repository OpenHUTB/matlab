function signalname=hdlsignalname(idx)


    if hdlispirbased

        if isscalar(idx)
            signalname=idx.Name;
            if isempty(signalname)
                warning(message('HDLShared:directemit:EmptySignalName',getfullname(idx.SimulinkHandle),idx.RefNum));
            end

        else
            signalname=cell(1,length(idx));
            for n=1:length(idx)
                signalname{n}=idx(n).Name;
                if isempty(signalname{n})
                    warning(message('HDLShared:directemit:EmptySignalName',getfullname(idx(n).SimulinkHandle),idx(n).RefNum));
                end
            end
        end
    else
        signalTable=hdlgetsignaltable;
        signalTable.checkSignalIndices(idx);

        if isscalar(idx)
            signal=signalTable.Signals(idx);
            signalname=signal.Name;
        else
            signalname=cell(1,length(idx));
            for ii=1:length(idx)
                signalname{ii}=hdlsignalname(idx(ii));
            end
        end
    end
end


