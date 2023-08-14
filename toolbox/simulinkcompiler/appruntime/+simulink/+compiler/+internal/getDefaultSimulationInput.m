



function simInput=getDefaultSimulationInput(model)



    product="Simulink_Compiler";
    [status,msg]=builtin('license','checkout',product);
    if~status
        product=extractBetween(msg,'Cannot find a license for ','.');
        if~isempty(product)
            error(message('simulinkcompiler:build:LicenseCheckoutError',product{1}));
        end
        error(msg);
    end

    verbose=false;

    if~Simulink.isRaccelDeployed
        load_system(model);
        if verbose,fprintf('### Loaded model: %s\n',model);end %#ok<UNRCH>
    else
        mi=Simulink.RapidAccelerator.getStandaloneModelInterface(model);
        if isempty(mi.startTime)
            mi.startTime=clock;
        end
        mi.initializeForDeployment();
    end






    simInput=Simulink.SimulationInput(model);
    simInput=setDefaultModelParameters(simInput);
    old_mode=get_param(model,'SimulationMode');

    try
        simInput=setBuildDependentInfo(simInput,verbose);
    catch err
        model_cleanup=onCleanup(@()set_param(model,'SimulationMode',old_mode));
        throw(err)
    end
end



function simInput=setDefaultModelParameters(simInput)
    assert(isa(simInput,'Simulink.SimulationInput'));

    modelIndependentParameters={...
    {'simulationmode','r'},...
    {'rapidacceleratoruptodatecheck','off'}...
    };

    for i=1:length(modelIndependentParameters)
        simInput=simInput.setModelParameter(...
        modelIndependentParameters{i}{1},...
        modelIndependentParameters{i}{2}...
        );
    end

    modelDependentParameters={...
'StopTime'...
    };

    model=simInput.ModelName;

    for i=1:length(modelDependentParameters)
        parameterValue=loc_get_param(...
        model,...
        modelDependentParameters{i}...
        );

        simInput=simInput.setModelParameter(...
        modelDependentParameters{i},...
parameterValue...
        );
    end

    simInput=loc_addVariablesThatAppearInModelParameters(simInput);
end



function value=loc_get_param(model,parameter)
    if~Simulink.isRaccelDeployed
        value=get_param(model,parameter);
    else
        mi=Simulink.RapidAccelerator.getStandaloneModelInterface(model);
        value=mi.get_param(parameter);
    end
end



function simInput=loc_addVariablesThatAppearInModelParameters(simInput)
    modelParameterVariables=Simulink.RapidAccelerator.internal.getVariablesFromNumericModelParameters(simInput);
    existingVariables=string({simInput.Variables.Name});
    newVariables=setdiff(modelParameterVariables,existingVariables);

    for i=1:length(newVariables)

        [variableValue,success]=find_nonsimulationinput_variable_with_workspace_resolution(...
        newVariables{i},...
        simInput.ModelName...
        );

        if~success
            variableValue=1;
        end

        simInput=simInput.setVariable(...
        newVariables{i},...
variableValue...
        );
    end
end



function simInput=setBuildDependentInfo(simInput,verbose)
    assert(...
    isa(simInput,'Simulink.SimulationInput')&&...
    ~isempty(simInput.ModelName)...
    );

    model=simInput.ModelName;

    if~Simulink.isRaccelDeployed


        rtp=eval('Simulink.BlockDiagram.buildRapidAcceleratorTarget(model)');
    else
        rtp=getRTPInDeployedSim(model);
    end

    simInput=setParameters(simInput,rtp);
    simInput=setExternalInputs(simInput);
    simInput=setInitialState(simInput);
end



function rtp=getRTPInDeployedSim(model)
    modelInterface=Simulink.RapidAccelerator.getStandaloneModelInterface(model);
    if isempty(modelInterface.startTime)
        modelInterface.startTime=clock;
    end
    modelInterface.initializeForDeployment();
    rtp=modelInterface.getRtp();
end



function simInput=setParameters(simInput,rtp)
    assert(isa(simInput,'Simulink.SimulationInput'));
    simInput=setVariablesUsingRTP(simInput,rtp);
    simInput=addVariablesUsedByMasks(simInput);
end



function simInput=setVariablesUsingRTP(simInput,rtp)
    variableSet=createVariableSetFromRTP(rtp);
    simInput.Variables=[simInput.Variables,variableSet];
end





function variableSet=createVariableSetFromRTP(rtp)
    variableSet=[];

    if isempty(rtp)
        return
    end

    assert(...
    isstruct(rtp)&&...
    isfield(rtp,'parameters')&&...
    isfield(rtp(1).parameters,'values')&&...
    isfield(rtp(1).parameters,'map')&&...
    isfield(rtp(1).parameters,'structParamInfo')...
    );

    parameterList=rtp.parameters;

    for paramIdx=1:length(parameterList)
        parameterValues=parameterList(paramIdx).values;

        if~isempty(parameterList(paramIdx).map)
            assert(isempty(parameterList(paramIdx).structParamInfo));
            map=parameterList(paramIdx).map;

            assert(...
            isstruct(map)&&...
            isfield(map,'Identifier')&&...
            isfield(map,'ValueIndices')...
            );

            for mapIdx=1:length(map)
                mapEntry=map(mapIdx);

                assert(...
                (ischar(mapEntry.Identifier)||isstring(map(mapEntry.Identifier)))&&...
                (isvector(mapEntry.ValueIndices)&&length(mapEntry.ValueIndices)==2&&...
                isnumeric(mapEntry.ValueIndices))...
                );

                varName=mapEntry.Identifier;
                varValu=reshape(...
                parameterValues(mapEntry.ValueIndices(1):mapEntry.ValueIndices(2)),...
                mapEntry.Dimensions);

                newVariable=Simulink.Simulation.Variable(varName,varValu);

                variableSet=[variableSet,newVariable];%#ok<AGROW>
            end
        elseif~isempty(parameterList(paramIdx).structParamInfo)
            structParamInfo=parameterList(paramIdx).structParamInfo;

            assert(...
            isstruct(structParamInfo)&&...
            isfield(structParamInfo,'Identifier')&&...
            isfield(structParamInfo,'ModelParam')...
            );



            if isempty(structParamInfo.Identifier)
                continue
            end


            assert(~isempty(structParamInfo.ModelParam));
            if~structParamInfo.ModelParam
                continue
            end

            assert(matlab.internal.datatypes.isScalarText(structParamInfo.Identifier));

            newVariable=Simulink.Simulation.Variable(...
            structParamInfo.Identifier,...
parameterValues...
            );

            variableSet=[variableSet,newVariable];%#ok<AGROW>
        end
    end
end



function simInput=addVariablesUsedByMasks(simInput)
    model=convertStringsToChars(simInput.ModelName);

    if~Simulink.isRaccelDeployed
        folders=Simulink.filegen.internal.FolderConfiguration(model,true,false);
        buildDir=folders.RapidAccelerator.absolutePath('ModelCode');

        maskTreeFile=rapid_accel_target_utils(...
        'get_mask_tree_file',...
        model,...
buildDir...
        );
    else
        modelInterface=Simulink.RapidAccelerator.getStandaloneModelInterface(model);
        if isempty(modelInterface.startTime)
            modelInterface.startTime=clock;
        end
        modelInterface.initializeForDeployment();
        maskTreeFile=modelInterface.getMaskTreeFile();
    end

    parser=mf.zero.io.XmlParser;
    maskTree=parser.parseFile(maskTreeFile);

    variableMaps={...
    maskTree.referencedGlobalWorkspaceVariables,...
    maskTree.referencedModelWorkspaceVariables...
    };

    for i=1:length(variableMaps)
        keys=variableMaps{i}.keys;
        for j=1:length(keys)
            variable=variableMaps{i}.getByKey(keys{j});
            try

                simInput.getVariable(variable.name);
            catch

                if isequal(variable.workspace,'global-workspace')
                    workspace='global-workspace';
                else
                    workspace=model;
                end
                simInput=simInput.setVariable(variable.name,variable.value,'workspace',workspace);
            end
        end
    end
end



function simInput=setExternalInputs(simInput)
    assert(...
    isa(simInput,'Simulink.SimulationInput')&&...
    ~isempty(simInput.ModelName)...
    );

    model=simInput.ModelName;

    if isequal(get_param(model,'LoadExternalInput'),'off')
        return
    end

    if~Simulink.isRaccelDeployed
        extInputs=getExternalInputsInDesktopSim(model);
    else
        extInputs=getExternalInputsInDeployedSim(model);
    end

    assert(iscell(extInputs));

    if isempty(extInputs)
        return
    end




    if isscalar(extInputs)&&...
        (isa(extInputs{1},'Simulink.SimulationData.Dataset')||...
        isa(extInputs{1},'Simulink.SimulationData.DatasetRef')||...
        isa(extInputs{1},'timeseries')||...
        isa(extInputs{1},'double'))
        extInputs=extInputs{1};
    else
        warning(...
        message(...
        'simulinkcompiler:get_default_simulation_input:ExternalInputsNotCompatibleWithSimulationInput',...
model...
        ));

        extInputs=[];
    end

    simInput=simInput.setExternalInput(extInputs);
end



function extInputs=getExternalInputsInDesktopSim(model)




    if~Simulink.isRaccelDeployed
        folders=Simulink.filegen.internal.FolderConfiguration(model,true,false);
        buildDir=folders.RapidAccelerator.absolutePath('ModelCode');
    else
        buildDir=fullfile(pwd,'slprj','raccel_deploy',model);
    end

    extInputs=sl(...
    'rapid_accel_target_utils',...
    'get_build_ext_inputs',...
buildDir...
    );
end



function extInputs=getExternalInputsInDeployedSim(model)
    mi=Simulink.RapidAccelerator.getStandaloneModelInterface(model);
    mi.debugLog(2,'In getDefaultSimulationInput/getExternalInputsInDeployedSim');
    extInputs=mi.getBuildExtInputs();
end



function simInput=setInitialState(simInput)
    model=simInput.ModelName;

    if~Simulink.isRaccelDeployed
        initialState=getInitialStateInDesktopSim(model);
    else
        initialState=getInitialStateInDeployedSim(model);
    end

    if~isempty(initialState)
        simInput=simInput.setInitialState(initialState);
    end
end


function initialState=getInitialStateInDesktopSim(model)
    if~Simulink.isRaccelDeployed
        folders=Simulink.filegen.internal.FolderConfiguration(model,true,false);
        buildDir=folders.RapidAccelerator.absolutePath('ModelCode');
    else
        buildDir=fullfile(pwd,'slprj','raccel_deploy',model);
    end

    initialState=sl(...
    'rapid_accel_target_utils',...
    'get_build_initial_state',...
buildDir...
    );
end


function initialState=getInitialStateInDeployedSim(model)
    mi=Simulink.RapidAccelerator.getStandaloneModelInterface(model);
    mi.debugLog(2,'In getDefaultSimulationInput/getInitialStateInDeployedSim');
    initialState=mi.getBuildInitialState();
end
