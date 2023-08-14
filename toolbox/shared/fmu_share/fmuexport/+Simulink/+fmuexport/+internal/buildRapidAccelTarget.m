

function buildRapidAccelTarget(model,varargin)


    oldVal=slfeature('NoSimTargetForBuild',1);
    oc=onCleanup(@()slfeature('NoSimTargetForBuild',oldVal));


    loggingToFile=get_param(model,'LoggingToFile');
    set_param(model,'LoggingToFile','on');
    logoc=onCleanup(@()set_param(model,'LoggingToFile',loggingToFile));

    racDepBld=Simulink.isRaccelDeploymentBuild();
    Simulink.isRaccelDeploymentBuild(true);
    rdboc=onCleanup(@()Simulink.isRaccelDeploymentBuild(racDepBld));


    if~strcmp(get_param(model,'RapidAcceleratorSimStatus'),'inactive')
        ME=MException(message('Simulink:tools:rapidAccelSecondSim',model));
        ME.throw();
    end

    set_param(model,'RapidAcceleratorSimStatus','starting');
    set_param(model,'RapidAcceleratorCallType','buildonly');

    theError='';
    m=mf.zero.Model;
    set_param(model,'RapidAcceleratorBuildData',m);
    try
        rtp=sl('build_rapid_accel_target',model,varargin{1:end});
    catch ex
        theError=ex;
    end

    buildData=get_param(model,'RapidAcceleratorBuildData');
    if~isempty(buildData)&&isa(buildData,'simulinkstandalone.metamodel.BuildData')
        set_param(model,'RapidAcceleratorSimStatus','terminating');
        set_param(model,'RapidAcceleratorBuildData',[]);
    else
        set_param(model,'RapidAcceleratorSimStatus','inactive');
    end

    if~isempty(theError)
        rethrow(theError);
    end


    sfuncs=load(fullfile(pwd,'slprj','raccel_deploy',model,[model,'_sfcn_info.mat']));
    for i=1:length(sfuncs.sFcnInfo)
        [~,name,ext]=fileparts(sfuncs.sFcnInfo(i).mexPath);
        copyfile(sfuncs.sFcnInfo(i).mexPath,fullfile(pwd,'slprj','raccel_deploy',model));
        sfuncs.sFcnInfo(i).mexPath=[name,ext];


    end
    save(fullfile(pwd,'slprj','raccel_deploy',model,[model,'_sfcn_info.mat']),'-struct','sfuncs')


    solverParamMat=dir(fullfile(pwd,'slprj','raccel_deploy',model,'slp*.mat'));
    for i=1:length(solverParamMat)
        solverParam=load(fullfile(solverParamMat(i).folder,solverParamMat(i).name));
        solverParam.slvrOpts.SolverChangeInfoFileName='';


        [~,name,ext]=fileparts(solverParam.slvrOpts.ParallelExecutionProfilingOutputFilename);
        solverParam.slvrOpts.ParallelExecutionProfilingOutputFilename=[name,ext];
        [~,name,ext]=fileparts(solverParam.slvrOpts.ParallelExecutionNodeExecutionModesFilename);
        solverParam.slvrOpts.ParallelExecutionNodeExecutionModesFilename=[name,ext];
        [~,name,ext]=fileparts(solverParam.slvrOpts.diaglogdb_dir);
        solverParam.slvrOpts.diaglogdb_dir=[name,ext];
        [~,name,ext]=fileparts(solverParam.slvrOpts.LoggedStatesTemplateFileName);
        solverParam.slvrOpts.LoggedStatesTemplateFileName=[name,ext];
        [~,name,ext]=fileparts(solverParam.slvrOpts.OperatingPointFileName);
        solverParam.slvrOpts.OperatingPointFileName=[name,ext];
        [~,name,ext]=fileparts(solverParam.slvrOpts.LiveOutputSpecsFileName);
        solverParam.slvrOpts.LiveOutputSpecsFileName=[name,ext];
        save(fullfile(solverParamMat(i).folder,solverParamMat(i).name),'-struct','solverParam');
    end
end

