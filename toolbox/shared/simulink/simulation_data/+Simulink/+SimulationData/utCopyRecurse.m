function out=utCopyRecurse(in)




    if ismethod(in,'copy')
        out=copy(in);
        return;
    elseif isstruct(in)
        out=in;
        names=fieldnames(in);
        nFields=numel(names);
        n=numel(in);
        for aIdx=1:n
            for idx=1:nFields
                out(aIdx).(names{idx})=Simulink.SimulationData.utCopyRecurse(in(aIdx).(names{idx}));
            end
        end
        return;
    elseif iscell(in)
        out=in;
        n=numel(out);
        for idx=1:n
            out{idx}=Simulink.SimulationData.utCopyRecurse(in{idx});
        end
    else
        out=in;
    end

end
