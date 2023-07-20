function sig=getSignal(this,searchArg)














    sig=Simulink.sdi.Signal.empty();
    if~isscalar(this)
        Simulink.SimulationData.utError('InvalidDatasetArray');
    end

    sigIDs=getSortedSignalIDs(this);


    if isnumeric(searchArg)
        validateattributes(searchArg,{'numeric'},{'positive','integer'},'getSignal','searchArg',2);
        if searchArg<=numel(sigIDs)
            sig=Simulink.sdi.Signal(this.Repo,sigIDs(searchArg));
        end


    else
        validateattributes(searchArg,{'char','string'},{},'getElement','searchArg',2);
        searchArg=char(searchArg);


        names=getElementNames(this);
        pos=strcmp(names,searchArg);
        for idx=1:numel(pos)
            if pos(idx)
                sig(end+1)=Simulink.sdi.Signal(this.Repo,sigIDs(idx));%#ok<AGROW>
            end
        end
    end

end
