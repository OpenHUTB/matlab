function addInstrumentationForRuntimeBindings(mdl,dbBlockHandles,observers)





    portHandles=[];
    neededObs={};


    numBlks=numel(dbBlockHandles);
    for idx=1:numBlks
        [portHandles,neededObs]=locInstrumentIfNeeded(...
        dbBlockHandles(idx),observers{idx},portHandles,neededObs);
    end


    if~isempty(portHandles)
        simulink.hmi.signal.addNeededObservers(mdl,portHandles,neededObs,true);
    end
end


function[ph,neededObs]=locInstrumentIfNeeded(hDbBlk,obsType,ph,neededObs)

    binding=get_param(hDbBlk,'Binding');
    for idx=1:numel(binding)
        if iscell(binding)
            sig=binding{idx};
        else
            assert(isscalar(binding));
            sig=binding;
        end


        hPort=locGetPortHandle(sig);
        if isempty(hPort)||~hPort
            return
        end


        if strcmpi(get(hPort,'DataLogging'),'off')
            set(hPort,'DataLogging','on');
        end


        if~isempty(obsType)
            ph(end+1)=hPort;%#ok<AGROW>
            neededObs{end+1}=obsType;%#ok<AGROW>
        end
    end
end


function hPort=locGetPortHandle(sig)

    hPort=0;
    try
        if~isempty(sig.BlockPath)&&sig.BlockPath.getLength()>0
            blk=sig.BlockPath.getBlock(sig.BlockPath.getLength());
            ph=get_param(blk,'PortHandles');
            if sig.OutputPortIndex>0&&sig.OutputPortIndex<=numel(ph.Outport)
                hPort=ph.Outport(sig.OutputPortIndex);
            end
        end
    catch me %#ok<NASGU>

        hPort=0;
    end
end
