


function unmarkSignalsToLog(sigs)





    for idx=1:numel(sigs)
        bPath=sigs(idx).BlockPath.convertToCell;
        ph=get_param(bPath{end},'PortHandles');
        ph=ph.Outport(sigs(idx).OutputPortIndex);
        set_param(ph,'DataLogging','off');
    end
end


