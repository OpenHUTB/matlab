



function signalsToLog=markSignalsToLog(sigs)




    signalsToLog=[];
    for idx=1:numel(sigs)
        bPath=sigs{idx}.BlockPath.convertToCell;
        ph=get_param(bPath{end},'PortHandles');
        ph=ph.Outport(sigs{idx}.OutputPortIndex);
        if strcmp(get_param(ph,'DataLogging'),'off')

            set_param(ph,'DataLogging','on');
            signalsToLog=[signalsToLog,sigs{idx}];%#ok<AGROW>
        end
    end
end


