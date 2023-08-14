function rtp=buildBDRapidAcceleratorTargetImpl(mdl,varargin)
































    load_system(mdl);


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
    catch e
        theError=e;
    end

    buildData=get_param(mdl,'RapidAcceleratorBuildData');
    if~isempty(buildData)&&isa(buildData,'simulinkstandalone.metamodel.BuildData')
        set_param(mdl,'RapidAcceleratorSimStatus','terminating');
        sl('rapid_accel_target_utils','cleanup',buildData);
        set_param(mdl,'RapidAcceleratorBuildData',[]);
    else
        set_param(mdl,'RapidAcceleratorSimStatus','inactive');
    end
    if~isempty(theError)
        rethrow(theError);
    end
end


