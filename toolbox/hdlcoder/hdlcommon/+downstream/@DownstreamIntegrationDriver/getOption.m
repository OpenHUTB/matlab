function hOption=getOption(obj,optionID)





    if strcmpi(optionID,'Workflow')
        hOption=obj.Workflow;

    elseif strcmpi(optionID,'Board')
        hOption=obj.Board;

    elseif strcmpi(optionID,'Tool')
        hOption=obj.Tool;

    elseif strcmpi(optionID,'SimulationTool')
        hOption=obj.SimulationTool;

    elseif strcmpi(optionID,'ExecutionMode')
        if~isempty(obj.hTurnkey)
            hOption=obj.hTurnkey.getExecutionModeOption;
        else
            hOption=[];
        end

    else

        cmpresult=strcmp(optionID,obj.hToolDriver.OptionIDList);
        if any(cmpresult)
            hOption=obj.hToolDriver.OptionList{cmpresult};
        else

            hOption=[];
        end

    end
end