function choice=getOptionChoice(obj,optionID)




    hOption=obj.getOption(optionID);
    if~isempty(hOption)
        if strcmpi(optionID,'Workflow')
            choice=obj.getTargetWorkflowList;

        elseif strcmpi(optionID,'Board')

            choice=obj.getBoardNameList;

        elseif strcmpi(optionID,'Tool')

            choice=obj.getToolNameList;

        elseif strcmpi(optionID,'SimulationTool')

            choice=obj.getSimToolNameList;

        elseif strcmpi(hOption.WorkflowID,'Device')
            switch optionID
            case 'Family'
                choice=obj.hToolDriver.hDevice.listFamily;
            case 'Device'
                choice=obj.hToolDriver.hDevice.listDevice(get(obj,'Family'));
            case 'Package'
                choice=obj.hToolDriver.hDevice.listPackage(get(obj,'Family'),get(obj,'Device'));
            case 'Speed'
                choice=obj.hToolDriver.hDevice.listSpeed(get(obj,'Family'),get(obj,'Device'));
            otherwise
                error(message('hdlcommon:workflow:InvalidDeviceOption',optionID));
            end
        else
            choice=hOption.AllChoice;
        end
    else

        choice={''};
    end

end
