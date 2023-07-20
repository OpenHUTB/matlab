function rtp=hBuildRapidAcceleratorTarget(mdl,varargin)


































    configAccel=get_param(0,'AcceleratorUseTrueIdentifier');
    set_param(0,'AcceleratorUseTrueIdentifier','on');
    oc=onCleanup(@()set_param(0,'AcceleratorUseTrueIdentifier',configAccel));



    configDeploy=Simulink.isRaccelDeploymentBuild;
    Simulink.isRaccelDeploymentBuild(true);
    oc2=onCleanup(@()Simulink.isRaccelDeploymentBuild(configDeploy));

    if~bdIsLoaded(mdl)
        load_system(mdl);
        objCleanupModel=onCleanup(@()close_system(mdl,0));
    end


    if~strcmp(get_param(mdl,'RapidAcceleratorSimStatus'),'inactive')
        ME=MException(message('Simulink:tools:rapidAccelSecondSim',mdl));
        ME.throw();
    end
    set_param(mdl,'RapidAcceleratorSimStatus','starting');
    set_param(mdl,'RapidAcceleratorCallType','buildonly');
    theError='';
    m=mf.zero.Model;
    set_param(mdl,'RapidAcceleratorBuildData',m);
    try
        rtp=sl('build_rapid_accel_target',mdl,varargin{1:end});
        disp(' done with rapid accelerator build');
    catch e
        disp(['!!! There was an error during the build process: ',e.identifier]);
        theError=e;
    end

    buildData=get_param(mdl,'RapidAcceleratorBuildData');
    if~isempty(buildData)&&isa(buildData,'simulinkstandalone.metamodel.BuildData')
        set_param(mdl,'RapidAcceleratorSimStatus','terminating');
        set_param(mdl,'RapidAcceleratorBuildData',[]);
    else
        set_param(mdl,'RapidAcceleratorSimStatus','inactive');
    end
    if~isempty(theError)
        rethrow(theError);
    end
end
