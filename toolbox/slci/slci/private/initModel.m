





function initModel(mdl)

    try
        slci.internal.initSFSimFolder(mdl);
    catch ME




        if strcmpi(ME.identifier,'Stateflow:sfprivate:TargetLocked')
            return;
        else
            mdlName=get_param(mdl,'Name');
            DAStudio.error('Slci:compatibility:ErrorInitModelOnMACheck',...
            mdlName);
        end
    end

end
