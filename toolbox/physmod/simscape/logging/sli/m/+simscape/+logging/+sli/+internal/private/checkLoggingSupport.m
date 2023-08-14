function loggingSupported=checkLoggingSupport(model,isRapidAccel)





    modelName=get_param(model,'Name');

    simMode=get_param(model,'SimulationMode');


















    logToSDI=strcmpi(get_param(model,'SimscapeLogToSDI'),'on');
    if(isRapidAccel||strcmpi(simMode,'rapid-accelerator'))
        if Simulink.isRaccelDeploymentBuild
            pm_warning('physmod:simscape:logging:sli:settings:StandaloneModeNotSupportedInRaccel');
        elseif logToSDI
            pm_warning('physmod:simscape:logging:sli:settings:SDILiveStreamingNotSupportedInRaccel');
        end
    end


    loggingSupported=true;
    if~lIsSimModeSupported(simMode,isRapidAccel)



        loggingSupported=false;
        pm_warning('physmod:simscape:logging:sli:settings:UnsupportedSimMode',simMode);
    end

    if loggingSupported

        if isRapidAccel&&strcmpi(get_param(model,'SimscapeLogSimulationStatistics'),'on')
            pm_warning('physmod:simscape:logging:sli:settings:ZcLoggingNotSupportedInRaccel',modelName);
        end


        mdlRefTarget=get_param(model,'ModelReferenceTargetType');
        switch upper(mdlRefTarget)
        case 'NONE'
            unsupportedModelRefMode=false;
        otherwise
            unsupportedModelRefMode=true;
        end
        if unsupportedModelRefMode
            pm_error('physmod:simscape:logging:sli:settings:ModelRefNotSupported',...
            modelName);
        end


        isRtwBuild=~isempty(get_param(model,'RTWGenSettings'));
        isAccel=~strcmpi(simMode,'normal');
        if isRtwBuild&&~isAccel&&~unsupportedModelRefMode
            pm_warning('physmod:simscape:logging:sli:settings:CodeGenNotSupported',...
            modelName);
        end
    end
end

function res=lIsSimModeSupported(mode,isRapidAccel)





    if isRapidAccel
        res=true;
    else
        switch lower(mode)
        case{'normal','accelerator','rapid-accelerator'}
            res=true;
        otherwise
            res=false;
        end
    end
end
