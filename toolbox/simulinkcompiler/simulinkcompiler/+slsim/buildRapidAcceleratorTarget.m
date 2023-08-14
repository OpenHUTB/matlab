function[rtp,buildData]=buildRapidAcceleratorTarget(mdl,varargin)








    set_param(0,'AcceleratorUseTrueIdentifier','on');

    load_system(mdl);

    old=Simulink.isRaccelDeploymentBuild();
    Simulink.isRaccelDeploymentBuild(true);
    oc=onCleanup(@()Simulink.isRaccelDeploymentBuild(old));



    if~strcmp(get_param(mdl,'SimulationStatus'),'stopped')
        ME=MException(message('Simulink:tools:rapidAccelSecondSim',mdl));
        ME.throw();
    end

    set_param(mdl,'RTWCAPIRootIO','on');
    set_param(mdl,'RapidAcceleratorSimStatus','starting');
    set_param(mdl,'RapidAcceleratorCallType','buildonly');

    m=mf.zero.Model;
    set_param(mdl,'RapidAcceleratorBuildData',m);

    rtp=sl('build_rapid_accel_target',mdl,varargin{1:end});

    buildData=get_param(mdl,'RapidAcceleratorBuildData');
    set_param(mdl,'RapidAcceleratorSimStatus','terminating');
    set_param(mdl,'RapidAcceleratorBuildData',[]);

end