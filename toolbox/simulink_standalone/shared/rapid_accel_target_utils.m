function varargout=rapid_accel_target_utils(iCmd,varargin)










    switch(iCmd)

    case 'init_up_to_date_check_on'
        [varargout{1:nargout}]=init_up_to_date_check_on(varargin{:});

    case 'init_up_to_date_check_off'
        [varargout{1:nargout}]=init_up_to_date_check_off(varargin{:});

    case 'cleanup'
        [varargout{1:nargout}]=cleanup(varargin{:});

    case 'run'
        [varargout{1:nargout}]=run(varargin{:});

    case 'runMultiSim'
        [varargout{1:nargout}]=runMultiSim(varargin{:});

    case 'get_exe_error'
        [varargout{1:nargout}]=get_exe_error(varargin{:});

    case 'create_slvr_file'
        [varargout{1:nargout}]=create_slvr_file(varargin{:});

    case 'load_mat_file'
        [varargout{1:nargout}]=load_mat_file(varargin{:});

    case 'load_simMetadata_file'
        [varargout{1:nargout}]=load_simMetadata_file(varargin{:});

    case 'launch_connect_and_start'
        [varargout{1:nargout}]=launch_connect_and_start(varargin{:});

    case 'set_status_string'
        [varargout{1:nargout}]=set_status_string(varargin{:});

    case 'print_message'
        [varargout{1:nargout}]=print_message(varargin{:});

    case 'get_build_dir'
        [varargout{1:nargout}]=get_build_dir(varargin{:});

    case 'get_exe_name'
        [varargout{1:nargout}]=get_exe_name(varargin{:});

    case 'create_prm_file'

        [varargout{1:nargout}]=create_prm_file(varargin{:});

    case 'save_live_output_specs'
        [varargout{1:nargout}]=loc_save_live_output_specs(varargin{:});

    case 'create_siglogselector_file'
        [varargout{1:nargout}]=create_siglogselector_file(varargin{:});

    case 'obtain_to_from_file_filenames'
        [varargout{1:nargout}]=obtain_to_from_file_filenames(varargin{:});

    case 'save_static_data'
        [varargout{1:nargout}]=save_static_data(varargin{:});

    case 'get_prm_file'
        [varargout{1:nargout}]=get_prm_file(varargin{:});

    case 'get_build_prm_file'
        [varargout{1:nargout}]=get_build_prm_file(varargin{:});

    case 'get_inp_file'
        [varargout{1:nargout}]=get_inp_file(varargin{:});

    case 'get_slvr_file'
        [varargout{1:nargout}]=get_slvr_file(varargin{:});

    case 'get_out_file'
        [varargout{1:nargout}]=get_out_file(varargin{:});

    case 'get_error_file'
        [varargout{1:nargout}]=get_error_file(varargin{:});

    case 'get_simMetadata_file'
        [varargout{1:nargout}]=get_simMetadata_file(varargin{:});

    case 'get_sigstream_file'
        [varargout{1:nargout}]=get_sigstream_file(varargin{:});

    case 'get_siglogselector_file'
        [varargout{1:nargout}]=get_siglogselector_file(varargin{:});

    case 'is_logging_enabled'
        [varargout{1:nargout}]=is_logging_enabled(varargin{:});

    case 'add_to_from_file_blocks'
        [varargout{1:nargout}]=add_to_from_file_blocks(varargin{:});

    case 'has_instrumented_signals'
        [varargout{1:nargout}]=has_instrumented_signals(varargin{:});

    case 'add_instrumented_signals'
        [varargout{1:nargout}]=add_instrumented_signals(varargin{:});

    case 'retrieve_aob_hierarchy'
        [varargout{1:nargout}]=retrieve_aob_hierarchy(varargin{:});

    case 'set_fxpBlockProps'
        [varargout{1:nargout}]=set_fxpBlockProps(varargin{:});

    case 'setup_ext_inputs'
        [varargout{1:nargout}]=setup_ext_inputs(varargin{:});

    case 'get_model_workspace_file'
        [varargout{1:nargout}]=get_model_workspace_file(varargin{:});

    case 'create_model_workspace_file'
        [varargout{1:nargout}]=create_model_workspace_file(varargin{:});

    case 'get_mask_tree_file'
        [varargout{1:nargout}]=get_mask_tree_file(varargin{:});

    case 'create_mask_tree_file'
        [varargout{1:nargout}]=create_mask_tree_file(varargin{:});

    case 'create_build_initial_state_file'
        [varargout{1:nargout}]=create_build_initial_state_file(varargin{:});

    case 'get_build_initial_state_file'
        [varargout{1:nargout}]=get_build_initial_state_file(varargin{:});

    case 'get_build_initial_state'
        [varargout{1:nargout}]=get_build_initial_state(varargin{:});

    case 'create_build_ext_input_file'
        [varargout{1:nargout}]=create_build_ext_input_file(varargin{:});

    case 'get_build_ext_input_file'
        [varargout{1:nargout}]=get_build_ext_input_file(varargin{:});

    case 'get_build_ext_inputs'
        [varargout{1:nargout}]=get_build_ext_inputs(varargin{:});

    case 'create_enum_file'
        [varargout{1:nargout}]=create_enum_file(varargin{:});

    case 'get_enum_file'
        [varargout{1:nargout}]=get_enum_file(varargin{:});

    case 'paramtuningappsvc_parameter_tuning'
        [varargout{1:nargout}]=paramtuningappsvc_parameter_tuning(varargin{:});

    case 'get_sfcn_info_file'
        [varargout{1:nargout}]=get_sfcn_info_file(varargin{:});

    case 'find_sfcn_source_code'
        [varargout{1:nargout}]=find_sfcn_source_code(varargin{:});

    case 'add_datasetref_to_simoutstruct'
        [varargout{1:nargout}]=add_datasetref_to_simoutstruct(varargin{:});

    case 'raccel_debug_rebuild'
        [varargout{1:nargout}]=raccel_debug_rebuild(varargin{:});

    case 'get_opt'
        [varargout{1:nargout}]=get_opt(varargin{:});

    case 'add_dataflow_configuration_info'
        [varargout{1:nargout}]=add_dataflow_configuration_info(varargin{:});

    case 'add_SimHardwareAcceleration_info'
        [varargout{1:nargout}]=add_SimHardwareAcceleration_info(varargin{:});

    case 'reval_instantiate_obj'
        [varargout{1:nargout}]=reval_instantiate_obj(varargin{:});

    case 'reval_obj_setup'
        [varargout{1:nargout}]=reval_obj_setup(varargin{:});

    case 'reval_obj_step'
        [varargout{1:nargout}]=reval_obj_step(varargin{:});

    case 'reval_destroy_obj'
        [varargout{1:nargout}]=reval_destroy_obj(varargin{:});

    case 'loc_edit_rtp'
        [varargout{1:nargout}]=loc_edit_rtp(varargin{:});

    case 'getSimulationOutput'
        [varargout{1:nargout}]=getSimulationOutput(varargin{:});

    otherwise
        assert(false,['Invalid Command ',iCmd]);
    end


    vars=setdiff(who,{'varargin','varargout','iCmd'});
    nvars=length(vars);
    for idx=1:nvars
        assignin('caller',vars{idx},eval(vars{idx}));
    end

end


function strout=findStr(cellAry,strin)
    for i=1:length(cellAry)
        if strcmpi(cellAry{i},strin)
            strout=cellAry{i};
            return;
        end
    end
    strout='';
    return
end



function exeName=get_exe_name(buildDir,mdl)
    if isstring(mdl)




        exeName=string(buildDir)+filesep+mdl;
        if ispc
            exeName=exeName+".exe";
        end
    else
        exeName=[buildDir,filesep,mdl];
        if ispc,exeName=[exeName,'.exe'];end
    end
end



function exeActiveToken=get_exe_active_token(tmpVarPrefix)

    nTmpVar=length(tmpVarPrefix);
    exeActiveToken=cell(1,nTmpVar);
    for i=1:nTmpVar
        exeActiveToken{i}=[tempdir,'tp',tmpVarPrefix{i},'.info'];
    end
end



function errorFile=get_error_file(tmpVarPrefix)

    nTmpVar=length(tmpVarPrefix);
    errorFile=cell(1,nTmpVar);
    for i=1:nTmpVar
        errorFile{i}=[tempdir,'err',tmpVarPrefix{i},'.err'];
    end
end



function exeActiveToken=get_tgtconn_active_token(tmpVarPrefix)

    nTmpVar=length(tmpVarPrefix);
    exeActiveToken=cell(1,nTmpVar);
    for i=1:nTmpVar
        exeActiveToken{i}=[tempdir,'tgtconn',tmpVarPrefix{i},'.info'];
    end
end



function prmFile=get_prm_file(buildDir,tmpVarPrefix)
    nTmpVar=length(tmpVarPrefix);
    prmFile=cell(1,nTmpVar);
    for i=1:nTmpVar
        prmFile{i}=[buildDir,filesep,'pr',tmpVarPrefix{i},'.mat'];
    end
end




function extInputFile=get_build_ext_input_file(buildDir)
    extInputFile=[buildDir,filesep,'build_ext_inputs.mat'];
end



function create_build_ext_input_file(buildData)
    extInputs=get_ext_inputs(buildData);
    extInputFile=get_build_ext_input_file(buildData.buildDir);
    if~isempty(extInputs)
        assert(iscell(extInputs));
    end
    save(extInputFile,'-v7','extInputs');
end



function extInputs=get_build_ext_inputs(buildDir)
    extInputFile=get_build_ext_input_file(buildDir);
    if exist(extInputFile,'file')
        extInputs=load(extInputFile);
        assert(...
        isstruct(extInputs)&&...
        isfield(extInputs,'extInputs')...
        );
        extInputs=extInputs.extInputs;
    else
        extInputs=[];
    end
end



function create_enum_file(enumInfo,buildData)
    enumFile=get_enum_file(buildData.mdl,buildData.buildDir);
    save(enumFile,'enumInfo');
end



function enumFile=get_enum_file(modelName,buildDir)
    enumFile=[buildDir,filesep,[modelName,'_enums.mat']];
end





function extInputFile=get_build_initial_state_file(buildDir)
    extInputFile=[buildDir,filesep,'build_initial_state.mat'];
end



function modelWorkspaceFile=get_model_workspace_file(buildDir)
    modelWorkspaceFile=fullfile(buildDir,'model_workspace.mat');
end



function loc_edit_model_workspace_file(modelWorkspaceFile,buildData)
    if buildData.opts.verbose
        fprintf('### %6.2fs :: Calling loc_edit_model_workspace_file \n',etime(clock,buildData.startTime));
    end
    try
        workspace=load(modelWorkspaceFile);
    catch
        return
    end

    vars=fieldnames(workspace);
    for i=1:length(vars)




        if isa(workspace.(vars{i}),'Simulink.Parameter')
            if buildData.opts.verbose
                fprintf('### %6.2fs :: Found a Simulink.Parameter \n',etime(clock,buildData.startTime));
            end
            workspace.(vars{i})=workspace.(vars{i}).Value;
        elseif isa(workspace.(vars{i}),'Simulink.Bus')
            if buildData.opts.verbose
                fprintf('### %6.2fs :: Found a Simulink.Bus \n',etime(clock,buildData.startTime));
            end
            workspace=rmfield(workspace,vars{i});
        end
    end
    save(modelWorkspaceFile,'-struct','workspace');
end



function create_model_workspace_file(model,buildData)
    if buildData.opts.verbose
        fprintf('### %6.2fs :: Calling create_model_workspace_file \n',etime(clock,buildData.startTime));
    end
    modelWorkspaceFile=get_model_workspace_file(buildData.buildDir);
    modelWS=get_param(model,'ModelWorkspace');
    modelWS.save(modelWorkspaceFile);
    loc_edit_model_workspace_file(modelWorkspaceFile,buildData);
end


function maskTreeFile=get_mask_tree_file(model,buildDir)
    maskTreeFile=fullfile(buildDir,[model,'_mask_tree.xml']);
end



function create_mask_tree_file(model,maskTree,buildData)
    if buildData.opts.verbose
        fprintf('### %6.2fs :: Calling create_mask_tree_file \n',etime(clock,buildData.startTime));
    end
    maskTreeFile=get_mask_tree_file(model,buildData.buildDir);
    serializer=mf.zero.io.XmlSerializer;
    serializer.serializeToFile(maskTree,maskTreeFile);
end




function create_build_initial_state_file(initialState,buildDir)
    initialStateFile=get_build_initial_state_file(buildDir);
    save(initialStateFile,'-v7','initialState');
end


function initialState=get_build_initial_state(buildDir)
    initialStateFile=get_build_initial_state_file(buildDir);
    if exist(initialStateFile,'file')
        initialState=load(initialStateFile);
        assert(...
        isstruct(initialState)&&...
        isfield(initialState,'initialState')...
        );
        initialState=initialState.initialState;
    else
        initialState=[];
    end
end



function prmFile=get_build_prm_file(buildDir)
    prmFile=[buildDir,filesep,'build_rtp.mat'];
end

function checksumFile=get_checksum_file(mdl,buildDir)
    checksumFile=[buildDir,filesep,mdl,'_get_checksum.mat'];
end



function opFile=get_operating_point_file(buildDir,tmpVarPrefix)
    nTmpVar=length(tmpVarPrefix);
    opFile=cell(1,nTmpVar);
    for i=1:nTmpVar
        opFile{i}=[buildDir,filesep,'_opPoint_info_',tmpVarPrefix{i},'.mat'];
    end

end



function paceErrorFile=get_pace_error_file(buildDir,mdl)
    paceErrorFile=[buildDir,filesep,mdl,'_pace_error','.mat'];
end



function logFile=get_standalone_logging_file(tmpVarPrefix)
    nTmpVar=length(tmpVarPrefix);
    logFile=cell(1,nTmpVar);
    for i=1:nTmpVar
        logFile{i}=[tempdir,filesep,'salog_',tmpVarPrefix{i},'.mat'];
    end

end




function[nVars,vars]=loc_get_var_names(varStr,mdl)
    varStr=strrep(varStr,' ','');
    varStrLen=length(varStr);
    commaLocs=strfind(varStr,',');
    commaLocs=[commaLocs,(varStrLen+1)];
    if varStrLen>0
        nVars=length(commaLocs);
    else
        nVars=0;
    end
    vars=cell(1,nVars);
    stPosn=1;
    for i=1:nVars
        vars{i}=varStr(stPosn:(commaLocs(i)-1));
        stPosn=commaLocs(i)+1;
        if~isvarname(vars{i})
            error(message('Simulink:tools:rapidAccelInvalidOutputsVar',mdl));
        end
    end
end




function populateBaseWorkspaceWithCollapsedVariables(rtp)
    if(isempty(rtp)||~isfield(rtp,'collapsedBaseWorkspaceVariables'))
        return
    end

    baseWSVars=evalin('base','whos');
    baseWSVarNames={baseWSVars.name};

    for i=1:length(rtp.collapsedBaseWorkspaceVariables)
        collapsedBaseWSVar=rtp.collapsedBaseWorkspaceVariables(i);
        if ismember(collapsedBaseWSVar.name,baseWSVarNames)
            continue
        end
        assignin('base',collapsedBaseWSVar.name,collapsedBaseWSVar.value);
    end
end


function rtp=loc_update_collapsed_parameters(rtp,buildData)
    if isempty(rtp)||~isfield(rtp,'internal')
        return
    end

    rtpIsForInternalUse=...
    isfield(rtp,'internal')&&...
    isfield(rtp.internal,'forInternalUse')&&...
    rtp.internal.forInternalUse;

    populateBaseWorkspaceWithCollapsedVariables(rtp);

    for i=1:length(rtp.parameters)
        expressionEvaluatorAppended=false;
        if~rtpIsForInternalUse&&isfield(rtp.internal,'tunedParameters')
            buildData=...
            loc_append_rtp_workspace_to_expression_evaluator(...
            buildData,...
            rtp.parameters{i},...
            rtp.internal.tunedParameters{i}...
            );
            expressionEvaluatorAppended=true;
        end
        rtp.parameters{i}=loc_update_collapsed_parameters_in_one_parameter_set(...
        rtp.parameters{i},...
buildData...
        );
        if expressionEvaluatorAppended
            buildData.expressionEvaluator.pop_back();
        end
    end
end

function parameterSet=loc_update_collapsed_parameters_in_one_parameter_set(parameterSet,buildData)
    for transitionIdx=1:length(parameterSet)
        for collapsedParamIdx=1:length(parameterSet(transitionIdx).collapsedParameterInfo)

            info=parameterSet(transitionIdx).collapsedParameterInfo(collapsedParamIdx);
            newValue=buildData.expressionEvaluator.evaluate(info.expression);


            oldValueIsReal=~logical(parameterSet(transitionIdx).complex);
            if~isequal(isreal(newValue),oldValueIsReal)
                if isreal(newValue)
                    newValueComplexityStr="real";
                else
                    newValueComplexityStr="complex";
                end

                if oldValueIsReal
                    oldValueComplexityStr="real";
                else
                    oldValueComplexityStr="complex";
                end

                error(message(...
                'Simulink:tools:rapidAccelCollapsedParameterComplexityMismatch',...
                info.expression,...
                newValueComplexityStr,...
                oldValueComplexityStr,...
                buildData.mdl...
                ));
            end

            oldValueLength=info.valueIndices(2)-info.valueIndices(1)+1;
            if~isequal(numel(newValue),oldValueLength)
                error(message(...
                'Simulink:tools:rapidAccelCollapsedParameterLengthMismatch',...
                info.expression,...
                numel(newValue),...
                oldValueLength,...
                buildData.mdl...
                ));
            end

            oldValueDataType=parameterSet(transitionIdx).dataTypeName;
            if isequal(oldValueDataType,'boolean')
                oldValueDataType='logical';
            end

            if~isequal(class(newValue),oldValueDataType)
                try
                    newValue=cast(newValue,oldValueDataType);
                catch
                    error(message(...
                    'Simulink:tools:rapidAccelCollapsedParameterUnableToCast',...
                    info.expression,...
                    class(newValue),...
                    oldValueDataType,...
                    buildData.mdl...
                    ));
                end
            end

            parameterSet(transitionIdx).values(info.valueIndices(1):info.valueIndices(2))=...
            reshape(newValue,[1,numel(newValue)]);
        end
    end
end



function rtp=loc_update_mask_dependent_parameters(rtp,buildData)
    if isempty(rtp)
        return
    end

    if~isfield(rtp,'internal')||(~isfield(rtp.internal,'tunedParameters')&&~isfield(rtp.internal,'simInputVariables'))

        return
    end

    mdl=buildData.mdl;
    buildDir=buildData.buildDir;
    maskTreeFile=fullfile(buildDir,[mdl,'_mask_tree.xml']);
    parser=mf.zero.io.XmlParser;
    maskTree=parser.parseFile(maskTreeFile);

    assert(isfield(rtp,'internal'));

    rtpIsForInternalUse=...
    isfield(rtp.internal,'forInternalUse')&&...
    rtp.internal.forInternalUse;

    for i=1:length(rtp.parameters)
        expressionEvaluatorAppended=false;
        if~rtpIsForInternalUse
            buildData=...
            loc_append_rtp_workspace_to_expression_evaluator(...
            buildData,...
            rtp.parameters{i},...
            rtp.internal.tunedParameters{i}...
            );
            expressionEvaluatorAppended=true;
        end
        tunedVariables={};

        if isfield(rtp.internal,'tunedParameters')
            tunedVariables={rtp.internal.tunedParameters{i}.name};
        end

        if rtpIsForInternalUse&&isfield(rtp.internal,'simInputVariables')
            tunedVariables={tunedVariables{:},rtp.internal.simInputVariables{:}};%#ok
        end






        tunedVariables=cellfun(@(x)char(x),tunedVariables,'UniformOutput',false);
        tunedVariables=unique(tunedVariables);

        if isempty(tunedVariables)
            return
        end

        rtp.parameters{i}=loc_update_mask_dependent_parameters_in_one_parameter_set(...
        rtp.parameters{i},...
        maskTree,...
        buildData,...
tunedVariables...
        );

        if expressionEvaluatorAppended
            buildData.expressionEvaluator.pop_back();
            maskTree.clearWorkspaces();
        end
    end
end


function parameterSet=loc_update_mask_dependent_parameters_in_one_parameter_set(parameterSet,maskTree,buildData,tunedVariables)
    maskTree.setExpressionEvaluator(buildData.expressionEvaluator);

    if(slsvTestingHook('UnconditionalMaskInitializationInSimulinkCompiler')~=0)
        maskTree.flags.runMaskInitializationCodeUnconditionally=true;
    else
        maskTree.flags.runMaskInitializationCodeUnconditionally=false;
    end

    maskTree.updateMaskWorkspaces(tunedVariables);

    for transitionIdx=1:length(parameterSet)
        for maskIdx=1:length(parameterSet(transitionIdx).maskDependentParameterInfo)
            info=parameterSet(transitionIdx).maskDependentParameterInfo(maskIdx);



            updateParameter=false;
            for varIdx=1:length(info.variables)
                workspace=info.variables(varIdx).workspaceType;

                if isequal(workspace,'global-workspace')||isequal(workspace,'model-workspace')
                    if any(strcmp(info.variables(varIdx).name,tunedVariables))
                        updateParameter=true;
                        break
                    end
                else

                    if(maskTree.maskedBlocks.getByKey(info.variables(varIdx).workspaceName).ranBaseMaskInitializationCodeDuringUpdate)
                        updateParameter=true;
                        break
                    end
                end
            end

            if updateParameter
                try
                    newValue=maskTree.evaluateExpressionInBaseMaskWorkspace(...
                    info.nearestMaskedParentSID,...
                    info.expression...
                    );
                catch ME
                    error(message(...
                    'Simulink:tools:rapidAccelMaskParameterEvaluationError',...
                    info.expression,...
                    info.ownerBlock...
                    ));
                end


                oldValueIsReal=~logical(parameterSet(transitionIdx).complex);
                if~isequal(isreal(newValue),oldValueIsReal)
                    if isreal(newValue)
                        newValueComplexityStr="real";
                    else
                        newValueComplexityStr="complex";
                    end

                    if oldValueIsReal
                        oldValueComplexityStr="real";
                    else
                        oldValueComplexityStr="complex";
                    end

                    error(message(...
                    'Simulink:tools:rapidAccelMaskParameterComplexityMismatch',...
                    info.expression,...
                    info.ownerBlock,...
                    newValueComplexityStr,...
                    oldValueComplexityStr,...
                    buildData.mdl...
                    ));
                end

                oldValueLength=info.valueIndices(2)-info.valueIndices(1)+1;
                if~isequal(numel(newValue),oldValueLength)
                    error(message(...
                    'Simulink:tools:rapidAccelMaskParameterLengthMismatch',...
                    info.expression,...
                    info.ownerBlock,...
                    numel(newValue),...
                    oldValueLength,...
                    buildData.mdl...
                    ));
                end

                oldValueDataType=parameterSet(transitionIdx).dataTypeName;
                if isequal(oldValueDataType,'boolean')
                    oldValueDataType='logical';
                end

                if~isequal(class(newValue),oldValueDataType)
                    try
                        newValue=cast(newValue,oldValueDataType);
                    catch
                        error(message(...
                        'Simulink:tools:rapidAccelMaskParameterUnableToCast',...
                        info.expression,...
                        info.ownerBlock,...
                        class(newValue),...
                        oldValueDataType,...
                        buildData.mdl...
                        ));
                    end
                end

                parameterSet(transitionIdx).values(info.valueIndices(1):info.valueIndices(2))=...
                reshape(newValue,[1,numel(newValue)]);
            end
        end
    end
end

function rtp=loc_update_matlab_transformed_parameters(rtp,buildData)
    if isempty(rtp)
        return
    end

    rtpIsForInternalUse=...
    isfield(rtp,'internal')&&...
    isfield(rtp.internal,'forInternalUse')&&...
    rtp.internal.forInternalUse;

    for i=1:length(rtp.parameters)
        expressionEvaluatorAppended=false;
        if~rtpIsForInternalUse&&isfield(rtp,'internal')&&isfield(rtp.internal,'tunedParameters')
            buildData=...
            loc_append_rtp_workspace_to_expression_evaluator(...
            buildData,...
            rtp.parameters{i},...
            rtp.internal.tunedParameters{i}...
            );
            expressionEvaluatorAppended=true;
        end
        rtp.parameters{i}=loc_update_matlab_transformed_parameters_in_one_parameter_set(...
        rtp.parameters{i},...
buildData...
        );
        if expressionEvaluatorAppended
            buildData.expressionEvaluator.pop_back();
        end
    end
end

function parameterSet=loc_update_matlab_transformed_parameters_in_one_parameter_set(parameterSet,buildData)

    for transitionIdx=1:length(parameterSet)
        if~isfield(parameterSet(transitionIdx),'matlabTransformedParameterInfo')

            continue;
        end

        for transformedParamIdx=1:length(parameterSet(transitionIdx).matlabTransformedParameterInfo)
            info=parameterSet(transitionIdx).matlabTransformedParameterInfo(transformedParamIdx);
            argCount=length(info.transformScriptArguments);

            args=cell(1,argCount);
            for argIndex=1:argCount

                args{argIndex}=loc_eval_transform_script_argument(...
                info.transformScriptArguments(argIndex),buildData);
            end

            out=cell(1,info.transformScriptOutputCount);

            [out{:}]=feval(info.transformScriptName,args{:});



            for vIndex=1:length(info.valueIndices)
                outIndex=info.valueIndices{vIndex}(1);
                startIndex=info.valueIndices{vIndex}(2);
                endIndex=info.valueIndices{vIndex}(3);

                newValue=out{outIndex};



                oldValueDataType=parameterSet(transitionIdx).dataTypeName;
                if isequal(oldValueDataType,'boolean')
                    oldValueDataType='logical';
                end

                if~isequal(class(newValue),oldValueDataType)
                    error(message(...
                    'Simulink:tools:rapidAccelTransformedParameterTypeMismatch',...
                    class(newValue),...
                    oldValueDataType,...
                    buildData.mdl...
                    ));
                end



                oldValueIsReal=~logical(parameterSet(transitionIdx).complex);
                if~isequal(isreal(newValue),oldValueIsReal)
                    if isreal(newValue)
                        newValueComplexityStr="real";
                    else
                        newValueComplexityStr="complex";
                    end
                    if oldValueIsReal
                        oldValueComplexityStr="real";
                    else
                        oldValueComplexityStr="complex";
                    end

                    error(message(...
                    'Simulink:tools:rapidAccelTransformedParameterComplexityMismatch',...
                    newValueComplexityStr,...
                    oldValueComplexityStr,...
                    buildData.mdl...
                    ));
                end



                oldValueLength=endIndex-startIndex+1;
                if~isequal(numel(newValue),oldValueLength)
                    error(message(...
                    'Simulink:tools:rapidAccelTransformedParameterLengthMismatch',...
                    numel(newValue),...
                    oldValueLength,...
                    buildData.mdl...
                    ));
                end

                parameterSet(transitionIdx).values(startIndex:endIndex)=...
                reshape(newValue,[1,numel(newValue)]);
            end
        end
    end
end

function newValue=loc_eval_transform_script_argument(transformScriptArgument,buildData)

    newValue=buildData.expressionEvaluator.evaluate(...
    transformScriptArgument.expression);



    oldValueDataType=transformScriptArgument.dataType;
    if isequal(oldValueDataType,'boolean')
        oldValueDataType='logical';
    end
    if~isequal(class(newValue),oldValueDataType)
        error(message(...
        'Simulink:tools:rapidAccelTransformedParameterArgTypeMismatch',...
        transformScriptArgument.expression,...
        class(newValue),...
        oldValueDataType,...
        buildData.mdl...
        ));
    end



    oldValueIsReal=~transformScriptArgument.complexity;
    if~isequal(isreal(newValue),oldValueIsReal)
        if isreal(newValue)
            newValueComplexityStr="real";
        else
            newValueComplexityStr="complex";
        end

        if oldValueIsReal
            oldValueComplexityStr="real";
        else
            oldValueComplexityStr="complex";
        end

        error(message(...
        'Simulink:tools:rapidAccelTransformedParameterArgComplexityMismatch',...
        transformScriptArgument.expression,...
        newValueComplexityStr,...
        oldValueComplexityStr,...
        buildData.mdl...
        ));
    end




    oldValueSize=transformScriptArgument.dimension;
    newValueSize=size(newValue);
    if~isequal(newValueSize,oldValueSize)
        error(message(...
        'Simulink:tools:rapidAccelTransformedParameterArgSizeMismatch',...
        transformScriptArgument.expression,...
        mat2str(newValueSize),...
        mat2str(oldValueSize),...
        buildData.mdl...
        ));
    end
end

function rtp=loc_update_sparse_parameters(rtp,buildData)
    if(isempty(rtp)||~isfield(rtp.globalParameterInfo,'sparseParameterInfo'))
        return
    end

    if(isfield(rtp.globalParameterInfo.sparseParameterInfo,'mapParameterInfo'))&&...
        ~isempty(rtp.globalParameterInfo.sparseParameterInfo.mapParameterInfo)
        rtp=loc_update_sparse_map_parameters(rtp,buildData);
    end

    if(isfield(rtp.globalParameterInfo.sparseParameterInfo,'maskParameterInfo')&&...
        ~isempty(rtp.globalParameterInfo.sparseParameterInfo.maskParameterInfo))
        rtp=loc_update_sparse_mask_parameters(rtp,buildData);
    end
end


function rtp=loc_update_sparse_mask_parameters(rtp,buildData)
    if~isfield(rtp,'internal')||~isfield(rtp.internal,'tunedParameters')&&~isfield(rtp.internal,'simInputVariables')

        return
    end
    assert(~isempty(rtp.globalParameterInfo.sparseParameterInfo.maskParameterInfo));
    mdl=buildData.mdl;
    buildDir=buildData.buildDir;
    maskTreeFile=fullfile(buildDir,[mdl,'_mask_tree.xml']);
    parser=mf.zero.io.XmlParser;
    maskTree=parser.parseFile(maskTreeFile);

    tunedVariables={};

    if isfield(rtp.internal,'tunedParameters')
        tunedVariables={rtp.internal.tunedParameters{1}.name};
    end

    if isfield(rtp.internal,'simInputVariables')
        tunedVariables={tunedVariables{:},rtp.internal.simInputVariables{:}};%#ok
    end


    tunedVariables=cellfun(@(x)convertStringsToChars(x),tunedVariables,'UniformOutput',false);
    tunedVariables=unique(tunedVariables);

    if isempty(tunedVariables)
        return
    end

    maskTree.setExpressionEvaluator(buildData.expressionEvaluator);

    if(slsvTestingHook('UnconditionalMaskInitializationInSimulinkCompiler')~=0)
        maskTree.flags.runMaskInitializationCodeUnconditionally=true;
    else
        maskTree.flags.runMaskInitializationCodeUnconditionally=false;
    end

    maskTree.updateMaskWorkspaces(tunedVariables);
    sparseMaskParamInfo=rtp.globalParameterInfo.sparseParameterInfo.maskParameterInfo;
    for transitionIdx=1:length(sparseMaskParamInfo)
        info=sparseMaskParamInfo(transitionIdx);


        updateParameter=false;
        for varIdx=1:length(info.variables)
            workspace=info.variables(varIdx).workspaceType;
            if isequal(workspace,'global-workspace')||isequal(workspace,'model-workspace')
                if any(strcmp(info.variables(varIdx).name,tunedVariables))
                    updateParameter=true;
                    break
                end
            else

                if(maskTree.maskedBlocks.getByKey(info.variables(varIdx).workspaceName).ranBaseMaskInitializationCodeDuringUpdate)
                    updateParameter=true;
                    break
                end
            end
        end

        if updateParameter
            try
                newValue=maskTree.evaluateExpressionInBaseMaskWorkspace(...
                info.nearestMaskedParentSID,...
                info.expression...
                );
            catch ME
                error(message(...
                'Simulink:tools:rapidAccelMaskParameterEvaluationError',...
                info.expression,...
                info.ownerBlock...
                ));
            end
            if(isstruct(newValue)||iscell(newValue))

                error(message(...
                'Simulink:tools:rapidAccelSparseParameterInvalidType',...
                info.expression,...
                class(newValue)...
                ));
            end
            [pr,ir,jc]=loc_extract_sparse_elements(newValue);
            rtp.parameters{1}=loc_update_sparse_element(...
            rtp.parameters{1},...
            pr,...
            info.prIndices,...
            false,...
            info.expression,...
            buildData.mdl);

            if(info.allowPatternChange)
                rtp.parameters{1}=loc_update_sparse_element(...
                rtp.parameters{1},...
                ir,...
                info.irIndices,...
                false,...
                info.expression,...
                buildData.mdl);

                rtp.parameters{1}=loc_update_sparse_element(...
                rtp.parameters{1},...
                jc,...
                info.jcIndices,...
                true,...
                info.expression,...
                buildData.mdl);
            else
                rtp.parameters{1}=local_validate_sparse_pattern(...
                rtp.parameters{1},...
                ir,...
                jc,...
                info.irIndices,...
                info.jcIndices,...
                info.expression,...
                buildData.mdl);
            end
        end
    end
end


function rtp=loc_update_sparse_map_parameters(rtp,buildData)
    sparseMapParamInfo=rtp.globalParameterInfo.sparseParameterInfo.mapParameterInfo;
    for transitionIdx=1:length(sparseMapParamInfo)
        info=sparseMapParamInfo(transitionIdx);
        newValue=buildData.expressionEvaluator.evaluate(info.expression);
        if(isstruct(newValue)||iscell(newValue))

            error(message(...
            'Simulink:tools:rapidAccelSparseParameterInvalidType',...
            info.expression,...
            class(newValue)...
            ));
        end
        [pr,ir,jc]=loc_extract_sparse_elements(newValue);
        rtp.parameters{1}=loc_update_sparse_element(...
        rtp.parameters{1},...
        pr,...
        info.prIndices,...
        false,...
        info.expression,...
        buildData.mdl);
        if(info.allowPatternChange)
            rtp.parameters{1}=loc_update_sparse_element(...
            rtp.parameters{1},...
            ir,...
            info.irIndices,...
            false,...
            info.expression,...
            buildData.mdl);

            rtp.parameters{1}=loc_update_sparse_element(...
            rtp.parameters{1},...
            jc,...
            info.jcIndices,...
            true,...
            info.expression,...
            buildData.mdl);
        else
            rtp.parameters{1}=local_validate_sparse_pattern(...
            rtp.parameters{1},...
            ir,...
            jc,...
            info.irIndices,...
            info.jcIndices,...
            info.expression,...
            buildData.mdl);
        end
    end
end

function parameterSet=loc_update_sparse_element(parameterSet,newValue,indices,checkLengthIdentical,expression,model)
    for vIndex=1:length(indices)
        subsetIndex=indices{vIndex}(1);
        startIndex=indices{vIndex}(2);
        endIndex=indices{vIndex}(3);
        oldValueIsReal=~logical(parameterSet(subsetIndex).complex);
        if~isequal(isreal(newValue),oldValueIsReal)
            if isreal(newValue)
                newValueComplexityStr="real";
            else
                newValueComplexityStr="complex";
            end

            if oldValueIsReal
                oldValueComplexityStr="real";
            else
                oldValueComplexityStr="complex";
            end

            error(message(...
            'Simulink:tools:rapidAccelSparseParameterComplexityMismatch',...
            expression,...
            newValueComplexityStr,...
            oldValueComplexityStr,...
model...
            ));
        end
        oldValueDataType=parameterSet(subsetIndex).dataTypeName;
        if isequal(oldValueDataType,'boolean')
            oldValueDataType='logical';
        end
        newValueDataType=class(newValue);
        if(ischar(newValue)||islogical(newValue))

            error(message(...
            'Simulink:tools:rapidAccelSparseParameterInvalidType',...
            expression,...
newValueDataType...
            ));
        end
        if~isequal(newValueDataType,oldValueDataType)
            try
                newValue=cast(newValue,oldValueDataType);
            catch
                error(message(...
                'Simulink:tools:rapidAccelSparseParameterUnableToCast',...
                expression,...
                newValueDataType,...
                oldValueDataType,...
model...
                ));
            end
        end
        oldValueLength=endIndex-startIndex+1;
        newValueLength=numel(newValue);
        if(checkLengthIdentical)
            loc_check_length_equal(oldValueLength,newValueLength,expression,model);
        else
            loc_check_length_lesser_than_or_equal(oldValueLength,newValueLength,expression,model)
            endIndex=startIndex+newValueLength-1;
        end
        parameterSet(subsetIndex).values(startIndex:endIndex)=...
        reshape(newValue,[1,numel(newValue)]);
    end
end

function loc_check_length_equal(oldValueLength,newValueLength,expression,model)
    if~isequal(newValueLength,oldValueLength)
        error(message(...
        'Simulink:tools:rapidAccelSparseParameterShapeMismatch',...
        expression,...
        newValueLength,...
        oldValueLength,...
model...
        ));
    end
end

function loc_check_length_lesser_than_or_equal(oldValueLength,newValueLength,expression,model)
    if(newValueLength>oldValueLength)
        error(message(...
        'Simulink:tools:rapidAccelSparseParameterLengthMismatch',...
        expression,...
        newValueLength,...
        oldValueLength,...
model...
        ));
    end
end

function parameterSet=local_validate_sparse_pattern(parameterSet,newIrValue,newJcValue,...
    irIndices,jcIndices,expression,model)
    for vIndex=1:length(irIndices)
        irSubsetIndex=irIndices{vIndex}(1);
        irStartIndex=irIndices{vIndex}(2);
        irEndIndex=irIndices{vIndex}(3);

        oldIrValue=parameterSet(irSubsetIndex).values(irStartIndex:irEndIndex)';

        jcSubsetIndex=jcIndices{vIndex}(1);
        jcStartIndex=jcIndices{vIndex}(2);
        jcEndIndex=jcIndices{vIndex}(3);

        oldJcValue=parameterSet(jcSubsetIndex).values(jcStartIndex:jcEndIndex)';

        loc_check_length_equal(length(oldJcValue),length(newJcValue),...
        expression,model);
        loc_check_length_lesser_than_or_equal(length(oldIrValue),length(newIrValue),...
        expression,model);
        rStartOld=1;
        rStartNew=1;
        for rIndex=2:length(newJcValue)
            rEndOld=oldJcValue(rIndex);
            rEndNew=newJcValue(rIndex);

            if~isempty(setdiff(newIrValue(rStartNew:rEndNew),oldIrValue(rStartOld:rEndOld)))
                error(message(...
                'Simulink:tools:rapidAccelSparseParameterPatternMismatch',...
                expression,...
model...
                ));
            end
            rStartOld=rEndOld+1;
            rStartNew=rEndNew+1;
        end

        parameterSet(jcSubsetIndex).values(jcStartIndex:jcEndIndex)=newJcValue;
        irEndIndex=irStartIndex+length(newIrValue)-1;
        parameterSet(irSubsetIndex).values(irStartIndex:irEndIndex)=newIrValue;
    end
end

function[pr,ir,jc]=loc_extract_sparse_elements(sparseParam)
    [rows,columns,pr]=find(sparseParam);
    [~,cSize]=size(sparseParam);
    ir=rows-1;
    jc=zeros(1,cSize+1)';
    for c=1:length(jc)-1
        jc(c+1)=jc(c)+nnz(columns==c);
    end
end



function create_prm_file(buildDir,tmpVarPrefix,rtp,mdl)
    assert(isfield(rtp,'globalParameterInfo'));

    assert(...
    isfield(rtp.globalParameterInfo,'structTransitionInfo')&&...
    isfield(rtp.globalParameterInfo,'fixedPointTransitionInfo')&&...
    isfield(rtp.globalParameterInfo,'sFunctionParameterInfo')&&...
    isfield(rtp.globalParameterInfo,'sparseParameterInfo'));

    if~isempty(rtp.globalParameterInfo.sFunctionParameterInfo)
        loc_add_sfunction_parameter_info_to_sfcn_info_file(...
        mdl,...
        buildDir,...
        rtp.globalParameterInfo.sFunctionParameterInfo);
    end

    rtp=loc_edit_rtp(rtp,mdl,buildDir);

    rtp.parameters={rtp.parameters};
    loc_create_prm_file(buildDir,tmpVarPrefix,rtp);
end



function logOpts=create_log_data(buildData,logOpts)





    simOptsFields=[];
    if~isempty(buildData.simOpts)
        simOptsFields=fieldnames(buildData.simOpts);
    end

    mdl=buildData.mdl;
    logOpts.LogStateDataForArrayLogging=...
    isempty(buildData.logging.LogStateDataForArrayLogging);
    logOpts.LogStateDataForStructLogging=...
    buildData.logging.LogStateDataForStructLogging;
    logOpts.TimeSaveName='';
    logOpts.StateSaveName='';
    if buildData.numReturnValues>0
        if buildData.outputT
            logOpts.TimeSaveName=[buildData.loggingPfx,'tout'];
        end
        logOpts.SaveFormat=buildData.logging.SaveFormat;
        logOpts.MaxDataPoints=0;
        if buildData.numReturnValues>2
            if buildData.outputX
                logOpts.StateSaveName=[buildData.loggingPfx,'xout'];
            end
            if~buildData.outputY
                logOpts.OutputSaveName='';
            end
        elseif buildData.numReturnValues>1
            logOpts.OutputSaveName='';
            if buildData.outputX
                logOpts.StateSaveName=[buildData.loggingPfx,'xout'];
            end
        else
            logOpts.OutputSaveName='';
        end
    else

        if buildData.logging.SaveTime
            logOpts.TimeSaveName=buildData.logging.TimeSaveName;
        end
        if buildData.logging.SaveState
            logOpts.StateSaveName=buildData.logging.StateSaveName;
        end
        logOpts.SaveFormat=buildData.logging.SaveFormat;

        if(isequal(buildData.logging.SaveFormat,'structure')&&...
            isequal(get_param(mdl,'SaveFormat'),'Dataset'))
            logOpts.SaveFormat='Dataset';
            buildData.logging.isOriginalFormatDataset=true;
        end



        if~buildData.logging.SaveOutput||isequal(buildData.logging.SaveFormat,'Dataset')||...
            buildData.logging.isOriginalFormatDataset
            logOpts.OutputSaveName='';
        end

        if isequal(get_param(mdl,'LimitDataPoints'),'on')
            fldValStr=get_param(mdl,'MaxDataPoints');
            fldVal=str2double(fldValStr);
            if isnan(fldVal)
                [fldVal,fldValExists]=eval_string_with_workspace_resolution(...
                fldValStr,...
                mdl,...
buildData...
                );

                if~fldValExists

                    error(message(...
                    'Simulink:tools:rapidAccelBadBlockDiagramParameterNonexistent',...
                    mdl,...
                    fldValStr,...
                    'MaxDataPoints'));
                end
            end

            if~isnumeric(fldVal)

                error(message(...
                'Simulink:tools:rapidAccelBadBlockDiagramParameterExpectingNumeric',...
                mdl,...
                fldValStr,...
                'MaxDataPints'));
            end
            logOpts.MaxDataPoints=fldVal;
        else
            logOpts.MaxDataPoints=0;
        end
    end

    logOpts.SaveFinalState=buildData.logging.SaveFinalState;
    logOpts.FinalStateName=buildData.logging.FinalStateName;



    logOpts.SaveOperatingPoint=buildData.logging.SaveOperatingPoint;

    initialState=buildData.logging.InitialState;
    isDatasetInitialStateFeatureOn=(slfeature('EnableRaccelDatasetAsInitialState')~=0);
    logOpts.InitialState=buildData.logging.InitialState;
    isInitialStateDataset=isequal(class(initialState),'Simulink.SimulationData.Dataset');
    if~isempty(initialState)
        logOpts.LoadInitialState=buildData.logging.LoadInitialState;
        if isequal(class(initialState),'Simulink.op.ModelOperatingPoint')
            SetOPFieldAccess(2);
            isInitialStateDataset=isequal(class(initialState.loggedStates),'Simulink.SimulationData.Dataset');
            if(isInitialStateDataset&&~isDatasetInitialStateFeatureOn)
                error(message('Simulink:Logging:DatasetInitialStateRapidAccelNoSupported'));
            end
            validOperatingPoint=true;

            if isempty(initialState.rapidAcceleratorLoggedStates)
                warning(message('Simulink:op:OnlyRestoringLoggedStateFromNormalOPWarn'));
                validOperatingPoint=false;
            end

            if logOpts.hasCustomCode
                warning(message('Simulink:op:CustomCodeInModelRapidAccelOperatingPointWarn',mdl));
                validOperatingPoint=false;
            end

            if(validOperatingPoint&&...
                (~isequal(initialState.platform,buildData.computer.arch)))
                warning(message(...
                'Simulink:op:PlatformMisMatchInRapidAccelOperatingPointWarn',mdl,...
                initialState.platform,buildData.computer.arch));
                validOperatingPoint=false;
            end

            if validOperatingPoint


                if~(logOpts.IsMaxStepSizeAuto&&logOpts.IsVariableStepSolver)

                    stepSizeDiff=(initialState.fundamentalStepSize-...
                    buildData.fundamentalDiscreteRate);



                    if(abs(stepSizeDiff)>128*eps(initialState.fundamentalStepSize))
                        warning(message(...
                        'Simulink:op:StepSizeMisMatchInRapidAccelOperatingPointWarn',...
                        num2str(initialState.fundamentalStepSize),...
                        num2str(buildData.fundamentalDiscreteRate)));
                        validOperatingPoint=false;
                    end
                end
            end

            if(validOperatingPoint&&...
                ~isequal(initialState.checksum,...
                load(get_checksum_file(mdl,buildData.buildDir)).raccelChecksum))
                warning(message('Simulink:op:ChecksumMisMatchInRapidAccelOperatingPointWarn',mdl));
                validOperatingPoint=false;
            end



            if validOperatingPoint&&...
                (~isequal(logOpts.Solver,buildData.compiledSolverName)||...
                ~isequal(initialState.solver,buildData.compiledSolverName))
                warning(message(...
                'Simulink:op:SolverMisMatchInRapidAccelOperatingPointWarn',...
                initialState.solver,...
                buildData.compiledSolverName));
            end



            signals=struct;
            if isInitialStateDataset
                assert(isempty(initialState.loggedStates)||isInitialStateDataset);
                signals=dataset_initial_state_utils('getDatasetInitialState',initialState.loggedStates,buildData);
            else
                assert(isempty(initialState.loggedStates)||isstruct(initialState.loggedStates));
                signals=initialState.loggedStates;
            end

            if~validOperatingPoint


                logOpts.InitialState=struct('signals',signals,...
                'snapshotTime',initialState.snapshotTime,...
                'timeOfNextContinuousVariableHit',...
                initialState.miscData.miscData.timeOfNextContinuousVariableHit);
                if initialState.snapshotTime>=logOpts.StopTime
                    error(message(...
                    'SimulinkExecution:OperatingPoint:StopTimeLessOrEqualToSnapshotTime',...
                    mdl,...
                    num2str(logOpts.StopTime),...
                    num2str(initialState.snapshotTime)));
                end
            else


                if~isequal(initialState.startTime,logOpts.StartTime)
                    warning(message(...
                    'Simulink:SimState:SimStateOverrideTStartWarn',...
                    mdl,...
                    num2str(initialState.startTime)));
                    logOpts.StartTime=initialState.startTime;
                end









                logOpts.InitialState=struct('OperatingPointData',...
                initialState.simLoopSimState.execEngineSimState,...
                'signals',...
                signals,...
                'blockSimStates',...
                initialState.blockSimStates,...
                'miscData',...
                initialState.miscData,...
                'CStateChanged',...
                initialState.cStateChanged);

            end
            SetOPFieldAccess(1);
        elseif(isequal(class(initialState),'Simulink.SimulationData.Dataset'))
            if~isDatasetInitialStateFeatureOn
                error(message('Simulink:Logging:DatasetInitialStateRapidAccelNoSupported'));
            end
            logOpts.InitialState=struct('signals',dataset_initial_state_utils('getDatasetInitialState',initialState,buildData));
        else
            logOpts.InitialState=initialState;
        end

    else
        if buildData.logging.LoadInitialState&&...
            isequal(class(initialState),'Simulink.op.ModelOperatingPoint')
            error(message('Simulink:SimState:SimStateNotSupportedInAccel'));
        end
    end

    if(isequal(class(logOpts.InitialState),'struct'))
        logOpts.LoadInitialState=buildData.logging.LoadInitialState;

        if isfield(logOpts.InitialState,'signals')
            loggedStates=logOpts.InitialState.signals;
            if isInitialStateDataset






                assert(isfield(logOpts.InitialState.signals,'loggedStates'));
                loggedStates=logOpts.InitialState.signals.loggedStates;
            end
            for i=1:length(loggedStates)


                if isfield(loggedStates(i),'values')
                    dataset_initial_state_utils('validateValues',i,loggedStates(i).values);
                end


                if isfield(loggedStates(i),'inReferencedModel')
                    dataset_initial_state_utils('validateRefModelField',i,loggedStates(i).inReferencedModel,mdl);
                end


                if isfield(loggedStates(i),'blockName')
                    dataset_initial_state_utils('validateBlockPath',i,loggedStates(i).blockName,mdl);
                end


                if isfield(loggedStates(i),'stateName')
                    dataset_initial_state_utils('validateStateName',i,loggedStates(i).stateName,mdl);
                end


                if isfield(loggedStates(i),'label')
                    dataset_initial_state_utils('validateLabel',i,loggedStates(i).label,mdl);
                end
            end
        end
    end

    fldStr=findStr(simOptsFields,'MaxDataPoints');
    if(~isempty(fldStr)&&...
        ~isempty(buildData.simOpts.(fldStr)))
        logOpts.MaxDataPoints=buildData.simOpts.(fldStr);
    end

    fldVal=[];
    fldStr=findStr(simOptsFields,'Decimation');
    if~isempty(fldStr)
        fldVal=buildData.simOpts.(fldStr);
    end
    if isempty(fldVal)
        fldValStr=get_param(mdl,'Decimation');
        fldVal=str2double(fldValStr);
        if isnan(fldVal)
            if~Simulink.isRaccelDeployed
                [fldVal,fldValExists]=slResolve(fldValStr,mdl);
            else
                [fldVal,fldValExists]=eval_string_with_workspace_resolution(...
                fldValStr,...
                mdl,...
buildData...
                );
            end
            if~fldValExists
                error(message(...
                'Simulink:ConfigSet:ConfigSetEvalErr',...
                fldValStr,...
                'Decimation',...
                mdl));
            end
        end
    end

    if~isnumeric(fldVal)
        error(message(...
        'Simulink:tools:rapidAccelBadBlockDiagramParameterExpectingNumeric',...
        mdl,...
        fldValStr,...
        'Decimation'));
    end

    logOpts.Decimation=fldVal;

end


function simulationRuntimeParametersChanged=isSimulationRuntimeParametersChanged(slvrOpts,buildData)

    fldNames={...
    'MinStep',...
    'RelTol',...
    'AbsTol',...
    'InitialStep',...
    'MaxConsecutiveMinStep',...
    'MaxConsecutiveZCs',...
    'ConsecutiveZCsStepRelTol',...
    'ZCThreshold',...
    };


    if strcmpi(buildData.MaxStep,'auto')

        if~slvrOpts.IsMaxStepSizeAuto
            simulationRuntimeParametersChanged=true;
            return;
        end
    else

        if isfield(slvrOpts,'MaxStep')&&...
            ~isequal(slvrOpts.MaxStep,str2num(buildData.MaxStep))
            simulationRuntimeParametersChanged=true;
            return;
        end
    end

    fldNum=length(fldNames);
    for i=1:fldNum
        if isfield(slvrOpts,fldNames{i})
            if~isequal(slvrOpts.(fldNames{i}),str2num(buildData.(fldNames{i})))
                simulationRuntimeParametersChanged=true;
                return;
            end
        end
    end

    simulationRuntimeParametersChanged=false;
end



function create_slvr_file(buildData)

    if buildData.opts.verbose
        fprintf('### %6.2fs :: Calling create_slvr_file\n',etime(clock,buildData.startTime));
    end

    mdl=buildData.mdl;
    slvrOpts=struct;

    simOptsFields=[];
    if~isempty(buildData.simOpts)
        simOptsFields=fieldnames(buildData.simOpts);
    end

    isemptySimOpts=isempty(simOptsFields);

    compiledSolver=buildData.compiledSolverName;
    configSetSolver=get_param(mdl,'Solver');

    slvrOpts.ConfigSetSolver=configSetSolver;
    slvrOpts.Solver=configSetSolver;

    isConfigSetSolverAuto=or(strcmpi(configSetSolver,'VariableStepAuto'),...
    strcmpi(configSetSolver,'FixedStepAuto'));

    isCompSolverDiscrete=or(strcmpi(compiledSolver,'VariableStepDiscrete'),...
    strcmpi(compiledSolver,'FixedStepDiscrete'));



    if(or(isConfigSetSolverAuto,isCompSolverDiscrete))
        slvrOpts.Solver=compiledSolver;
    end







    slvrOpts.SolverStatusFlags=buildData.solverStatusFlags;

    solverStatusFlags=slvrOpts.SolverStatusFlags;
    isAutoSolverAtCompile=...
    Simulink.RapidAccelerator.internal.AutoSolverUtil.isAutoSolverAtCompile(solverStatusFlags);

    if isAutoSolverAtCompile
        if~isConfigSetSolverAuto

            slvrOpts.SolverStatusFlags=...
            Simulink.RapidAccelerator.internal.AutoSolverUtil.clearAutoSolverAtCompile(solverStatusFlags);
        end
    end

    runTimeSolverSwitchOpts=get_param(mdl,'EnableRunTimeSolverSwitching');
    if(isfield(runTimeSolverSwitchOpts,'SpecifiedTimes'))
        specifiedTimes=eval(runTimeSolverSwitchOpts.SpecifiedTimes);
        if(~isempty(specifiedTimes))
            slvrOpts.SpecifiedTimesForRuntimeSolverSwitch=specifiedTimes;
        end
    end

    slvrOpts.NumStatesForStiffnessChecking=get_param(mdl,'NumStatesForStiffnessChecking');
    slvrOpts.StiffnessThreshold=get_param(mdl,'StiffnessThreshold');
    slvrOpts.SolverChangeInfoFileName=fullfile(buildData.buildDir,[mdl,'_SolverChangeInfo.mat']);

    jacobianMethod={'auto','SparsePerturbation','FullPerturbation','SparseAnalytical','FullAnalytical'};
    jacobianEnumValues={'0','1','2','3','4'};
    jacobianMap=containers.Map(jacobianMethod,jacobianEnumValues);
    configSetJacobianMethod=get_param(mdl,'SolverJacobianMethodControl');
    slvrOpts.ConfigSetJacobianMethod=jacobianMap(configSetJacobianMethod);

    slvrOpts.IsLinearlyImplicit=int2str(int8(strcmpi(get_param(mdl,'IsLinearlyImplicit'),'on')));


    fldNames={...
    'RelTol',...
    'AbsTol',...
    'MaxStep',...
    'MinStep',...
    'MaxConsecutiveMinStep',...
    'InitialStep',...
    'MaxOrder',...
    'ODENIntegrationMethod',...
    'DaesscMode',...
    'ConsecutiveZCsStepRelTol',...
    'MaxConsecutiveZCs',...
    'ExtrapolationOrder',...
    'NumberNewtonIterations',...
    'SolverResetMethod',...
    'MaxZcBracketingIterations',...
    'ZCThreshold',...
'MaxZcPerStep'...
    };
    fldNum=length(fldNames);
    fldVal=cell(1,fldNum);
    if~isemptySimOpts
        for i=1:fldNum
            fldStr=findStr(simOptsFields,fldNames{i});
            if~isempty(fldStr)
                fldVal{i}=buildData.simOpts.(fldStr);
            end
        end
    end

    [startT,stopT]=sl('get_start_stop_times',buildData);
    slvrOpts.StartTime=startT;
    slvrOpts.StopTime=stopT;

    slvrOpts.IsMaxStepSizeAuto=strcmpi(get_param(mdl,'MaxStep'),'auto');
    slvrOpts.IsMinStepSizeAuto=strcmpi(get_param(mdl,'MinStep'),'auto');
    slvrOpts.IsVariableStepSolver=strcmpi(get_param(mdl,'SolverType'),'Variable-step');
    slvrOpts.hasCustomCode=~isempty(get_param(mdl,'SimCustomHeaderCode'))||...
    ~isempty(get_param(mdl,'SimCustomSourceCode'));

    for i=1:fldNum
        if isempty(fldVal{i})
            fldValStr=get_param(mdl,fldNames{i});




            if strcmpi(fldNames{i},'MaxStep')
                fldValStr=buildData.compiledStepSize;



                if(strcmpi(get_param(mdl,'MaxStep'),'auto'))
                    if((slsvTestingHook('DisableFreqAnalysisForAutoHmax')>0)||...
                        strcmpi(buildData.hasSrcBlksForAutoHmaxCalc,'off'))
                        tStart=slvrOpts.StartTime;
                        tStop=slvrOpts.StopTime;

                        if((tStop==tStart)||isinf(tStop))
                            hMax=0.2;
                        else
                            hMax=(tStop-tStart)/50;
                        end
                        fldValStr=num2str(hMax);
                    end
                end
            end

            stringFields={...
'SolverResetMethod'...
            ,'ODENIntegrationMethod',...
            'DaesscMode',...
            };
            if any(strcmp(fldNames{i},stringFields))

                fldVal{i}=fldValStr;
            elseif ischar(fldValStr)
                fldVal{i}=str2num(fldValStr);
            else
                fldVal{i}=fldValStr;
            end
        end
        if~isnan(fldVal{i})
            slvrOpts.(fldNames{i})=fldVal{i};
        end
    end


    fldNames={...
'MaxNumMinSteps'...
    };
    fldNum=length(fldNames);
    for i=1:fldNum
        fldValStr=get_param(mdl,fldNames{i});
        if ischar(fldValStr)
            fldValNum=str2double(fldValStr);
        else
            fldValNum=fldValStr;
        end

        slvrOpts.(fldNames{i})=fldValNum;
    end


    fldDiagnosticNames={...
    'MinStepSizeMsg',...
    'MaxConsecutiveZCsMsg',...
'SolverPrmCheckMsg'

    };
    fldDiagnosticNum=length(fldDiagnosticNames);
    for i=1:fldDiagnosticNum
        fldValStr=get_param(mdl,fldDiagnosticNames{i});
        slvrOpts.(fldDiagnosticNames{i})=fldValStr;
    end


    slvrOpts.SaveSolverProfileInfo=false;

    if strcmp(get_param(mdl,'SaveSolverProfileInfo'),'on')
        slvrOpts.SaveSolverProfileInfo=true;
        solverProfileParams={'SolverProfileInfoName',...
        'SolverProfileInfoCollectionStartTime',...
        'SolverProfileInfoMaxSize',...
        'SolverProfileInfoLevel'};

        numspparams=length(solverProfileParams);
        for p=1:numspparams
            pvalue=get_param(mdl,solverProfileParams{p});
            slvrOpts.(solverProfileParams{p})=pvalue;
        end
        stateZcInfoFile=[mdl,'_solver_info.mat'];
        slvrOpts.SolverProfileInfoInputFileName=...
        fullfile(buildData.buildDir,stateZcInfoFile);
        slvrOpts.SolverProfileInfoOutputFileName=...
        fullfile(buildData.buildDir,[slvrOpts.SolverProfileInfoName,'.mat']);
    end

    slvrOpts.ParallelExecutionEngineMode=double(...
    slsvTestingHook('UseSimplifiedParallelExecutionEngine')>0);
    slvrOpts.ParallelExecutionInRapidAccelerator=double(...
    slfeature('ForEachParallelExecutionInRapidAccel')>0&&...
    ~slsvTestingHook('DisableParallelExecutionEngineInRapidAccelExe')&&...
    ~strcmp(get_param(mdl,'MultithreadedSim'),'off'));
    slvrOpts.ParallelExecutionProfiling=double(strcmp(get_param(mdl,'ParallelExecutionProfiling'),'on'));


    slvrOpts.ParallelExecutionMaxNumThreads=double(...
    loc_get_ForEach_parallel_execution_max_num_threads(mdl));

    slvrOpts.DumpParallelExecutionProfilingInfo=double(...
    slsvTestingHook('DisplayParallelExecutionEngineProfilingInfo')>0);

    parallelExecutionProfilingOutputFilename=get_param(mdl,'ParallelExecutionProfilingOutputFilename');
    if isempty(parallelExecutionProfilingOutputFilename)
        parallelExecutionProfilingOutputFilename=...
        'parallelExecutionProfilingOutput.txt';
    end
    slvrOpts.ParallelExecutionProfilingOutputFilename=...
    fullfile(buildData.buildDir,parallelExecutionProfilingOutputFilename);

    slvrOpts.ParallelExecutionNodeExecutionModesFilename=...
    fullfile(buildData.buildDir,'parallelExecutionNodeExecutionModes.txt');

    if get_param(mdl,'UseSLExecSimBridge')>0
        slvrOpts.serializedModelInfo=buildData.serializedModelInfo;
    end

    slvrOpts.isExportFunction=buildData.isExportFunction;
    slvrOpts.DecoupledContinuousIntegration=buildData.DecoupledContinuousIntegration;
    slvrOpts.OptimalSolverResetCausedByZc=buildData.OptimalSolverResetCausedByZc;




    fldRefine=findStr(simOptsFields,'Refine');
    fldOptPts=findStr(simOptsFields,'OutputPoints');
    ignoreBdOutOpt=...
    (~isempty(buildData.timeSpan)||...
    (~isemptySimOpts&&...
    ((~isempty(fldRefine)&&...
    ~isempty(buildData.simOpts.(fldRefine)))||...
    (~isempty(fldOptPts)&&...
    ~isempty(buildData.simOpts.(fldOptPts))))));
    if ignoreBdOutOpt
        if~isempty(buildData.timeSpan)
            slvrOpts.OutputTimes=buildData.timeSpan;
        end
        if~isemptySimOpts
            if(~isempty(fldRefine)&&...
                ~isempty(buildData.simOpts.(fldRefine)))
                slvrOpts.Refine=buildData.simOpts.(fldRefine);
            end
            if(~isempty(fldOptPts)&&...
                ~isempty(buildData.simOpts.(fldOptPts)))
                slvrOpts.OutputTimesOnly=...
                isequal(lower(buildData.simOpts.(fldOptPts)),'specified');
            end
        end
    elseif isequal(get_param(mdl,'SolverType'),'Variable-step')
        outputOption=get_param(mdl,'OutputOption');
        if isequal(outputOption,'RefineOutputTimes')
            refineOutputTimes=get_param(mdl,'Refine');
            if~Simulink.isRaccelDeployed
                [slvrOpts.Refine,refineExprExists]=slResolve(refineOutputTimes,mdl);
            else
                [slvrOpts.Refine,refineExprExists]=eval_string_with_workspace_resolution(...
                refineOutputTimes,...
                mdl,...
buildData...
                );
            end
            if~refineExprExists
                error(message(...
                'Simulink:ConfigSet:ConfigSetEvalErr',...
                refineOutputTimes,...
                'Refine',...
                mdl));
            end
        else
            slvrOpts.Refine=1;
            outputTimesStr=get_param(mdl,'OutputTimes');
            outputTimes=['[',outputTimesStr,']'];


            if~Simulink.isRaccelDeployed
                [outputTimes,outputTimesExprExists]=slResolve(outputTimes,mdl);
            else
                [outputTimes,outputTimesExprExists]=eval_string_with_workspace_resolution(...
                outputTimes,...
                mdl,...
buildData...
                );
            end
            if~outputTimesExprExists
                error(message(...
                'Simulink:ConfigSet:ConfigSetEvalErr',...
                outputTimesStr,...
                'OutputTimes',...
                mdl));
            end

            if(iscolumn(outputTimes))
                outputTimes=outputTimes.';
            end
            if(isrow(outputTimes))
                if(startT<min(outputTimes))
                    outputTimes=[startT,outputTimes];
                end
                if(stopT>max(outputTimes))
                    outputTimes=[outputTimes,stopT];
                end
            end
            slvrOpts.OutputTimes=outputTimes;
            if isequal(outputOption,'SpecifiedOutputTimes')
                slvrOpts.OutputTimesOnly=true;
            else







                slvrOpts.OutputTimesOnly=false;
            end

        end
    end



    loggingIntervalsStr=get_param(mdl,'LoggingIntervals');
    loggingIntervals='[-inf, inf]';
    if isequal(get_param(mdl,'ReturnWorkspaceOutputs'),'on')
        loggingIntervals=loggingIntervalsStr;
    end
    if~Simulink.isRaccelDeployed
        [loggingIntervals,loggingIntervalsExprExists]=slResolve(loggingIntervals,mdl);
    else
        [loggingIntervals,loggingIntervalsExprExists]=eval_string_with_workspace_resolution(...
        loggingIntervals,...
        mdl,...
buildData...
        );
    end
    if~loggingIntervalsExprExists
        error(message(...
        'Simulink:ConfigSet:ConfigSetEvalErr',...
        loggingIntervalsStr,...
        'LoggingInterval',...
        mdl));
    end
    slvrOpts.LoggingIntervals=loggingIntervals;

    unconstrainedPartitionHitTimes=[];
    unconstrainedPartitionHitTimesSpec=get_param(mdl,'AperiodicPartitionHitTimes');
    if(~isempty(unconstrainedPartitionHitTimesSpec))
        unconstrainedPartitionHitTimes=...
        sltp.internal.serializeHitTimes(...
        unconstrainedPartitionHitTimesSpec,mdl);
    end
    slvrOpts.AperiodicPartitionHitTimes=unconstrainedPartitionHitTimes;


    slvrOpts.SampleTimeParameterization=double(slfeature('SampleTimeParameterization'));
    if slvrOpts.SampleTimeParameterization
        if isequal(get_param(mdl,'ScaleDiscreteRates'),'on')
            slvrOpts.ScaleDiscreteRates=true;
            scaleFactorStr=get_param(mdl,'DiscreteRateScaleFactor');
            slvrOpts.DiscreteRateScaleFactor=eval_with_resolution(...
            scaleFactorStr,'DiscreteRateScaleFactor',mdl,buildData);
            if~slvrOpts.IsVariableStepSolver
                fixedStepStr=get_param(mdl,'FixedStep');
                if~strcmp(fixedStepStr,'auto')
                    slvrOpts.FixedStepSize=eval_with_resolution(...
                    fixedStepStr,'FixedStep',mdl,buildData);
                else
                    slvrOpts.FixedStepSize=0.0;
                end
            end
        else
            slvrOpts.ScaleDiscreteRate=false;
        end
    end


    slvrOpts.diaglogdb_dir=buildData.buildDir;
    slvrOpts.diaglogdb_sid=buildData.diaglogdb_sid;

    slvrOpts=create_log_data(buildData,slvrOpts);
    nTmpVar=length(buildData.tmpVarPrefix);
    slvrFile=get_slvr_file(buildData.buildDir,buildData.tmpVarPrefix);
    fromFile=buildData.fromFile;
    toFile=buildData.toFile;


    slvrOpts.SimulationRuntimeParametersChanged=isSimulationRuntimeParametersChanged(slvrOpts,buildData);

    buildData.operatingPointFile=get_operating_point_file(buildData.buildDir,...
    buildData.tmpVarPrefix);
    slvrOpts.LoggedStatesTemplateFileName=get_build_initial_state_file(buildData.buildDir);


    losFileName=get_live_output_specs_file_name(buildData.buildDir);


    if slfeature('RaccelSimulationPacing')>0
        slvrOpts.PaceErrorFile=get_pace_error_file(buildData.buildDir,mdl);
        slvrOpts.SavePaceError=buildData.pacingInfo.SavePaceError;
        if isequal(buildData.pacingInfo.EnablePacing,matlab.lang.OnOffSwitchState('on'))
            if buildData.isMenuSim
                warning(message('Simulink:SimulationPacing:RapidMenuSimNotSupported'));
            else
                slvrOpts.EnablePacing=buildData.pacingInfo.EnablePacing;
                slvrOpts.PacingRate=buildData.pacingInfo.PacingRate;
                warning('backtrace','off');
                warning(message('Simulink:SimulationPacing:PacingStatus'));
                warning('backtrace','on');
            end
        end
    end

    for i=1:nTmpVar
        slvrOpts.OperatingPointFileName=buildData.operatingPointFile{i};


        if Simulink.isRaccelDeployed
            slvrOpts.SimulinkVersion=0;
        else
            slvrOpts.SimulinkVersion=get_param(0,'version');
        end

        slvrOpts.LiveOutputSpecsFileName=losFileName;

        save(slvrFile{i},'-v7','slvrOpts','fromFile','toFile');
    end

end



function losFileName=get_live_output_specs_file_name(buildDir)
    losFileName=fullfile(buildDir,'tmwinternal','liveOutputSpecs.mat');

end



function loc_save_live_output_specs(buildDir,liveOutputSpecs)
    losFileName=get_live_output_specs_file_name(buildDir);
    save(losFileName,'-v7','liveOutputSpecs');
end




function loc_create_prm_file(buildDir,tmpVarPrefix,rtp)
    prmFile=get_prm_file(buildDir,tmpVarPrefix);
    nTmpVar=length(tmpVarPrefix);
    if~isempty(rtp)
        assert(isequal(nTmpVar,length(rtp.parameters)));
    end

    for i=1:nTmpVar
        if exist(prmFile{i},'file'),delete(prmFile{i});end
        if~isempty(rtp)
            modelChecksum=rtp.modelChecksum;
            parameters=rtp.parameters{i};
            globalParameterInfo=rtp.globalParameterInfo;
            save(prmFile{i},'-v7','modelChecksum','parameters','globalParameterInfo');
        end
    end
end




function create_siglogselector_file(buildData)

    if buildData.opts.verbose
        fprintf('### %6.2fs :: Calling create_siglogselector_file\n',etime(clock,buildData.startTime));
    end

    mdl=buildData.mdl;
    siglogselectorFile=...
    get_siglogselector_file(buildData.buildDir,buildData.tmpVarPrefix);
    if(Simulink.isRaccelDeployed)
        standaloneModelLoggingInfoFileName=...
        get_model_logging_info_file(buildData.buildDir);
        modelLoggingInfo=load(standaloneModelLoggingInfoFileName);
        dataLoggingOverride=modelLoggingInfo.dataLoggingOverrideStruct;
    else
        dataLoggingOverrideMcos=get_param(mdl,'DataLoggingOverride');
        dataLoggingOverrideMcos=dataLoggingOverrideMcos.updateModelName(mdl);
        dataLoggingOverrideMcos=loc_dataLoggingOverride_check_signals(dataLoggingOverrideMcos,mdl);
        dataLoggingOverride=dataLoggingOverrideMcos.utStruct;
    end
    outputLogging=buildData.logging.SaveOutput;
    signalLogging=buildData.logging.SignalLogging;
    sigLogPlugin0=0;
    sigLogPluginPath=...
    sigstream_mapi('getSignalStorageImplLibraryPath');
    sigLogPluginParameters=...
    sigstream_mapi('getSignalStorageParameters');
    sigstreamDetection=0;
    strLoggingToFile=get_param(mdl,'LoggingToFile');
    loggingToFile=strcmp(strLoggingToFile,'on');
    if loggingToFile
        signalLoggingToPersistentStorage=2;
    else
        signalLoggingToPersistentStorage=0;
    end

    disableSignalLoggingToR2forXIL=0;

    for runNumber=1:buildData.numRuns
        signalStorageParameters=get_param(mdl,'ResolvedLoggingFileName');

        isMultisim=~isempty(buildData.multiSimInfo);
        if isMultisim||(buildData.numRuns>1)
            if isMultisim
                runId=buildData.multiSimInfo.runInfo(runNumber).RunId;
            else
                runId=runNumber;
            end
            unusedWorkingDirArg=[];
            signalStorageParameters=MultiSim.internal.getUniqueLoggingFileName(...
            unusedWorkingDirArg,...
            signalStorageParameters,...
            runId);
        end

        if loggingToFile
            for counter=1:length(buildData.toFile)
                if strcmp(signalStorageParameters,buildData.toFile(counter).filename)
                    msgDescription=message('Simulink:Logging:SlFileLoggingDescription');
                    description=msgDescription.getString;
                    exception=MSLException(...
                    [],...
                    message(...
                    'Simulink:blocks:DupDataLogFileName2',...
                    signalStorageParameters,...
                    buildData.toFile(counter).blockPath,...
description...
                    )...
                    );
                    exception.throw;
                end
            end

            wName=which(signalStorageParameters);
            if(isempty(wName))
                wName=signalStorageParameters;
            end
            for counter=1:length(buildData.fromFileBlocks)
                if strcmp(wName,buildData.fromFile(counter).filename)
                    msgDescription=message('Simulink:Logging:SlFileLoggingDescription');
                    description=msgDescription.getString;
                    exception=MSLException(...
                    [],...
                    message(...
                    'Simulink:blocks:DupToFileFromFileFileName',...
                    signalStorageParameters,...
                    buildData.fromFile(counter).blockPath,...
description...
                    )...
                    );
                    exception.throw;
                end
            end
        end

        compressedTimeLogical=sigstream_mapi('getCompressedTime');
        compressedTime=double(compressedTimeLogical);

        if~Simulink.isRaccelDeployed
            recordData=Simulink.sdi.getRecordData();
        else
            recordData=true;
        end

        save(...
        siglogselectorFile{runNumber},...
        '-v7',...
        'outputLogging',...
        'dataLoggingOverride',...
        'signalLogging',...
        'sigLogPlugin0',...
        'sigLogPluginPath',...
        'sigLogPluginParameters',...
        'sigstreamDetection',...
        'signalLoggingToPersistentStorage',...
        'signalStorageParameters',...
        'compressedTime',...
        'recordData',...
'disableSignalLoggingToR2forXIL'...
        );
    end

end



function inpFile=get_inp_file(buildDir,tmpVarPrefix)
    nTmpVar=length(tmpVarPrefix);
    inpFile=cell(1,nTmpVar);
    for i=1:nTmpVar
        inpFile{i}=[buildDir,filesep,'in',tmpVarPrefix{i},'.mat'];
    end
end



function slvrFile=get_slvr_file(buildDir,tmpVarPrefix)
    nTmpVar=length(tmpVarPrefix);
    slvrFile=cell(1,nTmpVar);
    for i=1:nTmpVar
        slvrFile{i}=[buildDir,filesep,'sl',tmpVarPrefix{i},'.mat'];
    end
end



function outFile=get_out_file(buildDir,tmpVarPrefix)
    nTmpVar=length(tmpVarPrefix);
    outFile=cell(1,nTmpVar);
    for i=1:nTmpVar
        outFile{i}=[buildDir,filesep,'ou',tmpVarPrefix{i},'.mat'];
    end
end



function sFcnInfoFile=get_sfcn_info_file(buildDir,mdlName)
    sFcnInfoFile=[buildDir,filesep,mdlName,'_sfcn_info.mat'];
end



function[sourceCodeExists,success]=find_sfcn_source_code(sFcnName)
    cSFcnName=[sFcnName,'.c'];
    cppSFcnName=[sFcnName,'.cpp'];
    tlcSFcnName=[sFcnName,'.tlc'];
    sourceCodeExists=false;
    success=true;

    sFcnMexFile=which(sFcnName);
    [sFcnMexPath,~,~]=fileparts(sFcnMexFile);


    tlcExistsWithMexFile=exist([sFcnMexPath,filesep,tlcSFcnName],'file');
    if tlcExistsWithMexFile==2
        sourceCodeExists=true;
        success=true;
        return;
    end




    emitWarning=false;


    exists=exist(cSFcnName,'file');
    existsWithMexFile=exist([sFcnMexPath,filesep,cSFcnName],'file');

    if existsWithMexFile==2
        sourceCodeExists=true;
        success=true;
        return;
    elseif exists==2
        sourceCodeExists=false;
        emitWarning=true;
    else

        exists=exist(cppSFcnName,'file');
        existsWithMexFile=exist([sFcnMexPath,filesep,cppSFcnName],'file');

        if existsWithMexFile==2
            sourceCodeExists=true;
            success=true;
            return;
        elseif exists==2
            sourceCodeExists=false;
            emitWarning=true;
        end
    end

    if~sourceCodeExists


        if~isempty(sFcnMexPath)
            rtwMakeCfgName=fullfile(sFcnMexPath,'rtwmakecfg');

            if(exist([rtwMakeCfgName,'.m'],'file')>0||...
                exist([rtwMakeCfgName,'.p'],'file')>0)

                currDir=pwd;
                cd(sFcnMexPath);

                try
                    rtwCfg=eval('rtwmakecfg');
                catch ME %#ok<NASGU>
                    rtwCfg=false;
                end

                cd(currDir);

                success=true;
                if islogical(rtwCfg)&&rtwCfg==false
                    cd(currDir);
                    sourceCodeExists=false;
                    success=false;

                end

                if success
                    if isfield(rtwCfg,'sourcePath')

                        sourceDirs=rtwCfg.sourcePath;

                        if~iscell(sourceDirs)
                            error(message('Simulink:tools:rapidAccelSFcnErrorDuringrtwmakecfg',sFcnName));
                        end

                        for i=1:length(sourceDirs)

                            if~ischar(sourceDirs{i})
                                error(message('Simulink:tools:rapidAccelSFcnErrorDuringrtwmakecfg',sFcnName));
                            end

                            exists=exist([sourceDirs{i},filesep,cSFcnName],'file');
                            if exists==2
                                sourceCodeExists=true;
                                return;
                            else
                                exists=exist([sourceDirs{i},filesep,cppSFcnName],'file');
                                if exists==2
                                    sourceCodeExists=true;
                                    return;
                                else
                                    sourceCodeExists=false;
                                end
                            end
                        end
                    end
                end
            end
        end

        if~sourceCodeExists

            simulinkSrcPath=[matlabroot,filesep,'simulink',filesep,'src'];

            existResult=exist([simulinkSrcPath,filesep,cSFcnName],'file');

            if existResult==2
                sourceCodeExists=true;
                return;
            else
                existResult=exist([simulinkSrcPath,filesep,cppSFcnName],'file');
                if existResult==2
                    sourceCodeExists=true;
                    return;
                end
            end
        end
    end

    if emitWarning
        warning(message(...
        'Simulink:tools:rapidAccelSFcnSourceExistsButUsingMexFileAnyways',...
        sFcnName));
    end
end



function simMetadataFile=get_simMetadata_file(buildDir,tmpVarPrefix)
    nTmpVar=length(tmpVarPrefix);
    simMetadataFile=cell(1,nTmpVar);
    for i=1:nTmpVar
        simMetadataFile{i}=[buildDir,filesep,'md',tmpVarPrefix{i},'.mat'];
    end
end



function sigstreamFile=get_sigstream_file(buildDir,tmpVarPrefix)
    nTmpVar=length(tmpVarPrefix);
    sigstreamFile=cell(1,nTmpVar);
    for i=1:nTmpVar
        sigstreamFile{i}=[buildDir,filesep,'lo',tmpVarPrefix{i},'.mat'];
    end
end



function siglogselectorFile=get_siglogselector_file(buildDir,tmpVarPrefix)
    xtester_emulate_ctrl_c('get_siglogselector_file_ctrl_c');
    nTmpVar=length(tmpVarPrefix);
    siglogselectorFile=cell(1,nTmpVar);
    for i=1:nTmpVar
        siglogselectorFile{i}=...
        [buildDir,filesep,'se',tmpVarPrefix{i},'.mat'];
    end
end



function extInputSettingsFile=get_ext_input_settings_file(buildDir)
    extInputSettingsFile=[buildDir,filesep,'ext_input_settings.mat'];
end



function mdlLoggingInfoFile=get_model_logging_info_file(buildDir)
    mdlLoggingInfoFile=[buildDir,filesep,'standaloneModelLoggingInfo.mat'];
end



function fromFileFile=get_runtorunstaticdata_file(buildDir,tmpVarPrefix)
    nTmpVar=length(tmpVarPrefix);
    fromFileFile=cell(1,nTmpVar);
    for i=1:nTmpVar
        fromFileFile{i}=[buildDir,filesep,'rs',tmpVarPrefix{i},'.mat'];
    end
end



function isLoggingEnabled=is_logging_enabled(buildData)
    format=lower(buildData.logging.SaveFormat);
    isLoggingEnabled=false;


    if~isempty(buildData.toFileBlocks)
        isLoggingEnabled=true;
        return;
    end

    datasetOutput=strcmp(format,'dataset')&&...
    buildData.logging.SaveOutput;
    if buildData.logging.SignalLogging||datasetOutput
        isLoggingEnabled=true;
        return;
    end
    stateOrOutput=(buildData.logging.SaveOutput||...
    buildData.logging.SaveState||...
    buildData.logging.SaveFinalState);
    if(strcmp(format,'structurewithtime'))
        if stateOrOutput
            isLoggingEnabled=true;
            return;
        end
    end

    if(strcmp(format,'array')||strcmp(format,'structure'))&&...
        buildData.logging.SaveTime
        if stateOrOutput
            isLoggingEnabled=true;
        end
    end
end



function hasInstrumentedSignals=has_instrumented_signals(buildData)
    hasInstrumentedSignals=false;

    if buildData.hasInstrumentedSignals
        hasInstrumentedSignals=true;
        return;
    end
end



function print_message(msg,varargin)
    prefix='';
    buildData=[];

    if nargin>1,buildData=varargin{1};end
    if nargin>2,prefix=varargin{2};end

    if~isempty(buildData)&&buildData.opts.verbose
        fprintf('%s### %6.2fs :: %s\n',...
        prefix,etime(clock,buildData.startTime),msg);
    end
end





function set_status_string(iMdl,iStatusId,varargin)
    if~isempty(iStatusId)
        statusMsg=message(iStatusId,varargin{:}).getString;
    else
        statusMsg='';
    end
    set_param(iMdl,'StatusString',statusMsg);
end








function buildData=loc_basic_setup(iMdl,buildData,varargin)



















    if ishandle(iMdl),iMdl=get_param(iMdl,'Name');end
    buildData.mdl=iMdl;
    buildData.startTime=clock;
    buildData.loggingPfx='tmp_raccel_';

    buildData.logging.LogStateDataForArrayLogging=true;
    buildData.logging.LogStateDataForStructLogging=true;

    if slfeature('RaccelSimulationPacing')>0
        buildData.pacingInfo.EnablePacing=false;
        buildData.pacingInfo.SavePaceError=false;
        buildData.pacingInfo.PacingRate=0;
    end










    buildData.opts.debug=get_opt('debug',0);


    buildData.opts.profile=get_opt('profile',0);


    buildData.opts.verbose=get_opt('verbose',0);
    buildData.opts.extModeVerbose=get_opt('extModeVerbose',0);
    buildData.opts.maxAttempts=get_opt('maxAttempts',40);
    buildData.opts.pauseInterval=get_opt('pauseInterval',0.5);
    buildData.opts.connectWaitTime=get_opt('connectWaitTime',300);
    buildData.opts.internalTesting=get_opt('internalTesting',[]);
    buildData.opts.deploymentStartDir=get_opt('deploymentStartDir',[]);
    buildData.opts.keepArtifacts=get_opt('keepArtifacts',[]);
    buildData.opts.simServer=get_opt('simServer',0);

    buildData.codeWasUpToDate=1;

    buildData.MaxStep='0';
    buildData.MinStep='0';
    buildData.RelTol='0';
    buildData.AbsTol='0';
    buildData.InitialStep='0';
    buildData.MaxConsecutiveMinStep='0';
    buildData.MaxConsecutiveZCs='0';
    buildData.ConsecutiveZCsStepRelTol='0';
    buildData.ZCThreshold='0';


    if nargin>=18
        buildData.timeSpan=varargin{1};
        buildData.simOpts=varargin{2};
        buildData.extInputs=varargin{3};
        buildData.numReturnValues=varargin{4};
        buildData.treatDstWkspAsReadOnly=varargin{5};
        buildData.returnDstWkspOutput=varargin{6};
        buildData.runningInParallel=varargin{7};
        buildData.okayToPushNags=varargin{8};
        if(~isempty(varargin{10}))
            buildData.startTime=varargin{10};
        end


        if~isempty(varargin{11})
            buildData.logging.InitialState=varargin{11};
        end


        if~isempty(varargin{12})
            buildData.simInputWorkspaces=...
            Simulink.RapidAccelerator.internal.createSimInputWorkspaces(varargin{12});
        end
        buildData.externalInputsFcn=varargin{13};
        buildData.externalOutputsFcn=varargin{14};
        buildData.liveOutputsFcn=varargin{15};
        buildData.runtimeFcns=varargin{16};
    end
    buildData.runtimeFcnsInfo=slsim.internal.RuntimeFcnsInfo.empty();

    if isequal(get_param(iMdl,'ReturnWorkspaceOutputs'),'on')
        buildData.treatDstWkspAsReadOnly=true;
        buildData.returnDstWkspOutput=true;
        buildData.returnDstWkspOutputName=...
        get_param(iMdl,'ReturnWorkspaceOutputsName');
    end

    hasExternalInputsData=~isempty(buildData.extInputs)||...
    isequal(get_param(iMdl,'LoadExternalInput'),'on');

    hasInputsCallbacks=~isempty(buildData.externalInputsFcn)||...
    (~isempty(buildData.runtimeFcns)&&~isempty(buildData.runtimeFcns.InputFcns));
    if(hasExternalInputsData&&hasInputsCallbacks)
        error(message('SimulinkExecution:SimulationService:ExternalInputsAndExternalInputsFcn'));
    end


    if length(varargin)>=12&&~isempty(varargin{12})
        buildData.simInputWorkspaces=...
        Simulink.RapidAccelerator.internal.createSimInputWorkspaces(varargin{12});

        buildData.expressionEvaluator=...
        Simulink.RapidAccelerator.internal.createExpressionEvaluator(...
        iMdl,...
        buildData.simInputWorkspaces...
        );
    else
        buildData.expressionEvaluator=...
        Simulink.RapidAccelerator.internal.createExpressionEvaluator(iMdl,[]);
    end

    simOptsFields=[];
    if~isempty(buildData.simOpts)
        if iscell(buildData.simOpts)
            buildData.simOpts=struct(buildData.simOpts{:});
        end
        simOptsFields=fieldnames(buildData.simOpts);
    end

    buildData.outputT=true;
    buildData.outputX=true;
    buildData.outputY=true;
    if buildData.returnDstWkspOutput
        buildData.numReturnValues=buildData.numReturnValues-1;
    end

    save_name_map=containers.Map;

    save_name_map('SimulationMetadata')=...
    message('Simulink:Logging:SimulationMetadataLoggingLocation').getString;



    buildData.logging.SignalLogging=isequal(get_param(iMdl,'SignalLogging'),'on');
    if buildData.logging.SignalLogging
        buildData.logging.SignalLoggingName=get_param(iMdl,'SignalLoggingName');
        loc_check_logging_save_name(...
        buildData.logging.SignalLoggingName,true,'Simulink:Logging:SignalLoggingLocation',save_name_map);
    end

    buildData.IATesting.IntrusiveAccessorTesting=isequal(slsvTestingHook('SLIO_IA_testing'),1);
    if buildData.IATesting.IntrusiveAccessorTesting
        buildData.IATesting.IATestingName='IA_output';
    end

    if isequal(get_param(iMdl,'DatasetSignalFormat'),'timetable')
        buildData.logging.datasetSignalFormat='timetable';
    else
        buildData.logging.datasetSignalFormat='timeseries';
    end

    if buildData.numReturnValues<=0
        buildData.logging.SaveTime=isequal(get_param(iMdl,'SaveTime'),'on');
        if buildData.logging.SaveTime
            buildData.logging.TimeSaveName=get_param(iMdl,'TimeSaveName');
            loc_check_logging_save_name(...
            buildData.logging.TimeSaveName,true,'Simulink:Logging:TimeLoggingLocation',save_name_map);
        end
        buildData.logging.SaveState=isequal(get_param(iMdl,'SaveState'),'on');
        if buildData.logging.SaveState
            buildData.logging.StateSaveName=get_param(iMdl,'StateSaveName');
            loc_check_logging_save_name(...
            buildData.logging.StateSaveName,true,'Simulink:Logging:StateLoggingLocation',save_name_map);
        end
        buildData.logging.SaveOutput=isequal(get_param(iMdl,'SaveOutput'),'on');
        if buildData.logging.SaveOutput
            buildData.logging.OutputSaveName=get_param(iMdl,'OutputSaveName');
            loc_check_logging_save_name(...
            buildData.logging.OutputSaveName,false,'Simulink:Logging:OutputLoggingLocation',save_name_map);
        end
        fldStr=findStr(simOptsFields,'SaveFormat');
        if(~isempty(fldStr)&&...
            ~isempty(buildData.simOpts.(fldStr)))
            buildData.logging.SaveFormat=buildData.simOpts.(fldStr);
        else
            buildData.logging.SaveFormat=get_param(iMdl,'SaveFormat');
        end
    else
        buildData.logging.SaveFormat=get_param(iMdl,'SaveFormat');
    end



    buildData.logging.SaveCompleteFinalSimState=isequal(...
    get_param(iMdl,'SaveCompleteFinalSimState'),'on');

    if strcmpi(buildData.logging.SaveFormat,'dataset')


        if(slfeature('EnableRaccelDatasetAsInitialState')~=0)
            buildData.logging.SaveOperatingPoint=(get_param(iMdl,'SaveOperatingPoint')...
            ==matlab.lang.OnOffSwitchState('on'));
        end
    else
        buildData.logging.SaveOperatingPoint=(get_param(iMdl,'SaveOperatingPoint')...
        ==matlab.lang.OnOffSwitchState('on'));


        if(buildData.logging.SaveOperatingPoint&&...
            isequal(lower(buildData.logging.SaveFormat),'array'))
            buildData.logging.SaveFormat='Structure';
        end
    end

    buildData.logging.LoadInitialState=isequal(...
    get_param(iMdl,'LoadInitialState'),'on');





    if buildData.logging.LoadInitialState&&isempty(buildData.logging.InitialState)
        initialStateStr=get_param(iMdl,'InitialState');
        initialState=['[',initialStateStr,']'];
        if~Simulink.isRaccelDeployed
            buildData.logging.InitialState=slResolve(initialState,iMdl);
        else
            buildData.logging.InitialState=eval_string_with_workspace_resolution(...
            initialState,...
            iMdl,...
buildData...
            );
        end
        if isa(buildData.logging.InitialState,'Simulink.SimulationData.Dataset')...
            &&(slfeature('EnableRaccelDatasetAsInitialState')==0)
            error(message('Simulink:Logging:DatasetInitialStateRapidAccelNoSupported'));
        end
    end

    fldStr=findStr(simOptsFields,'FinalStateName');
    if(~isempty(fldStr)&&...
        ~isempty(buildData.simOpts.(fldStr)))
        buildData.logging.SaveFinalState=true;
        buildData.logging.FinalStateName=buildData.simOpts.(fldStr);
    else
        buildData.logging.SaveFinalState=...
        isequal(get_param(iMdl,'SaveFinalState'),'on');
        if buildData.logging.SaveFinalState
            buildData.logging.FinalStateName=get_param(iMdl,'FinalStateName');
            loc_check_logging_save_name(...
            buildData.logging.FinalStateName,true,'Simulink:Logging:FinalStateLoggingLocation',save_name_map);
        end
    end




    buildData.logging.isOriginalFormatDataset=false;
    if isequal(get_param(iMdl,'SaveFormat'),'Dataset')...
        &&(slfeature('EnableRaccelDatasetAsInitialState')~=0)
        if(buildData.logging.SaveFinalState)
            buildData.logging.SaveFormat='structure';
            buildData.logging.isOriginalFormatDataset=true;
        end
    end

clear save_name_map;
    fldStr=findStr(simOptsFields,'OutputVariables');
    if(~isempty(fldStr)&&...
        ~isempty(buildData.simOpts.(fldStr)))
        outputVariables=buildData.simOpts.(fldStr);
        switch(outputVariables)
        case{'tx','xt'}
            buildData.outputY=false;

        case{'ty','yt'}
            buildData.outputX=false;

        case{'xy','yx'}
            buildData.outputT=false;

        case 't'
            buildData.outputX=false;
            buildData.outputY=false;

        case 'x'
            buildData.outputT=false;
            buildData.outputY=false;

        case 'y'
            buildData.outputT=false;
            buildData.outputX=false;

        otherwise
        end
    end

    if slfeature('RaccelSimulationPacing')>0
        buildData.pacingInfo.SavePaceError=false;
        if~Simulink.isRaccelDeployed



            buildData.pacingInfo.SavePaceError=isequal(get_param(iMdl,'SavePaceError'),'on');
        end
        if isequal(get_param(iMdl,'EnablePacing'),'on')
            buildData.pacingInfo.EnablePacing=true;
            buildData.pacingInfo.PacingRate=get_param(iMdl,'PacingRate');
        end
    end

    fldStr=findStr(simOptsFields,'ConcurrencyResolvingToFileSuffix');
    if~isempty(fldStr)
        buildData.toFileSuffix=buildData.simOpts.(fldStr);
    end








    if(isfield(buildData.simOpts,'RapidAcceleratorUpToDateCheck')&&...
        strcmpi(buildData.simOpts.RapidAcceleratorUpToDateCheck,'off')&&...
        ~Simulink.isRaccelDeployed)


        rtw_checkdir;
        if~exist(get_exe_name(buildData.buildDir,buildData.mdl),'file')
            identifier='Simulink:tools:rapidAccelExeNotFound';
            modelHandle=get_param(buildData.mdl,"handle");
            throwAsCaller(MSLException(modelHandle,message(identifier,buildData.mdl)));
        end
    end

    fromFileBlocks=cell(0);%#ok<PREALL>
    toFileBlocks=cell(0);%#ok<PREALL>
    hasInstrumentedSignals=false;%#ok<NASGU>





    buildData.modelsToClose={};

    useRunToRunStaticData=...
    (isfield(buildData.simOpts,'RapidAcceleratorUpToDateCheck')&&...
    strcmpi(buildData.simOpts.RapidAcceleratorUpToDateCheck,'off'));

    runToRunStaticDataFileName=get_runtorunstaticdata_file(buildData.buildDir,{'_raccel'});



    if exist(runToRunStaticDataFileName{1},'file')
        runToRunStaticData=load(runToRunStaticDataFileName{1});
        buildData.MaxStep=runToRunStaticData.MaxStep;
        buildData.MinStep=runToRunStaticData.MinStep;
        buildData.RelTol=runToRunStaticData.RelTol;
        buildData.AbsTol=runToRunStaticData.AbsTol;
        buildData.InitialStep=runToRunStaticData.InitialStep;
        buildData.MaxConsecutiveMinStep=runToRunStaticData.MaxConsecutiveMinStep;
        buildData.MaxConsecutiveZCs=runToRunStaticData.MaxConsecutiveZCs;
        buildData.ConsecutiveZCsStepRelTol=runToRunStaticData.ConsecutiveZCsStepRelTol;
        buildData.ZCThreshold=runToRunStaticData.ZCThreshold;
    end

    if(useRunToRunStaticData)




        runToRunStaticData=load(runToRunStaticDataFileName{1});
        fromFileBlocks=runToRunStaticData.fromFileBlocks;
        toFileBlocks=runToRunStaticData.toFileBlocks;


        toFromFileMdls=cell(0);
        for i=1:length(fromFileBlocks)
            toFromFileMdls=[toFromFileMdls;fromFileBlocks{i}.model];%#ok Can't know size in advance.
        end
        for i=1:length(toFileBlocks)
            toFromFileMdls=[toFromFileMdls;toFileBlocks{i}.model];%#ok
        end
        toFromFileMdls=unique(toFromFileMdls);


        if~Simulink.isRaccelDeployed
            buildData.modelsToClose={};
            for i=1:length(toFromFileMdls)
                modelToLoad=toFromFileMdls{i};
                if(~bdIsLoaded(modelToLoad))

                    load_system(modelToLoad);

                    buildData.modelsToClose=[buildData.modelsToClose,...
                    modelToLoad];
                end
            end
        end

        buildData.computer=runToRunStaticData.computer;

        buildData.logging.LogStateDataForArrayLogging=runToRunStaticData.logStateDataForArrayLogging;
        buildData.fromFileBlocks=fromFileBlocks;
        buildData.fromFile=runToRunStaticData.fromFile;
        buildData.toFileBlocks=toFileBlocks;
        buildData.toFile=runToRunStaticData.toFile;
        buildData.hasInstrumentedSignals=runToRunStaticData.hasInstrumentedSignals;


        buildData.rootInportsInfo=runToRunStaticData.rootInportsInfo;
        buildData.rootOutportsInfo=runToRunStaticData.rootOutportsInfo;

        buildData.externalInputsFcnCompliant=runToRunStaticData.externalInputsFcnCompliant;
        buildData.externalOutputsFcnCompliant=runToRunStaticData.externalOutputsFcnCompliant;
        buildData.externalInputsFcnError=runToRunStaticData.externalInputsFcnError;
        buildData.externalOutputsFcnError=runToRunStaticData.externalOutputsFcnError;

        buildData.combinedFcnsError=runToRunStaticData.combinedFcnsError;
        buildData.runtimeFcnsInfo=runToRunStaticData.runtimeFcnsInfo;
        buildData.maxIOBufferSize=runToRunStaticData.maxIOBufferSize;




        buildData.compiledSolverName=runToRunStaticData.compiledSolverName;
        buildData.solverStatusFlags=runToRunStaticData.solverStatusFlags;
        buildData.compiledStepSize=runToRunStaticData.compiledStepSize;
        buildData.fundamentalDiscreteRate=runToRunStaticData.fundamentalDiscreteRate;
        buildData.hasSrcBlksForAutoHmaxCalc=runToRunStaticData.hasSrcBlksForAutoHmaxCalc;

        if buildData.logging.isOriginalFormatDataset
            templateInfo=load(fullfile(buildData.buildDir,'template_dataset'));
            assert(isfield(templateInfo,'templateDataset'));
            templateDataset=templateInfo.templateDataset;

            assert((isempty(templateDataset)&&isequal(class(templateDataset),'double'))||...
            isequal(class(templateDataset),'Simulink.SimulationData.Dataset'));
            buildData.templateDataset=templateDataset;
        end

        buildData.UnsupportedTypeData=runToRunStaticData.UnsupportedTypeData;
        if(~Simulink.isRaccelDeployed)


            checkValidityOfSolver(buildData);
        end



        check_validity_of_dataflow_configuration(runToRunStaticData.dataflowRebuildInfo);
        check_validity_of_SimHardwareAcceleration_configuration(runToRunStaticData.simHardwareAccelerationRebuildInfo);

        if get_param(iMdl,'UseSLExecSimBridge')>0
            buildData.serializedModelInfo=runToRunStaticData.serializedModelInfo;
        end

        buildData.isExportFunction=runToRunStaticData.isExportFunction;
        buildData.DecoupledContinuousIntegration=runToRunStaticData.DecoupledContinuousIntegration;
        buildData.OptimalSolverResetCausedByZc=runToRunStaticData.OptimalSolverResetCausedByZc;

    else
        buildData.computer.arch=computer('arch');


        rootOutports=find_system(iMdl,'SearchDepth',1,'BlockType','Outport');
        numOutports=length(rootOutports);

        rootRootOutports=cell(numOutports,1);
        oIdx=1;
        while oIdx<=numOutports
            outportPaths=find_system(iMdl,'SearchDepth',1,...
            'Port',num2str(oIdx),'BlockType','Outport');
            numBO=length(outportPaths);
            numOutports=numOutports-numBO+1;
            busPortName=get_param(outportPaths{1},'PortName');
            busPortName=strrep(busPortName,'/','//');
            rootRootOutports(oIdx)={[get_param(outportPaths{1},'Parent'),'/',busPortName]};
            oIdx=oIdx+1;
        end

        buildData.rootOutportsInfo.numOutports=numOutports;
        rootRootOutports=rootRootOutports(~cellfun('isempty',rootRootOutports));
        buildData.rootOutportsInfo.rootRootOutports=rootRootOutports;
        buildData.rootOutportsInfo.hasBEP=false;
        buildData.runtimeFcnsInfo=slsim.internal.RuntimeFcnsInfo(iMdl);

    end






    temporaryStream=RandStream('twister','Seed','shuffle');
    buildData.diaglogdb_sid=randi(temporaryStream,1e6);


    if buildData.opts.verbose
        fprintf('### %6.2fs :: %s\n',etime(clock,buildData.startTime),...
        message('Simulink:tools:rapidAccelSimStart',buildData.mdl).getString);
    end

end


function save_static_data(buildData)



    computer=buildData.computer;

    fromFileBlocks=buildData.fromFileBlocks;
    fromFile=buildData.fromFile;
    toFileBlocks=buildData.toFileBlocks;
    toFile=buildData.toFile;

    rootInportsInfo=buildData.rootInportsInfo;
    rootOutportsInfo=buildData.rootOutportsInfo;
    hasInstrumentedSignals=buildData.hasInstrumentedSignals;
    logStateDataForArrayLogging=buildData.logging.LogStateDataForArrayLogging;

    externalInputsFcnCompliant=buildData.externalInputsFcnCompliant;
    externalOutputsFcnCompliant=buildData.externalOutputsFcnCompliant;
    externalInputsFcnError=buildData.externalInputsFcnError;
    externalOutputsFcnError=buildData.externalOutputsFcnError;

    combinedFcnsError=buildData.combinedFcnsError;
    runtimeFcnsInfo=buildData.runtimeFcnsInfo;
    maxIOBufferSize=buildData.maxIOBufferSize;


    compiledSolverName=buildData.compiledSolverName;
    solverStatusFlags=buildData.solverStatusFlags;
    compiledStepSize=buildData.compiledStepSize;
    fundamentalDiscreteRate=buildData.fundamentalDiscreteRate;
    hasSrcBlksForAutoHmaxCalc=buildData.hasSrcBlksForAutoHmaxCalc;

    MaxStep=buildData.MaxStep;
    MinStep=buildData.MinStep;
    RelTol=buildData.RelTol;
    AbsTol=buildData.AbsTol;
    InitialStep=buildData.InitialStep;
    MaxConsecutiveMinStep=buildData.MaxConsecutiveMinStep;
    MaxConsecutiveZCs=buildData.MaxConsecutiveZCs;
    ConsecutiveZCsStepRelTol=buildData.ConsecutiveZCsStepRelTol;
    ZCThreshold=buildData.ZCThreshold;

    if get_param(buildData.mdl,'UseSLExecSimBridge')>0
        serializedModelInfo=buildData.serializedModelInfo;
    end

    isExportFunction=buildData.isExportFunction;
    DecoupledContinuousIntegration=buildData.DecoupledContinuousIntegration;
    OptimalSolverResetCausedByZc=buildData.OptimalSolverResetCausedByZc;

    dataflowRebuildInfo=buildData.dataflowRebuildInfo;
    simHardwareAccelerationRebuildInfo=buildData.simHardwareAccelerationRebuildInfo;
    UnsupportedTypeData=buildData.UnsupportedTypeData;
    runToRunStaticDataFileName=...
    get_runtorunstaticdata_file(buildData.buildDir,{'_raccel'});
    if get_param(buildData.mdl,'UseSLExecSimBridge')>0

        save(runToRunStaticDataFileName{1},'-v7',...
        'computer',...
        'fromFileBlocks','fromFile','toFileBlocks','toFile',...
        'rootInportsInfo','rootOutportsInfo',...
        'hasInstrumentedSignals','compiledSolverName','solverStatusFlags',...
        'serializedModelInfo',...
        'compiledStepSize','fundamentalDiscreteRate','hasSrcBlksForAutoHmaxCalc',...
        'MaxStep','MinStep','RelTol','AbsTol','InitialStep',...
        'MaxConsecutiveMinStep','MaxConsecutiveZCs','ConsecutiveZCsStepRelTol',...
        'ZCThreshold','externalInputsFcnCompliant','externalOutputsFcnCompliant',...
        'externalInputsFcnError','externalOutputsFcnError',...
        'combinedFcnsError',...
        'runtimeFcnsInfo',...
        'maxIOBufferSize',...
        'isExportFunction','DecoupledContinuousIntegration','OptimalSolverResetCausedByZc',...
        'logStateDataForArrayLogging','dataflowRebuildInfo','simHardwareAccelerationRebuildInfo',...
        'UnsupportedTypeData');
    else

        save(runToRunStaticDataFileName{1},'-v7',...
        'fromFileBlocks','fromFile','toFileBlocks','toFile',...
        'rootInportsInfo','rootOutportsInfo',...
        'hasInstrumentedSignals','compiledSolverName','solverStatusFlags',...
        'compiledStepSize','hasSrcBlksForAutoHmaxCalc',...
        'externalInputsFcnCompliant','externalOutputsFcnCompliant',...
        'externalInputsFcnError','externalOutputsFcnError',...
        'combinedFcnsError',...
        'runtimeFcnsInfo',...
        'maxIOBufferSize',...
        'isExportFunction','DecoupledContinuousIntegration','OptimalSolverResetCausedByZc',...
        'logStateDataForArrayLogging','dataflowRebuildInfo','simHardwareAccelerationRebuildInfo',...
        'UnsupportedTypeData');
    end
end





function buildData=add_to_from_file_blocks(buildData,modelName)
    binfo_cache=coder.internal.infoMATPostBuild...
    ('loadNoConfigSet','binfo',modelName,'NONE',...
    get_param(modelName,'SystemTargetFile'));
    fromFileBlocks=binfo_cache.fromFileBlocks;
    toFileBlocks=binfo_cache.toFileBlocks;

    buildData.fromFileBlocks=fromFileBlocks;
    buildData.toFileBlocks=toFileBlocks;

    set_param(buildData.mdl,'RapidAcceleratorBuildData',buildData);
end




function buildData=add_instrumented_signals(buildData,modelName)
    binfo_cache=coder.internal.infoMATPostBuild...
    ('loadNoConfigSet','binfo',modelName,'NONE',...
    get_param(modelName,'SystemTargetFile'));
    hasInstrumentedSignals=binfo_cache.hasInstrumentedSignals;
    buildData.hasInstrumentedSignals=hasInstrumentedSignals;

    set_param(buildData.mdl,'RapidAcceleratorBuildData',buildData);
end




function buildData=add_dataflow_configuration_info(buildData,modelName)
    dataflowRebuildInfo=[];
    dataflowRebuildInfo.numThreads=get_param(modelName,'DataflowMaxThreadsUsed');
    buildData.dataflowRebuildInfo=dataflowRebuildInfo;

    set_param(buildData.mdl,'RapidAcceleratorBuildData',buildData);
end






function check_validity_of_dataflow_configuration(dataflowRebuildInfo)
    if~isempty(dataflowRebuildInfo)&&isfield(dataflowRebuildInfo,'numThreads')
        numAvailableThreads=min(feature('numcores'),maxNumCompThreads);
        if dataflowRebuildInfo.numThreads>numAvailableThreads
            error(message('dataflow:Engine:TooManyThreadsAndRapidAccelUpToDataCheckOff'));
        end
    end
end




function buildData=add_SimHardwareAcceleration_info(buildData,iMdl)
    buildData.simHardwareAccelerationRebuildInfo.CPUInfo=private_sl_CPUInfo;
    buildData.simHardwareAccelerationRebuildInfo.HasNativeSimHardwareAcceleration=strcmpi(get_param(iMdl,'HasNativeSimHardwareAcceleration'),'on');
    set_param(buildData.mdl,'RapidAcceleratorBuildData',buildData);
end






function check_validity_of_SimHardwareAcceleration_configuration(simHardwareAccelerationRebuildInfo)
    if~isempty(simHardwareAccelerationRebuildInfo)

        if simHardwareAccelerationRebuildInfo.HasNativeSimHardwareAcceleration
            cpuInfo=private_sl_CPUInfo;
            oldCPUInfo=simHardwareAccelerationRebuildInfo.CPUInfo;
            if((oldCPUInfo.AVX2&&~cpuInfo.AVX2)||(oldCPUInfo.AVX512&&~cpuInfo.AVX512))
                error(message('Simulink:tools:rapidAccelSimHardwareAccelRapidAccelUpToDateCheck'));
            end
        end
    end
end


function buildData=obtain_to_from_file_filenames(buildData,~)



    if buildData.opts.verbose
        fprintf('### %6.2fs :: Calling obtain_to_from_file_filenames\n',etime(clock,buildData.startTime));
    end

    if(Simulink.isRaccelDeployed)
        for i=1:length(buildData.fromFile)
            buildData.fromFile(i).filename=makeSureIsDotMat(buildData.fromFile(i).filename);
            wName=which(buildData.fromFile(i).filename);
            if(~isempty(wName))


                buildData.fromFile(i).filename=wName;
            end
            if buildData.opts.verbose
                fprintf('### %6.2fs :: Finalized FromFile filename: %s\n',...
                etime(clock,buildData.startTime),...
                buildData.fromFile(i).filename);
            end
        end
        for i=1:length(buildData.toFile)
            wName=which(buildData.toFile(i).filename);
            if(~isempty(wName))


                buildData.toFile(i).filename=wName;
            end
            buildData.toFile(i).filename=makeSureIsDotMat(buildData.toFile(i).filename);
            if buildData.opts.verbose
                fprintf('### %6.2fs :: Finalized ToFile filename: %s\n',...
                etime(clock,buildData.startTime),...
                buildData.toFile(i).filename);
            end
        end
    else

        buildData.fromFile=[];
        buildData.toFile=[];
        fromFileBlocks=buildData.fromFileBlocks;
        toFileBlocks=buildData.toFileBlocks;

        for i=1:length(fromFileBlocks)
            buildData.fromFile(i).blockPath=fromFileBlocks{i}.blockPath;
            try
                buildData.fromFile(i).filename=get_param(fromFileBlocks{i}.blockPath,'Filename');
            catch ME %#ok the response does not depend on the exception


                buildData.fromFile(i).filename=fromFileBlocks{i}.originalFileName;
            end

            buildData.fromFile(i).filename=makeSureIsDotMat(buildData.fromFile(i).filename);
            wName=which(buildData.fromFile(i).filename);
            if(~isempty(wName)&&~Simulink.isRaccelDeploymentBuild)


                buildData.fromFile(i).filename=wName;
            end
            if buildData.opts.verbose
                fprintf('### %6.2fs :: Finalized FromFile filename: %s\n',...
                etime(clock,buildData.startTime),...
                buildData.fromFile(i).filename);
            end
        end

        for i=1:length(toFileBlocks)
            buildData.toFile(i).blockPath=toFileBlocks{i}.blockPath;
            try
                buildData.toFile(i).filename=get_param(toFileBlocks{i}.blockPath,'Filename');
            catch


                buildData.toFile(i).filename=toFileBlocks{i}.originalFileName;
            end

            buildData.toFile(i).filename=makeSureIsDotMat(buildData.toFile(i).filename);
            if buildData.opts.verbose
                fprintf('### %6.2fs :: Finalized ToFile filename: %s\n',...
                etime(clock,buildData.startTime),...
                buildData.toFile(i).filename);
            end
        end
    end

end




function init_up_to_date_check_on(iMdl,varargin)





























    PerfTools.Tracer.setStatisticsTypeForModel(iMdl,'RTW');




















    if Simulink.isRaccelDeploymentBuild



        folders=Simulink.filegen.internal.FolderConfiguration(iMdl,true,false);
    else
        folders=Simulink.filegen.internal.FolderConfiguration(iMdl);
    end

    buildDir=folders.RapidAccelerator.absolutePath('ModelCode');
    m=[];
    if(nargin>=18)
        m=varargin{17};
    else
        m=get_param(iMdl,'RapidAcceleratorBuildData');
    end
    buildData=simulinkstandalone.metamodel.BuildData(m);
    buildData.logging=simulinkstandalone.metamodel.Logging(m);
    buildData.opts=simulinkstandalone.metamodel.Opts(m);
    buildData.IATesting=simulinkstandalone.metamodel.IATesting(m);
    if slfeature('RaccelSimulationPacing')>0
        buildData.pacingInfo=simulinkstandalone.metamodel.PacingInfo(m);
    end



    buildData.buildDir=buildDir;


    buildData.numRuns=1;
    tmpVarPrefix=strrep(tempname,tempdir,'');
    buildData.tmpVarPrefix{1}=tmpVarPrefix(2:end);




    loc_create_build_dir(iMdl,buildData.buildDir,false);


    if(Simulink.isRaccelDeploymentBuild)
        standaloneInterfaceFileName=...
        fullfile(buildData.buildDir,'standaloneModelInterface.mat');
        modelInterface=Simulink.RapidAccelerator.StandaloneModelInterface(iMdl);
        modelInterface.populateDesktopValues();
        modelInterface.set_param('EnableRunTimeSolverSwitching',[]);
        modelInterface.set_param('Callbacks',[]);
        modelInterface.set_param('CodeCoverageSettings',[]);
        modelInterface.set_param('ModelWorkspace',[]);
        modelInterface.serializeData(standaloneInterfaceFileName);
    end

    buildData=loc_basic_setup(iMdl,buildData,varargin{:});


    buildData.basicSetupOnly=false;
    buildData.opts.extModeTrigDuration=get_opt('extModeTrigDuration',100);

    buildData.opts.makeCommand=get_opt('makeCommand','make_rtw');
    buildData.opts.templateMakefile=get_opt('templateMakefile',...
    'raccel_default_tmf');
    buildData.opts.extModeTesting=get_opt('extModeTesting',0);







    if slfeature('TunableStructParamsInRaccel')
        buildData.csParams={...
        {'ExtModeMexFile','ext_comm'};...
        {'ExtModeMexArgs',nan};...
        {'RTWUseSimCustomCode','on'};...
        {'RTWCAPIParams','on'};...
        {'RTWCAPISignals','on'};...
        };
    else
        buildData.csParams={...
        {'ExtModeMexFile','ext_comm'};...
        {'ExtModeMexArgs',nan};...
        {'RTWUseSimCustomCode','on'};...
        {'RTWCAPISignals','on'};...
        };
    end

    tempCS=getActiveConfigSet(buildData.mdl);
    if isa(tempCS,'Simulink.ConfigSetRef')
        tempCS=tempCS.getRefConfigSet;
    end
    tgt=tempCS.getComponent('Code Generation').getComponent('Target');
    lutObjStructAxisOrderParamExists=tgt.hasProp('LookupTableObjectStructAxisOrder');
    if(lutObjStructAxisOrderParamExists)
        oldLutObjStructAxisOrder=tgt.getProp('LookupTableObjectStructAxisOrder');
        buildData.csParams{end+1}={'LookupTableObjectStructAxisOrder',...
        oldLutObjStructAxisOrder};
    end
    tgt=tempCS.getComponent('Code Generation').getComponent('Target');
    lutObjStructOrderExplicitValuesParamExists=tgt.hasProp('LUTObjectStructOrderExplicitValues');
    if(lutObjStructOrderExplicitValuesParamExists)
        oldLutObjStructOrderExplicitValues=tgt.getProp('LUTObjectStructOrderExplicitValues');
        buildData.csParams{end+1}={'LUTObjectStructOrderExplicitValues',...
        oldLutObjStructOrderExplicitValues};
    end
    tgt=tempCS.getComponent('Code Generation').getComponent('Target');
    lutObjStructOrderEvenSpacingParamExists=tgt.hasProp('LUTObjectStructOrderEvenSpacing');
    if(lutObjStructOrderEvenSpacingParamExists)
        oldLutObjStructOrderEvenSpacing=tgt.getProp('LUTObjectStructOrderEvenSpacing');
        buildData.csParams{end+1}={'LUTObjectStructOrderEvenSpacing',...
        oldLutObjStructOrderEvenSpacing};
    end
    tgt=tempCS.getComponent('Code Generation').getComponent('Target');
    RTWCAPIRootIOParamExists=tgt.hasProp('RTWCAPIRootIO');
    if RTWCAPIRootIOParamExists
        oldRTWCAPIRootIO=tgt.getProp('RTWCAPIRootIO');
        if slfeature('UseSimulationServiceForRaccel')>0
            oldRTWCAPIRootIO='on';
        end
        buildData.csParams{end+1}={'RTWCAPIRootIO',oldRTWCAPIRootIO};
    end





    if(~buildData.logging.SaveFinalState&&...
        buildData.logging.SaveCompleteFinalSimState)
        buildData.csParams{end+1}=...
        {'SaveCompleteFinalSimState','off'};
    end

    buildData.bdParams={...
    {'ExtModeAutoUpdateStatusClock','on'};...
    {'ExtModeEnableFloating','on'};...
    {'ExtModeTrigDurationFloating','auto'};...
    {'ExtModeBatchMode','off'};...
    {'ExtModeLogAll','on'};...
    {'ExtModeTrigType','manual'};...
    {'ExtModeTrigMode','normal'};...
    {'ExtModeTrigDuration',buildData.opts.extModeTrigDuration};...
    {'ExtModeTrigDelay',0};...
    {'ExtModeArmWhenConnect','on'};...
    {'ExtModeArchiveMode','off'};...
    {'StatusString',nan};...
    {'Dirty',nan};...
    };
    nCSParams=length(buildData.csParams);
    nBDParams=length(buildData.bdParams);

    buildData.configSet=cell(1,1);

    for ip=1:nBDParams
        buildData.bdParams{ip}{3}=get_param(buildData.mdl,...
        buildData.bdParams{ip}{1});
    end
    buildData.configSet{1}=getActiveConfigSet(buildData.mdl);




    if(~slfeature('RapidAcceleratorHonorTargetLangSupport'))&&...
        isequal(get_param(iMdl,'SimTargetLang'),'C++')
        warning(message('Simulink:tools:rapidAccelCppNotSupported',iMdl));
    end

    buildData.compInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;



    try
        set_param(iMdl,'RapidAcceleratorBuildData',buildData);
    catch e
        close_models(buildData.modelsToClose);
        rethrow(e)
    end


    autosave_start=get_param(0,'AutoSaveOptions');
    if autosave_start.SaveOnModelUpdate
        try

            slInternal('autosave');
        catch E %#ok<NASGU>

        end
    end

    buildData.isMenuSim=false;
    if nargin>=8
        buildData.isMenuSim=varargin{8};
    end



    set_status_string(iMdl,'Simulink:tools:rapidAccelSettingUp');

    mdl=buildData.mdl;

    origCS=buildData.configSet{1};
    while origCS.isa('Simulink.ConfigSetRef')
        origCS=origCS.getRefConfigSet();
    end
    tmpCS=origCS.copy;
    slInternal('substituteTmpConfigSetForBuild',...
    get_param(mdl,'Handle'),buildData.configSet{1},tmpCS);
    origCS.lock;

    rtwComponentParamsToKeep={...
    {'CustomSourceCode',''},...
    {'CustomHeaderCode',''}...
    ,{'CustomInclude',''},...
    {'CustomSource',''},...
    {'CustomLibrary',''},...
    {'CustomInitializer',''},...
    {'RetainRTWFile',''},...
    {'TLCDebug',''},...
    {'CustomTerminator',''}};
    csParamsToKeep={...
    'LifeSpan'};

    largestAtomicIntSize='';%#ok<NASGU>
    try
        largestAtomicIntSize=get_param(mdl,'TargetLargestAtomicInteger');
    catch e %#ok<NASGU>
        largestAtomicIntSize='';

    end

    origRTWcomp=origCS.getComponent('Real-Time Workshop');
    for idx=1:length(rtwComponentParamsToKeep)
        rtwComponentParamsToKeep{idx}{2}=...
        origRTWcomp.get(rtwComponentParamsToKeep{idx}{1});
    end







    comp=Simulink.RTWCC('ert.tlc');
    tmpCS.attachComponent(comp);
    switchTarget(tmpCS,'raccel.tlc',[]);
    set_param(tmpCS,'MakeCommand',buildData.opts.makeCommand);
    set_param(tmpCS,'TemplateMakefile',buildData.opts.templateMakefile);



    set_param(tmpCS,'RTWCAPIRootIO','on');

    rtwComp=tmpCS.getComponent('Real-Time Workshop');

    cap=rtwComp.getComponent('Code Appearance');
    cap.MaxIdLength=128;
    if(buildData.opts.verbose||buildData.opts.debug)
        set_param(tmpCS,'RetainRTWFile','on');
    end
    if(buildData.opts.debug)
        cap.GenerateComments='on';
        cap.ObfuscateCode=0;
        set_param(tmpCS,'GenerateReport','on');
        set_param(tmpCS,'LaunchReport','on');
    elseif(buildData.opts.profile)
        cap.GenerateComments='on';
        cap.ObfuscateCode=0;
    else

        cap.GenerateComments='off';
        if strcmp(get_param(0,'AcceleratorUseTrueIdentifier'),'off')
            cap.ObfuscateCode=1;
            cap.MangleLength=10;
        end
    end

    if slfeature('RapidAcceleratorHonorTargetLangSupport')


        set_param(tmpCS,'TargetLang',get_param(origCS,'SimTargetLang'));
    end


    hwComp=tmpCS.getComponent('Hardware Implementation');
    slprivate('setHardwareDevice',hwComp,'Target','MATLAB Host');

    for idx=1:length(rtwComponentParamsToKeep)
        rtwComp.set(rtwComponentParamsToKeep{idx}{1},...
        rtwComponentParamsToKeep{idx}{2});
    end


    if~isequal(largestAtomicIntSize,'')
        set_param(mdl,'TargetLargestAtomicInteger',largestAtomicIntSize);
    end

    if get_param(mdl,'UseSLExecSimBridge')>0
        set_param(rtwComp,...
        'ENABLE_SLEXEC_SSBRIDGE',...
        get_param(mdl,'UseSLExecSimBridge'));
    end

    for idx=1:length(csParamsToKeep)
        set_param(tmpCS,csParamsToKeep{idx},...
        get_param(origCS,csParamsToKeep{idx}));
    end

    if strcmpi(get_param(tmpCS,'TargetLang'),'C++')
        set_param(tmpCS,'DLTargetLibrary','mkl-dnn');
        if strcmp(origCS.getComponent('Simulation Target').GPUAcceleration,'on')
            warning(message('RTW:buildProcess:gpuAccelerationNotSupportedForRaccel'));
        end
    end

    if(slfeature('C99ForRapidAccelAndAccelTop')>0||slfeature('RapidAccelGccCheck')>0)
        lToolchainInfo=buildData.compInfo.ToolchainInfo;
        lCompilerInfo=coder.make.internal.getMexCompInfoFromKey(lToolchainInfo.Alias{1});
    end

    if(slfeature('RapidAccelGccCheck')>0)




        if(strcmp(lCompilerInfo.compStr,'GNU-x'))
            minMajor=6;
            minMinor=3;
            versionStrs=strsplit(lCompilerInfo.comp.Version,'.');
            assert(~isempty(versionStrs)&&isvector(versionStrs));
            majorVersion=str2double(versionStrs{1});


            minorVersion='';
            if length(versionStrs)>=2
                minorVersion=str2double(versionStrs{2});
            end

            unsupportedVersion=...
            majorVersion<minMajor||...
            (~isempty(minorVersion)&&majorVersion==minMajor&&minorVersion<minMinor);

            if(unsupportedVersion)
                error(message('Simulink:tools:rapidAccelGccVersion',...
                lCompilerInfo.comp.Version,[num2str(minMajor),'.',num2str(minMinor)]));
            end
        end
    end


    set_param(tmpCS,'LogVarNameModifier','none');
    set_param(tmpCS,'RTWVerbose',get_param(iMdl,'AccelVerboseBuild'));


    RTW.TargetRegistry.get;
    tfl=get_param(mdl,'SimTargetFcnLibHandle');
    set_param(mdl,'TargetFcnLibHandle',tfl);
    tfl.doPreRTWBuildProcessing;





    set_param(mdl,'EfficientFloat2IntCast','off');
    set_param(mdl,'EfficientMapNaN2IntZero','off');
    for ip=1:nCSParams
        v=buildData.csParams{ip}{2};
        if isnan(v),continue;end
        set_param(mdl,buildData.csParams{ip}{1},v);
    end
    for ip=1:nBDParams
        v=buildData.bdParams{ip}{2};
        if isnan(v),continue;end
        set_param(mdl,buildData.bdParams{ip}{1},v);
    end

    if buildData.opts.extModeTesting
        try
            set_param(iMdl,'ExtModeTesting','on');
        catch E
            error(message('Simulink:tools:rapidAccelExtModeTestingError',...
            iMdl,E.identifier,E.message));
        end
    end












    if isequal(get_param(iMdl,'SaveFormat'),'Dataset')
        if isequal(get_param(iMdl,'SaveOutput'),'on')
            if contains(get_param(iMdl,'OutputSaveName'),',')
                error(message('Simulink:Logging:InvDataLogOutputMultiSaveName',buildData.mdl));
            end
        end
    end

    set_param(iMdl,'SaveTime','on');
    if isequal(get_param(iMdl,'SaveFormat'),'Dataset')
        saveState=get_param(iMdl,'SaveState');
        saveFinalState=get_param(iMdl,'SaveFinalState');

        if(slfeature('EnableRaccelDatasetAsInitialState')>0)



            if isequal(saveState,'on')
                warning(message('Simulink:Logging:DatasetSaveStateRapidAccelNoSupported',iMdl));
                set_param(iMdl,'SaveState','off');
            end
        else


            if isequal(saveState,'on')||isequal(saveFinalState,'on')
                warning(message('Simulink:Logging:DatasetRapidAccelNoSupported'));
                set_param(iMdl,'SaveState','off','SaveFinalState','off');
            end
        end
        if buildData.rootOutportsInfo.numOutports>0
            set_param(iMdl,'SaveOutput','on');
        else
            set_param(iMdl,'SaveOutput','off');
        end
    else

        set_param(iMdl,'SaveOutput','on','SaveState','on','SaveFinalState','on');
        set_param(iMdl,'SaveFormat','StructureWithTime');
    end

    set_param(iMdl,'SignalLogging','on');
    if buildData.numReturnValues>0
        set_param(iMdl,'TimeSaveName',[buildData.loggingPfx,'tout']);
    end

    set_param(iMdl,'StateSaveName',[buildData.loggingPfx,'xout']);

    set_param(iMdl,'SignalLoggingName',[buildData.loggingPfx,'logsout']);


    outputSaveName={};
    for op=1:buildData.rootOutportsInfo.numOutports
        outportName=[buildData.loggingPfx,'yout',num2str(op)];
        outputSaveName=[outputSaveName,outportName];%#ok
    end

    if~isempty(outputSaveName)
        outputSaveNameStr=strjoin(outputSaveName,',');
        set_param(iMdl,'OutputSaveName',outputSaveNameStr);
    else
        set_param(iMdl,'SaveOutput','off');
    end

    if Simulink.isRaccelDeploymentBuild
        standaloneModelLoggingInfoFileName=...
        get_model_logging_info_file(buildData.buildDir);
        dataLoggingOverrideMcos=get_param(iMdl,'DataLoggingOverride');
        dataLoggingOverrideMcos=dataLoggingOverrideMcos.updateModelName(iMdl);
        dataLoggingOverrideMcos=loc_dataLoggingOverride_check_signals(dataLoggingOverrideMcos,iMdl);
        dataLoggingOverrideStruct=dataLoggingOverrideMcos.utStruct;
        save(standaloneModelLoggingInfoFileName,'-v7','dataLoggingOverrideStruct');
    end

    if~isempty(buildData.simOpts)
        loc_setup_sim_opts(buildData);
    end

    set_param(iMdl,'Dirty',buildData.bdParams{end}{3});





    if(buildData.logging.SaveOutput)
        [nYoutVars,~]=loc_get_var_names(...
        buildData.logging.OutputSaveName,buildData.mdl);
        numOutports=buildData.rootOutportsInfo.numOutports;
        if((nYoutVars>1)&&(nYoutVars~=numOutports))
            error(message('Simulink:tools:rapidAccelIncorrectOutputs',buildData.mdl));
        end
    end

end

function buildData=loc_create_mat_files_for_packaged_model_menu_sim(buildData)
    setup_ext_inputs(buildData);
    buildData=obtain_to_from_file_filenames(buildData,buildData.mdl);
    create_slvr_file(buildData);
    create_siglogselector_file(buildData);
end


function checkValidityOfSolver(buildData)
    mdl=buildData.mdl;

    simOptsFields=[];
    if~isempty(buildData.simOpts)
        simOptsFields=fieldnames(buildData.simOpts);
    end


    fldStr=findStr(simOptsFields,'Solver');
    if~isempty(fldStr)
        fldValStr=buildData.simOpts.(fldStr);
    else
        fldValStr=get_param(mdl,'Solver');
    end


    solverType=get_param(mdl,'SolverType');


    solverType=strrep(solverType,'-s',' S');
    solverList=getSolversByParameter('SolverType',solverType);

    compSolver=buildData.compiledSolverName;
    solverStatusFlags=buildData.solverStatusFlags;

    isAutoSolverNow=or(isequal(fldValStr,'VariableStepAuto'),...
    isequal(fldValStr,'FixedStepAuto'));

    isAutoSolverAtCompile=...
    Simulink.RapidAccelerator.internal.AutoSolverUtil.isAutoSolverAtCompile(solverStatusFlags);

    if(any(ismember(solverList(:),compSolver)))

        if(isAutoSolverNow&&not(isAutoSolverAtCompile))

            error(message('Simulink:tools:rapidAccelAutoSolverError'));
        end
    else

        if(isequal(solverType,'Fixed Step'))
            identifier='SimulinkExecution:SolverParameter:SolverChangeFromVariableStepToFixedStep';
        else
            identifier='SimulinkExecution:SolverParameter:SolverChangeFromFixedStepToVariableStep';
        end
        error(message(identifier));
    end

end



function buildData=loc_append_rtp_workspace_to_expression_evaluator(buildData,parameterSet,tunedParameters)
    buildData.rtpWorkspace=Simulink.standalone.MatlabWorkspace;

    for i=1:length(tunedParameters)
        tunedParameterInfo=tunedParameters(i);
        if tunedParameterInfo.isStruct
            parameterValue=parameterSet(tunedParameterInfo.transitionIdx).values;
        else
            transitionIdx=tunedParameterInfo.transitionIdx;
            mapIdx=tunedParameterInfo.mapIdx;
            map=parameterSet(transitionIdx).map(mapIdx);
            vi=map.ValueIndices;
            parameterValue=parameterSet(transitionIdx).values(vi(1):vi(2));
            parameterValue=reshape(parameterValue,map.Dimensions);
        end

        buildData.rtpWorkspace.assign(...
        tunedParameterInfo.name,...
parameterValue...
        );
    end

    buildData.expressionEvaluator.push_back(buildData.rtpWorkspace);
end



function buildData=init_up_to_date_check_off(iMdl,varargin)




















    simOpts=varargin{2};
    m=varargin{17};
    buildData=simulinkstandalone.metamodel.BuildData(m);
    buildData.logging=simulinkstandalone.metamodel.Logging(m);
    buildData.opts=simulinkstandalone.metamodel.Opts(m);
    buildData.IATesting=simulinkstandalone.metamodel.IATesting(m);
    if(slfeature('RaccelSimulationPacing')>0)
        buildData.pacingInfo=simulinkstandalone.metamodel.PacingInfo(m);
    end

    startIsHandle=tic;
    if ishandle(iMdl),iMdl=get_param(iMdl,'Name');end
    val=getenv('RAPID_ACCELERATOR_OPTIONS_VERBOSE');
    if(~isempty(val)&&isequal(val,'1'))
        fprintf('### %6.2fs for Ishandle check \n',toc(startIsHandle));
    end

    if(Simulink.isRaccelDeployed)







        buildData.modelInterface=...
        Simulink.RapidAccelerator.getStandaloneModelInterface(iMdl);
        buildData.modelInterface.debugLog(1,'Calling initializeForDeployment');
        buildDir=buildData.modelInterface.initializeForDeployment();
        buildData.modelInterface.debugLog(1,'Done initializeForDeployment');
        buildDir=buildData.modelInterface.initializeForDeployment();


        rtp=buildData.modelInterface.getRtp();
        buildData.modelInterface.set_param('EnableRunTimeSolverSwitching',[]);
    else




        folders=Simulink.filegen.internal.FolderConfiguration(iMdl);
        buildDir=folders.RapidAccelerator.absolutePath('ModelCode');

        rtp=[];
        if~isempty(simOpts)&&isfield(simOpts,'RapidAcceleratorParameterSets')
            rtp=simOpts.RapidAcceleratorParameterSets;
        end
    end

    if isequal(get_param(iMdl,'SaveFormat'),'Dataset')&&...
        isequal(get_param(iMdl,'SaveFinalState'),'on')&&...
        ~isfile(fullfile(buildDir,'template_dataset.mat'))
        warning(message('Simulink:Logging:CannotSaveFinalStatesInDatasetFormat',iMdl));
        set_param(iMdl,'SaveFinalState','off');
    end






    if isempty(rtp)
        build_rtp_file=fullfile(buildDir,'build_rtp.mat');
        if isfile(build_rtp_file)
            buildData.loadFromBuildRtpFile=true;
        else



            assert(~exist(get_exe_name(buildDir,iMdl),'file'));
        end
    end

    rtp=loc_edit_rtp(rtp,iMdl,buildDir);

    dirty=get_param(iMdl,'Dirty');

    loc_PerfToolsTracerLogSimulinkData('Performance Advisor Stats',iMdl,'RapidAccelSim',...
    'SetUpForUpToDateCheckOff',true);

    buildData.buildDir=buildDir;



    buildData.numRuns=1;
    if~isempty(rtp)
        if~iscell(rtp.parameters)
            rtp.parameters={rtp.parameters};
        end
        buildData.numRuns=length(rtp.parameters);
        if~isempty(simOpts)&&isfield(simOpts,'RapidAcceleratorMultiSim')
            buildData.multiSimInfo=simOpts.RapidAcceleratorMultiSim;
        end
    end

    buildData=loc_basic_setup(iMdl,buildData,varargin{:});

    rtp=loc_update_mask_dependent_parameters(...
    rtp,...
buildData...
    );

    populateBaseWorkspaceWithCollapsedVariables(rtp);

    rtp=loc_update_collapsed_parameters(...
    rtp,...
buildData...
    );

    rtp=loc_update_matlab_transformed_parameters(...
    rtp,...
buildData...
    );

    rtp=loc_update_sparse_parameters(...
    rtp,...
buildData...
    );


    if isequal(get_param(iMdl,'SaveFormat'),'Array')
        if(~isempty(buildData.logging.LogStateDataForArrayLogging))
            if(isequal(get_param(iMdl,'SaveState'),'on')||isequal(get_param(iMdl,'SaveFinalState'),'on'))
                warning('backtrace','off');
                warning(message(buildData.logging.LogStateDataForArrayLogging,iMdl));
                warning('backtrace','on');
            end
        end
    end



    if~isequal(get_param(iMdl,'SaveFormat'),'Array')&&...
        buildData.logging.SaveFinalState
        warning('backtrace','off');
        ReportUnsupportedTypeWarning(buildData,iMdl);
        warning('backtrace','on');
    end

    buildData.basicSetupOnly=true;


    for i=1:buildData.numRuns
        tmpVarPrefix=strrep(tempname,tempdir,'');
        buildData.tmpVarPrefix{i}=tmpVarPrefix(2:end);
    end

    if~isempty(buildData.simOpts)
        loc_check_sim_opts_with_up_to_date_off(buildData.simOpts);
    end

    setup_ext_inputs(buildData);

    loc_create_prm_file(buildData.buildDir,buildData.tmpVarPrefix,rtp);

    buildData=obtain_to_from_file_filenames(buildData,iMdl);

    create_slvr_file(buildData);

    create_siglogselector_file(buildData);

    set_param(iMdl,'Dirty',dirty);

    loc_PerfToolsTracerLogSimulinkData('Performance Advisor Stats',iMdl,'RapidAccelSim',...
    'SetUpForUpToDateCheckOff',false);
end



function kill(iPID)
    if isunix

        cmd=['kill -9 ',iPID];
    else
        cmd=['taskkill /F /PID ',iPID];
    end
    [stat,res]=system(cmd);%#ok

end





function[oPID,oPort]=get_pid_and_port(buildData,exeActiveTokenStr,reasonForPID,errorFile)
    oPID='';oPort='';
    nAttempts=1;
    portCell={};
    pidCell={};

    startTime=tic;
    calledTestingHook=false;

    verboseReportingInterval=50;

    internalTesting=~isempty(buildData.opts.internalTesting);

    switch(reasonForPID)

    case 'toConnect'

        if buildData.opts.verbose
            fprintf('\n### Getting PID and port, max wait time: %f seconds\n',buildData.opts.connectWaitTime);
        end

        while toc(startTime)<buildData.opts.connectWaitTime
            if internalTesting&&~calledTestingHook
                loc_testExtModeConnect(buildData,exeActiveTokenStr,errorFile,startTime);
                calledTestingHook=true;
            end

            [fileReady,portCell,pidCell]=loc_read_server_info(buildData,exeActiveTokenStr);

            if fileReady
                if buildData.opts.verbose
                    fprintf('### Done waiting for PID and port, performed %i attempts, waited %f seconds\n',nAttempts,toc(startTime));
                end
                break;
            elseif exist(errorFile,'file')==2
                errorFileContents=loc_read_error_file(buildData,0);
                assert(~isempty(errorFileContents)&&length(errorFileContents)==1);
                error(message(...
                'Simulink:tools:rapidAcceleratorExeErrorBeforeConnect',...
                buildData.mdl,errorFileContents{1}));
            else




                if buildData.opts.verbose&&mod(nAttempts,verboseReportingInterval)==2
                    fprintf('### Server info file %s not found ...\n',exeActiveTokenStr);
                end
            end


            nAttempts=nAttempts+1;
            pause(buildData.opts.pauseInterval);

            continue;
        end

    case 'toClean'
        [~,portCell,pidCell]=loc_read_server_info(buildData,exeActiveTokenStr);

    otherwise
        return;
    end

    if internalTesting&&isfield(buildData.opts.internalTesting,'getPIDAndPortTiming')
        elapsedTime=toc(startTime);
        switch(reasonForPID)
        case 'toConnect'
            structFieldName='GetPIDAndPortConnectTimingInfo';
            timingInfo=struct(...
            'elapsedTimeForConnect',...
            elapsedTime,...
            'maxConnectWaitTime',...
            buildData.opts.connectWaitTime...
            );

        case 'toClean'
            structFieldName='GetPIDAndPortCleanupTimingInfo';
            timingInfo=struct(...
            'elapsedTimeForCleanup',...
elapsedTime...
            );

        otherwise
            return
        end

        loc_recordTestingInfo(structFieldName,timingInfo);
    end

    if(~isempty(portCell))
        oPort=portCell{1};
    end

    if(~isempty(pidCell))
        oPID=pidCell{1};
    end
end



function loc_testExtModeConnect(buildData,exeActiveTokenStr,errorFile,startTime)
    if isfield(buildData.opts.internalTesting,'exeErrorBeforeConnect')
        pidCell=loc_testGetPIDAndDeleteToken(buildData,exeActiveTokenStr,startTime);
        errorFileID=fopen(errorFile,'w');
        fprintf(errorFileID,'Testing');
        fclose(errorFileID);
        if~isempty(pidCell)
            kill(pidCell{1});
        end
    elseif isfield(buildData.opts.internalTesting,'connectWaitTime')
        pause(buildData.opts.internalTesting.connectWaitTime+1);
        pidCell=loc_testGetPIDAndDeleteToken(buildData,exeActiveTokenStr,startTime);
        if~isempty(pidCell)
            kill(pidCell{1});
        end
    end
end

function pidCell=loc_testGetPIDAndDeleteToken(buildData,exeActiveTokenStr,startTime)
    localWaitTime=300;
    while toc(startTime)<localWaitTime
        if exist(exeActiveTokenStr,'file')==2

            [~,~,pidCell]=loc_read_server_info(buildData,exeActiveTokenStr);
            delete(exeActiveTokenStr);
            break;
        end
    end
end

function loc_recordTestingInfo(testingInfoStructField,info)
    assert(isstring(testingInfoStructField)||ischar(testingInfoStructField));

    rapidAcceleratorTestingStructName='rapidAcceleratorTestingInfo';
    try
        testingInfoStruct=evalin('base',rapidAcceleratorTestingStructName);
    catch ME %#ok<NASGU>
        testingInfoStruct=[];
    end

    if~isempty(testingInfoStruct)
        assert(isstruct(testingInfoStruct));
    end

    testingInfoStruct.(testingInfoStructField)=info;

    try
        assignin('base',rapidAcceleratorTestingStructName,testingInfoStruct);
    catch ME %#ok<NASGU>
    end
end

function loc_SwapSolver(modelName)

    try
        if isequal(get_param(modelName,'SolverType'),'Fixed-step')
            set_param(modelName,'SolverType','Variable-step');
        else
            set_param(modelName,'SolverType','Fixed-step');
        end
    catch ME %#ok<NASGU>
    end
end




function oPort=get_tgtconn_port(buildData,exeActiveTokenStr)
    oPort='';
    nAttempts=1;
    portCell={};

    if buildData.opts.verbose
        fprintf('### Getting tgtconn port, max %i attempts',buildData.opts.maxAttempts);
tic
    end

    while nAttempts<buildData.opts.maxAttempts
        if buildData.opts.verbose,fprintf('.');end
        [fileReady,portCell]=loc_read_tgtconn_server_info(exeActiveTokenStr);
        if fileReady
            break;
        end


        nAttempts=nAttempts+1;
        pause(buildData.opts.pauseInterval);
    end

    if buildData.opts.verbose
        fprintf(' ');
toc
        fprintf('### Done waiting for tgtconn port, performed %i attempts\n',nAttempts);
    end

    if(~isempty(portCell))
        oPort=portCell{1};
    end
end



function cleanup(buildData,varargin)
    if buildData.opts.verbose
        fprintf('### %6.2fs :: Cleaning up\n',etime(clock,buildData.startTime));
    end

    if nargin>1
        closeModels=varargin{1};
    else
        closeModels=true;
    end



    set_status_string(buildData.mdl,'Simulink:editor:DefaultFlybyStr');


    set_status_string(buildData.mdl,'');

    exeActiveToken=get_exe_active_token(buildData.tmpVarPrefix);
    tgtconnActiveToken=get_tgtconn_active_token(buildData.tmpVarPrefix);
    outFile=get_out_file(buildData.buildDir,buildData.tmpVarPrefix);
    prmFile=get_prm_file(buildData.buildDir,buildData.tmpVarPrefix);
    inpFile=get_inp_file(buildData.buildDir,buildData.tmpVarPrefix);
    slvrFile=get_slvr_file(buildData.buildDir,buildData.tmpVarPrefix);
    simMetadataFile=get_simMetadata_file(buildData.buildDir,buildData.tmpVarPrefix);
    sigLogSelectorFile=...
    get_siglogselector_file(buildData.buildDir,buildData.tmpVarPrefix);

    for i=1:buildData.numRuns
        if slfeature('RapidAcceleratorDiagnosticsStreaming')<2
            if buildData.opts.verbose
                fprintf('### %6.2fs :: Checking if PID is active\n',...
                etime(clock,buildData.startTime));
            end
            [pid,~]=get_pid_and_port(buildData,exeActiveToken{i},'toClean');
            if~isempty(pid)
                if buildData.opts.verbose
                    fprintf('### %6.2fs :: Killing PID=%s\n',...
                    etime(clock,buildData.startTime),pid);
                end
                kill(pid);
            end
        else
            if~isempty(buildData.menusim_p)
                if buildData.opts.verbose
                    fprintf('### %6.2fs :: Checking if PID is active\n',...
                    etime(clock,buildData.startTime));
                end
                counter=0;
                while(buildData.menusim_p.Alive)
                    pause(1);
                    counter=counter+1;
                    if counter>30
                        break;
                    end
                end
                if buildData.opts.verbose
                    fprintf('### :: Waited %i seconds for PID=%s to terminate\n',...
                    counter,num2str(buildData.menusim_p.PID));
                end
                if(buildData.menusim_p.Alive)
                    if buildData.opts.verbose
                        fprintf('### %6.2fs :: Killing PID=%s\n',...
                        etime(clock,buildData.startTime),num2str(buildData.menusim_p.PID));
                    end
                    kill(num2str(buildData.menusim_p.PID));
                end
            end
        end

        if(~isempty(outFile{i})&&exist(outFile{i},'file')&&isempty(buildData.opts.keepArtifacts))
            delete(outFile{i});
        end
        if(~isempty(prmFile{i})&&exist(prmFile{i},'file')&&isempty(buildData.opts.keepArtifacts))
            delete(prmFile{i});
        end
        if(~isempty(inpFile{i})&&exist(inpFile{i},'file')&&isempty(buildData.opts.keepArtifacts))
            delete(inpFile{i});
        end
        if(~isempty(slvrFile{i})&&exist(slvrFile{i},'file')&&isempty(buildData.opts.keepArtifacts))
            delete(slvrFile{i});
        end
        if(~isempty(tgtconnActiveToken{i})&&exist(tgtconnActiveToken{i},'file')&&isempty(buildData.opts.keepArtifacts))
            delete(tgtconnActiveToken{i});
        end
        if(~isempty(simMetadataFile{i})&&exist(simMetadataFile{i},'file')&&isempty(buildData.opts.keepArtifacts))
            delete(simMetadataFile{i});
        end
        if(~isempty(sigLogSelectorFile{i})&&exist(sigLogSelectorFile{i},'file')&&isempty(buildData.opts.keepArtifacts))
            delete(sigLogSelectorFile{i});
        end
    end

    set_param(buildData.mdl,'ExtModeParamVectName','');

    if(buildData.basicSetupOnly)
        close_models(buildData.modelsToClose);
        return;
    end

    nBDParams=length(buildData.bdParams);

    mdl=buildData.mdl;

    tmpCS=getActiveConfigSet(mdl);
    origCS=buildData.configSet{1};
    if~eq(origCS,tmpCS)
        while isa(origCS,'Simulink.ConfigSetRef')
            origCS=origCS.getRefConfigSet();
        end
        origCS.unlock;
        slInternal('restoreOrigConfigSetForBuild',...
        get_param(mdl,'Handle'),buildData.configSet{1},tmpCS);
    end


    for ip=1:nBDParams
        nam=buildData.bdParams{ip}{1};
        val=buildData.bdParams{ip}{3};
        set_param(mdl,nam,val);
    end
    set_param(mdl,'TargetFcnLibHandle',[]);

    if(closeModels)
        close_models(buildData.modelsToClose);
    end

end



function[fileContents]=loc_read_error_file(buildData,runNumber)
    errorFile=get_error_file(buildData.tmpVarPrefix);

    if runNumber>0
        numRuns=1;
    else
        numRuns=length(errorFile);
        runNumber=1:numRuns;
    end

    fileContents=cell(1,numRuns);
    for i=1:numRuns
        if exist(errorFile{runNumber(i)},'file')
            fh=fopen(errorFile{runNumber(i)},'r');
            if fh~=-1
                fileContents{i}=fscanf(fh,'%c');
                fclose(fh);
            end

            delete(errorFile{runNumber(i)});
        end
    end
end



function get_exe_error(buildData,varargin)
    try

        if sdi.Repository.sessionRequiresRaccelImport()
            isMenuSim=buildData.numReturnValues<0;
            Simulink.sdi.internal.importCompletedRapidAccelRuns(buildData.mdl,isMenuSim);
        end
    catch ME
        ME.throwAsCaller;
    end
    xtester_emulate_ctrl_c('diaglogdb_ctrlc_1');
    if slfeature('RapidAcceleratorDiagnosticsStreaming')==0
        diaglogdb_ptr=loc_init_diagdb(buildData);
        diaglogdb_cleanup=onCleanup(@()slsvInternal('slsvDiagnosticLoggerDB','destroy',diaglogdb_ptr));
        try

            slsvInternal('slsvDiagnosticLoggerDB','report',diaglogdb_ptr);
            xtester_emulate_ctrl_c('diaglogdb_ctrlc_2');

            diaglogdb_cleanup.delete();
        catch ME

            diaglogdb_cleanup.delete();

            if~Simulink.isRaccelDeployed
                ME.throwAsCaller;
            else
                disp(ME.message);
            end
        end
    end

    numRun=length(buildData.tmpVarPrefix);
    iStatus=cell(1,numRun);
    iResult=cell(1,numRun);
    for i=1:numRun
        iStatus{i}=0;
        iResult{i}='';
    end
    runNumber=1:numRun;

    if nargin>1,iStatus=varargin{1};end
    if nargin>2,iResult=varargin{2};end
    if nargin>3

        numRun=1;
        iStatus=cell(1,numRun);
        iResult=cell(1,numRun);
        iStatus{1}=varargin{1};
        iResult{1}=varargin{2};
        runNumber=varargin{3};
    end

    for i=1:numRun
        errorFileContents=...
        loc_read_error_file(buildData,runNumber(i));

        if~isempty(errorFileContents{i})
            iStatus{i}=1;
        end

        if iStatus{i}~=0

            if contains(iResult{i},...
                '** Received SIGINT (Interrupt) signal @')
                error(message('Simulink:tools:rapidAccelExeInterrupted'));
            else
                if~isempty(errorFileContents{i})
                    iResult{i}=errorFileContents{i};
                end

                xmlString=regexp(iResult{i},...
                '(?=<diag_root\>)[\S\s]*?(?<=/diag_root>)','match');
                if~isempty(xmlString)
                    myException=slsvInternal('slsvCreateMExceptionFromXml',xmlString{1});
                    myException.throw;
                else
                    error(message('Simulink:tools:rapidAccelExeError',...
                    buildData.mdl,iResult{i}));
                end
            end
        end
    end
end



function[status,result]=run(buildData)
    iMdl=buildData.mdl;
    loc_PerfToolsTracerLogSimulinkData('Simulink Compile',...
    iMdl,'RapidAccelSim','Execution',true);

    set_param(buildData.mdl,'RapidAcceleratorSimStatus','running');
    if slfeature('ForEachParallelExecutionInRapidAccel')>0&&...
        ~slsvTestingHook('DisableParallelExecutionEngineInRapidAccelExe')&&...
        ~isempty(get_param(buildData.mdl,'ParallelExecutionNodeHandles'))
        numWorkerThreads=loc_get_ForEach_parallel_execution_max_num_threads(buildData.mdl);
        set_status_string(buildData.mdl,'Simulink:tools:rapidAccelRunningInMultithreading',...
        numWorkerThreads);
    else
        set_status_string(buildData.mdl,'Simulink:tools:rapidAccelRunning');
    end







    val=getenv('SLINTERNAL_RAPID_ACCEL_TARGET_IS_ACTIVE');
    if isempty(val)
        val='';
    end
    setenv('SLINTERNAL_RAPID_ACCEL_TARGET_IS_ACTIVE','1');
    rapidAccelActive=onCleanup(@()setenv('SLINTERNAL_RAPID_ACCEL_TARGET_IS_ACTIVE',val));

    buildData=setup_reval_service(buildData);




    if(buildData.opts.debug||buildData.opts.profile)
        loc_raccel_debug(buildData,false);
    end

    numRuns=buildData.numRuns;
    status=cell(1,numRuns);
    result=cell(1,numRuns);
    runCmd=get_run_cmd(buildData);

    loc_update_sfcn_info_file(buildData);



    if numRuns==1
        cmd=runCmd{1};
        if~buildData.opts.verbose
            cmd=[cmd,' -verbose off'];
            if slfeature('RapidAcceleratorDiagnosticsStreaming')==0||...
                Simulink.isRaccelDeployed
                if ispc
                    cmd=[cmd,' 1>nul'];
                else
                    cmd=[cmd,' > /dev/null'];
                end
            end
        end
        if buildData.opts.debug
            fprintf('               %s\n',cmd);
        end
        if buildData.opts.verbose
            fprintf('### %6.2fs :: Running process with command line: %s\n',...
            etime(clock,buildData.startTime),cmd);
            timingLog=[get_exe_name(buildData.buildDir,buildData.mdl),'_timing.log'];
            timingLogFID=fopen(timingLog,'w');
            fprintf(timingLogFID,'\n');
            fclose(timingLogFID);
        end

        useSimulationService=slfeature('UseSimulationServiceForRaccel')>0&&...
        (~Simulink.isRaccelDeployed||slfeature('UseSimulationServiceForDeployment')>0);

        if useSimulationService

            diaglogdb_ptr=loc_init_diagdb(buildData);
            diaglogdb_cleanup=onCleanup(@()slsvInternal('slsvDiagnosticLoggerDB','destroy',diaglogdb_ptr));


            simOptsFields=[];
            if~isempty(buildData.simOpts)
                simOptsFields=fieldnames(buildData.simOpts);
            end
            timeOutStr='';
            fldStr1=findStr(simOptsFields,'TimeOut');
            if~isempty(fldStr1)
                timeOut1=buildData.simOpts.(fldStr1);
                if~isempty(timeOut1)
                    timeOutStr=num2str(timeOut1);
                end
            end


            if(Simulink.isRaccelDeployed)
                isDeployed=int32(1);
            else
                isDeployed=int32(0);
            end

            sdiSource=Simulink.sdi.getSource();
            liveStream=slfeature('JetstreamRapidAccelStreaming');

            if ischar(buildData.toFileSuffix)
                toFileSuffix1=buildData.toFileSuffix;
            else
                toFileSuffix1='';
            end

            if buildData.runningInParallel
                runningInParallel=int32(1);
            else
                runningInParallel=int32(0);
            end



            if~isempty(buildData.externalInputsFcn)&&~isempty(buildData.externalOutputsFcn)
                if(buildData.externalInputsFcnCompliant==false||...
                    buildData.externalOutputsFcnCompliant==false)
                    if~isempty(buildData.combinedFcnsError)
                        buildData.combinedFcnsError.reportAsError();
                    else
                        error(message('SimulinkExecution:SimulationService:UserFcnNotSupported'));
                    end
                end

            elseif~isempty(buildData.externalInputsFcn)
                if buildData.externalInputsFcnCompliant==false
                    if~isempty(buildData.externalInputsFcnError)
                        buildData.externalInputsFcnError.reportAsError();
                    else
                        error(message('SimulinkExecution:SimulationService:UserFcnNotSupported'));
                    end
                end

            elseif~isempty(buildData.externalOutputsFcn)
                if buildData.externalOutputsFcnCompliant==false
                    if~isempty(buildData.externalOutputsFcnError)
                        buildData.externalOutputsFcnError.reportAsError();
                    else
                        error(message('SimulinkExecution:SimulationService:UserFcnNotSupported'));
                    end
                end
            end


            if buildData.rootOutportsInfo.hasBEP&&...
                buildData.logging.SaveOutput&&...
                ~isequal(lower(buildData.logging.SaveFormat),'dataset')
                error(message('Simulink:Engine:BEPInvalidDataLoggingFormat',buildData.mdl));
            end



            useBuildRtpFile=buildData.loadFromBuildRtpFile;

            if buildData.opts.simServer

                if~isempty(buildData.externalInputsFcn)||~isempty(buildData.externalOutputsFcn)
                    error(message('SimulinkExecution:SimulationService:UserFcnNotSupported'));
                end


                [status{1},result{1}]=slsim.internal.simServer(...
                buildData.mdl,...
                buildData.tmpVarPrefix{1},...
                ['_',buildData.mdl,num2str(feature('getpid'))],...
                buildData.buildDir,...
                timeOutStr,...
                toFileSuffix1,...
                runningInParallel,...
                sdiSource,...
                isDeployed,...
                '127.0.0.1',...
                7890,...
                liveStream);
            else
                if~isempty(buildData.runtimeFcns)
                    runtimeFcnsInfo=buildData.runtimeFcnsInfo.setFcns(buildData.runtimeFcns);
                else
                    runtimeFcnsInfo=buildData.runtimeFcnsInfo;
                end

                if slfeature('MLSysBlockRaccelReval')==1||...
                    slfeature('FMUBlockRaccelReval')==1
                    revalHost2target=num2str(buildData.qidHost2target);
                    revalTarget2host=num2str(buildData.qidTarget2host);
                    revalServicePort=num2str(buildData.dashServicePort);
                else
                    revalHost2target='';
                    revalTarget2host='';
                    revalServicePort='';
                end


                [status{1},result{1}]=slsim.internal.simRunner(...
                buildData.mdl,...
                buildData.tmpVarPrefix{1},...
                ['_',buildData.mdl,num2str(feature('getpid'))],...
                buildData.buildDir,...
                buildData.externalInputsFcn,...
                buildData.externalOutputsFcn,...
                buildData.liveOutputsFcn,...
                runtimeFcnsInfo.postStepFcn,...
                runtimeFcnsInfo.postStepFcnDecimation,...
                runtimeFcnsInfo.simStatusChangeFcn,...
                runtimeFcnsInfo.inputFcns,...
                runtimeFcnsInfo.outputFcns,...
                timeOutStr,...
                toFileSuffix1,...
                runningInParallel,...
                sdiSource,...
                isDeployed,...
                useBuildRtpFile,...
                liveStream,...
                revalHost2target,...
                revalTarget2host,...
                revalServicePort,...
                buildData);
            end

            if buildData.opts.verbose
                tmpToc=clock;
                timingLog=[get_exe_name(buildData.buildDir,buildData.mdl),'_timing.log'];
                timingLogFID=fopen(timingLog,'r');
                timingInfo=fscanf(timingLogFID,'%c');
                fclose(timingLogFID);
                delete(timingLog);
                timingInfo=split(timingInfo,newline);
                fprintf('               %s\n',timingInfo{:});
                fprintf('### %6.2fs :: Returned from raccel process\n',etime(tmpToc,buildData.startTime));
            end

            xtester_emulate_ctrl_c('diaglogdb_ctrlc_3');
            try

                slsvInternal('slsvDiagnosticLoggerDB','report',diaglogdb_ptr);
                xtester_emulate_ctrl_c('diaglogdb_ctrlc_4');

                diaglogdb_cleanup.delete();
            catch ME

                diaglogdb_cleanup.delete();
                ME.throwAsCaller;
            end

        elseif slfeature('RapidAccelSlProcess')==0
            [status{1},result{1}]=system(cmd);
        else
            diaglogdb_ptr=loc_init_diagdb(buildData);
            diaglogdb_cleanup=onCleanup(@()slsvInternal('slsvDiagnosticLoggerDB','destroy',diaglogdb_ptr));
            p=slprocess.Process;

            simulink.rapidaccelerator.internal.setTargetLibPathOnSlProcess(p);
            p.start(cmd);
            if slfeature('RapidAcceleratorDiagnosticsStreaming')>0
                counter=0;
                oldPauseState=pause('on');
                while p.Alive
                    pause(5/1000);
                    counter=counter+1;
                    if counter>1000
                        try

                            slsvInternal('slsvDiagnosticLoggerDB','report',diaglogdb_ptr);
                            counter=0;
                        catch ME

                            diaglogdb_cleanup.delete();
                            ME.throwAsCaller;
                        end
                    end
                end
                pause(oldPauseState);
            end

            try



                cpp_feval_wrapper('waitForSlProcess',p);
            catch ex
                p.terminate;
                ex.rethrow;
            end

            try

                slsvInternal('slsvDiagnosticLoggerDB','report',diaglogdb_ptr);

                diaglogdb_cleanup.delete();
            catch ME

                diaglogdb_cleanup.delete();
                ME.throwAsCaller;
            end

            status{1}=p.Status;
            result{1}=p.Result;
        end
    else

        [status,result]=simulink.rapidaccelerator.internal.runTargetsInSerial(...
        runCmd,buildData);
    end

    if~isempty(buildData.revalHost)
        buildData.revalHost=[];%#ok<NASGU>
    end

    loc_PerfToolsTracerLogSimulinkData('Simulink Compile',...
    iMdl,'RapidAccelSim','Execution',false);
    xtester_emulate_ctrl_c('diaglogdb_ctrlc_5');
end


function runFutures=runMultiSim(buildData,tpoolMgr)
    set_param(buildData.mdl,'RapidAcceleratorSimStatus','running');
    val=getenv('SLINTERNAL_RAPID_ACCEL_TARGET_IS_ACTIVE');
    if isempty(val)
        val='';
    end
    setenv('SLINTERNAL_RAPID_ACCEL_TARGET_IS_ACTIVE','1');
    rapidAccelActive=onCleanup(@()setenv('SLINTERNAL_RAPID_ACCEL_TARGET_IS_ACTIVE',val));

    buildData.toFileSuffix=[];
    numRuns=buildData.numRuns;
    runCmd=get_run_cmd(buildData);

    loc_update_sfcn_info_file(buildData);


    for i=1:numRuns
        runId=buildData.multiSimInfo.runInfo(i).RunId;
        runCmd{i}=[runCmd{i},' -T ',quote(['_',num2str(runId)])];
        runCmd{i}=[runCmd{i},' -dmr_idx ',num2str(runId)];
    end



    runFutures=simulink.rapidaccelerator.internal.runTargetsOnThreadPool(...
    runCmd,buildData,tpoolMgr);

end



function waitForSlProcess(p)
    testerName='RapidAccelSlProcessCtrlC';
    oldPauseState=pause('on');
    while p.Alive
        pause(0.1);



        xtester_emulate_ctrl_c(testerName);
    end
    pause(oldPauseState);
end



function oName=quote(iName)
    oName=iName;
    oName=['"',oName,'"'];
end



function runCmd=get_run_cmd(buildData)
    exeName=get_exe_name(buildData.buildDir,buildData.mdl);
    outFile=get_out_file(buildData.buildDir,buildData.tmpVarPrefix);
    simMetadataFile=get_simMetadata_file(buildData.buildDir,buildData.tmpVarPrefix);
    sigstreamFile=get_sigstream_file(buildData.buildDir,buildData.tmpVarPrefix);
    siglogselectorFile=...
    get_siglogselector_file(buildData.buildDir,buildData.tmpVarPrefix);

    prmFile=get_prm_file(buildData.buildDir,buildData.tmpVarPrefix);
    inpFile=get_inp_file(buildData.buildDir,buildData.tmpVarPrefix);
    slvrFile=get_slvr_file(buildData.buildDir,buildData.tmpVarPrefix);
    sFcnInfoFile=get_sfcn_info_file(buildData.buildDir,buildData.mdl);
    exeActiveToken=get_exe_active_token(buildData.tmpVarPrefix);
    errorFile=get_error_file(buildData.tmpVarPrefix);
    tgtconnActiveToken=get_tgtconn_active_token(buildData.tmpVarPrefix);
    nTmpVar=length(buildData.tmpVarPrefix);
    runCmd=cell(1,nTmpVar);
    simOptsFields=[];
    if~isempty(buildData.simOpts)
        simOptsFields=fieldnames(buildData.simOpts);
    end
    for i=1:nTmpVar
        runCmd{i}=quote(exeName);
        sbruntestsSessionID=getenv('SBRUNTESTS_SESSION_ID');
        if~isempty(sbruntestsSessionID)
            runCmd{i}=[runCmd{i},' -ignore-arg ',sbruntestsSessionID];
        end
        if(~Simulink.isRaccelDeployed)
            runCmd{i}=[runCmd{i},...
            ' -server_info_file ',quote(exeActiveToken{i})];
        end

        runCmd{i}=[runCmd{i},...
        ' -error_file ',quote(errorFile{i}),...
        ' -o ',quote(outFile{i}),...
        ' -m ',quote(simMetadataFile{i})];



        runCmd{i}=[runCmd{i},' -l ',quote(sigstreamFile{i})];

        runCmd{i}=[runCmd{i},' -e ',quote(siglogselectorFile{i})];

        runCmd{i}=[runCmd{i},' -R ',quote(Simulink.sdi.getSource())];

        if slfeature('JetstreamRapidAccelStreaming')
            runCmd{i}=[runCmd{i},' -live_stream'];
        end

        if exist(sFcnInfoFile,'file')
            runCmd{i}=[runCmd{i},' -d ',quote(sFcnInfoFile)];
        end

        paramFile=prmFile{i};


        if buildData.loadFromBuildRtpFile
            paramFile=get_build_prm_file(buildData.buildDir);
        end
        if exist(paramFile,'file')
            runCmd{i}=[runCmd{i},' -p ',quote(paramFile)];
        end

        if exist(slvrFile{i},'file')
            runCmd{i}=[runCmd{i},' -S ',quote(slvrFile{i})];
        end

        if exist(inpFile{i},'file')
            runCmd{i}=[runCmd{i},' -i ',quote(inpFile{i})];
        end

        fldStr=findStr(simOptsFields,'TimeOut');
        if~isempty(fldStr)
            timeOut=buildData.simOpts.(fldStr);
            if~isempty(timeOut)
                runCmd{i}=[runCmd{i},' -L ',num2str(timeOut)];
            end
        end

        if buildData.runningInParallel
            runCmd{i}=[runCmd{i},' -P '];
        end

        if(Simulink.isRaccelDeployed)
            runCmd{i}=[runCmd{i},' -D '];
        end

        if ischar(buildData.toFileSuffix)
            runCmd{i}=[runCmd{i},' -T ',quote(buildData.toFileSuffix)];
        end

        if slfeature('MLSysBlockRaccelReval')==1||...
            slfeature('FMUBlockRaccelReval')==1
            runCmd{i}=[runCmd{i},' -reval_host_to_target ',num2str(buildData.qidHost2target)];
            runCmd{i}=[runCmd{i},' -reval_target_to_host ',num2str(buildData.qidTarget2host)];
            runCmd{i}=[runCmd{i},' -reval_service_port ',num2str(buildData.dashServicePort)];
        end


        if(~Simulink.isRaccelDeployed)
            if~isempty(buildData.tgtConnMgr)
                portStr=num2str(0);
                runCmd{i}=[runCmd{i},...
                ' -tgtconn_server_info_file ',quote(tgtconnActiveToken{i}),...
                ' -tgtconn_port ',portStr];
            end
        end
    end

end




function launch_connect_and_start(buildData)



    iMdl=buildData.mdl;


    Simulink.filegen.internal.FolderConfiguration(iMdl);

    set_status_string(iMdl,'Simulink:tools:rapidAccelLaunching');

    if buildData.opts.verbose
        fprintf('### %6.2fs :: Launching ',etime(clock,buildData.startTime));
    end


    loc_PerfToolsTracerLogSimulinkData('TgtConn',iMdl,'RapidAccelSim','coder.internal.connectivity.TgtConnMgr.load',true);
    buildData.tgtConnMgr=coder.internal.connectivity.TgtConnMgr.load(iMdl,buildData.buildDir);
    loc_PerfToolsTracerLogSimulinkData('TgtConn',iMdl,'RapidAccelSim','coder.internal.connectivity.TgtConnMgr.load',false);
    set_param(iMdl,'RapidAcceleratorBuildData',buildData);



    val=getenv('SLINTERNAL_RAPID_ACCEL_TARGET_IS_ACTIVE');
    if isempty(val)
        val='';
    end
    setenv('SLINTERNAL_RAPID_ACCEL_TARGET_IS_ACTIVE','1');
    rapidAccelActive=onCleanup(@()setenv('SLINTERNAL_RAPID_ACCEL_TARGET_IS_ACTIVE',val));






    if(buildData.opts.debug||buildData.opts.profile)
        loc_raccel_debug(buildData,true);
    end




    buildData=setup_reval_service(buildData);

    portStr=num2str(0);

    cmdCell=get_raccel_run_cmd(buildData);

    loc_update_sfcn_info_file(buildData);

    assert(isequal(length(cmdCell),1));
    cmd=cmdCell{1};
    if slfeature('RapidAcceleratorDiagnosticsStreaming')<2
        cmd=[cmd,' -port ',portStr,' -verbose',' off'];
        if ispc


            winCmdFile=[buildData.buildDir,filesep,'winCmd.bat'];
            cmdLogFile=['"',buildData.buildDir,filesep,'cmdLog.txt"'];
            cmd=['cmd /D /c start "RapidAccelerator" /B ',cmd,' -w 1>',cmdLogFile];
            fid=fopen(winCmdFile,'w');
            fprintf(fid,'%s',cmd);
            fclose(fid);
            cmd=winCmdFile;
        else
            cmd=[cmd,' -w > /dev/null &'];
        end
    else
        cmd=[cmd,' -port ',portStr,' -verbose',' off',' -w'];
    end

    if(buildData.opts.debug==3)


        status=0;
        result='';
    else
        if true
            [status,result]=system(cmd);
        else
            buildData.menusim_p=slprocess.Process;%#ok<UNRCH>
            simulink.rapidaccelerator.internal.setTargetLibPathOnSlProcess(...
            builData.menusim_p...
            );
            buildData.menusim_p.start(cmd);
            set_param(buildData.mdl,'RapidAcceleratorBuildData',buildData);
            oldPauseState=pause('on');
            while buildData.menusim_p.Alive
                pause(0.1);
            end
            pause(oldPauseState);
            status=buildData.menusim_p.Status;
            result=buildData.menusim_p.Result;
        end
    end

    if slfeature('RapidAcceleratorDiagnosticsStreaming')<2
        if status~=0
            error(message('Simulink:tools:rapidAccelExeError',iMdl,result));
        end
    else
        if buildData.menusim_p.Alive~=1||buildData.menusim_p.Status~=0
            error(message('Simulink:tools:rapidAccelExeError',iMdl,buildData.menusim_p.Result));
        end
    end

    exeActiveToken=get_exe_active_token(buildData.tmpVarPrefix);
    errorFile=get_error_file(buildData.tmpVarPrefix);
    [pid,portToUse]=get_pid_and_port(buildData,exeActiveToken{1},'toConnect',errorFile{1});
    if isempty(pid)


        error(message('Simulink:tools:rapidAccelCannotGetPID',iMdl));
    end
    if slfeature('RapidAcceleratorDiagnosticsStreaming')==2&&buildData.menusim_p.Alive~=1
        error(message('Simulink:tools:rapidAccelUnableToStartExecutable',iMdl,pid));
    end
    if isempty(portToUse)
        error(message('Simulink:tools:rapidAccelUnableToFindPort',iMdl));
    end


    try
        if~isempty(buildData.tgtConnMgr)
            exeActiveToken=get_tgtconn_active_token(buildData.tmpVarPrefix);
            tgtconnPortToUse=get_tgtconn_port(buildData,exeActiveToken{1});
            if isempty(tgtconnPortToUse)
                error(message('Simulink:tools:rapidAccelUnableToFindPort',iMdl));
            end

            loc_PerfToolsTracerLogSimulinkData('TgtConn',iMdl,'RapidAccelSim','buildData.tgtConnMgr.start',true);
            buildData.tgtConnMgr.start('port',str2double(tgtconnPortToUse));
            loc_PerfToolsTracerLogSimulinkData('TgtConn',iMdl,'RapidAccelSim','buildData.tgtConnMgr.start',false);

            loc_PerfToolsTracerLogSimulinkData('TgtConn',iMdl,'RapidAccelSim','Simulink.HMI.slhmi',true);
            ME=coder.internal.connectivity.ToAsyncQueueAppSvc.startSDIVisualizations(iMdl);
            if~isempty(ME)
                rethrow(ME);
            end
            loc_PerfToolsTracerLogSimulinkData('TgtConn',iMdl,'RapidAccelSim','Simulink.HMI.slhmi',false);
        end
    catch ME %#ok<NASGU>
        warning(message('Simulink:tools:rapidAccelTgtConnConnectFailed'));
    end


    dirty=get_param(iMdl,'Dirty');

    set_param(iMdl,'RapidAcceleratorSimStatus','connecting');
    set_status_string(iMdl,'Simulink:tools:rapidAccelConnecting');
    if buildData.opts.verbose
        fprintf('### %6.2fs :: Connecting ',etime(clock,buildData.startTime));
    end

    Simulink.ExtMode.CtrlPanel.destroyExtModeCtrlPanelForModel(iMdl);


    extModeVerbose='0';
    if buildData.opts.verbose>1||buildData.opts.extModeVerbose>0
        extModeVerbose='1';
    end
    if buildData.opts.verbose>1,extModeVerbose='1';end
    set_param(iMdl,'ExtModeMexArgs',[''''', ',extModeVerbose,', ',portToUse]);


    set_param(iMdl,'IsExtModeSimForRapidAccelerator','on');

    set_param(iMdl,'Dirty',dirty);


    connect_stage=Simulink.output.Stage(message('Simulink:tools:rapidAcceleratorExternalModeConnectStage').getString,...
    'ModelName',iMdl,'UIMode',true);%#ok<NASGU>


    hTflControl=get_param(iMdl,'TargetFcnLibHandle');
    hTflControlSim=get_param(iMdl,'SimTargetFcnLibHandle');
    set_param(iMdl,'TargetFcnLibHandle',hTflControlSim);

    if isfield(buildData.opts.internalTesting,'checksumError')
        loc_SwapSolver(iMdl);
    end


    set_param(iMdl,'SimulationCommand','connect');

    clear('connect_stage');


    okayToStart=false;
    nFailedConnectionAtttempts=0;
    while nFailedConnectionAtttempts<buildData.opts.maxAttempts
        if buildData.opts.verbose,fprintf('.');end

        set_param(iMdl,'ExtModeCommand','ProcessMsg');

        if(isequal(get_param(iMdl,'ExtModeStartButtonEnabled'),'on')&&...
            isequal(get_param(iMdl,'ExtModeTargetSimStatus'),'waitingToStart'))
            assert(isequal(get_param(iMdl,'ExtModeConnected'),'on'));
            okayToStart=true;
            break;
        end

        nFailedConnectionAtttempts=nFailedConnectionAtttempts+1;
        pause(buildData.opts.pauseInterval);
    end

    if~okayToStart||~isequal(get_param(iMdl,'SimulationStatus'),'external')
        error(message('Simulink:tools:rapidAccelExtModeConnectFailed'));
    end
    if buildData.opts.verbose,fprintf('\n');end


    if slfeature('ForEachParallelExecutionInRapidAccel')>0&&...
        ~slsvTestingHook('DisableParallelExecutionEngineInRapidAccelExe')&&...
        ~isempty(get_param(iMdl,'ParallelExecutionNodeHandles'))
        numWorkerThreads=loc_get_ForEach_parallel_execution_max_num_threads(iMdl);
        set_status_string(iMdl,'Simulink:tools:rapidAccelRunningInMultithreading',...
        numWorkerThreads);
    else
        set_status_string(iMdl,'Simulink:tools:rapidAccelRunning');
    end

    if buildData.opts.verbose
        fprintf('### %6.2fs :: Starting\n',etime(clock,buildData.startTime));
    end
    set_param(iMdl,'SimulationCommand','start');
    set_param(iMdl,'TargetFcnLibHandle',hTflControl);

end


function youtData=loc_pack_yout_data(youtLogData,nYoutLogData,...
    nYoutVars,format,~)
    if isequal(lower(format),'array')
        if(nYoutVars==1)&&(nYoutLogData>1)

            youtLogData{1}=reshapeOutputIfNecessary(youtLogData{1});
            youtData{1}=youtLogData{1};
            for i=2:nYoutLogData
                youtLogData{i}=reshapeOutputIfNecessary(youtLogData{i});
                if(~isequal(class(youtData{1}),class(youtLogData{i})))
                    error(message('Simulink:Engine:OutportInvalidArrayDataLogging_DATATYPE'));
                end
                youtData{1}=[youtData{1},youtLogData{i}];
            end
        else
            youtData=youtLogData;
        end
    else
        if nYoutVars==1
            i=1;
            while(i<nYoutLogData+1)
                if isfield(youtLogData{i},{'time','signals'})
                    break;
                else
                    i=i+1;
                end

            end
            if(i>nYoutLogData)
                youtData{1}.time=[];
                youtData{1}.signals=[];
                return;
            end
            youtData{1}.time=youtLogData{i}.time;
            youtData{1}.signals=[];

            for i=1:nYoutLogData
                if isfield(youtLogData{i},'signals')
                    sigFlds=fieldnames(youtLogData{i}.signals);
                    for j=1:length(sigFlds)
                        youtData{1}.signals(i).(sigFlds{j})=...
                        youtLogData{i}.signals.(sigFlds{j});
                    end
                else
                    youtData{1}.signals(i).values=[];
                end
            end
        else
            youtData=youtLogData;
        end
    end
end





function logVars=loc_reshapeVectorOutput(logVars)
    varNames=fieldnames(logVars);
    nVars=length(varNames);
    for idx=1:nVars
        origData=logVars.(varNames{idx});
        if(isfield(origData,'signals'))
            for idx2=1:length(origData.signals)
                if~isfield(origData.signals(idx2),'values')||...
                    isempty(origData.signals(idx2).values)
                    continue;
                end
                values=origData.signals(idx2).values;
                if ndims(values)==2&&size(values,2)>1
                    origData.signals(idx2).values=reshape(values,size(values'))';
                end
            end
        elseif(~isempty(origData)&&ndims(origData)==2&&size(origData,2)>1)
            origData=reshape(origData,size(origData'))';
        end
        logVars.(varNames{idx})=origData;
    end
end


function logVars=getSimulationOutputFromMatFile(buildData,outputMatFile,sdiRunId)
    logVars=[];


    if exist(outputMatFile,'file')
        logVars=load(outputMatFile);
        logVars=loc_reshapeVectorOutput(logVars);
    end

    numOutports=buildData.rootOutportsInfo.numOutports;
    if buildData.logging.SaveOutput&&numOutports>0
        [nYoutVars,youtVars]=loc_get_var_names(...
        buildData.logging.OutputSaveName,buildData.mdl);

        [logVars,youtLogData]=loc_get_yout_data(logVars,buildData,...
        nYoutVars);

        youtData=loc_pack_yout_data(...
        youtLogData,numOutports,nYoutVars,...
        buildData.logging.SaveFormat);

        for idx=1:nYoutVars
            var=youtVars{idx};
            if~isempty(youtData{idx})
                editedData=loc_edit_yout_data(youtData{idx});
                logVars.(var)=editedData;
            end
        end
    end

    slvrFile=get_slvr_file(buildData.buildDir,buildData.tmpVarPrefix);
    slvrSettings=load(slvrFile{1});


    logBlkData=Simulink.sdi.internal.getRapidAccelStreamoutBlockData(buildData,slvrSettings,sdiRunId);
    if~isempty(logBlkData)
        for count=1:length(logBlkData)
            var=logBlkData(count).var;
            if~isempty(var)
                logVars.(var)=logBlkData(count).data;
            end
        end
    end


    if isfield(logVars,buildData.logging.FinalStateName)
        logVars=rmfield(logVars,buildData.logging.FinalStateName);
    end

    if isfield(logVars,buildData.logging.StateSaveName)
        logVars=rmfield(logVars,buildData.logging.StateSaveName);
    end
end



function simOut=getSimulationOutputInStructureFormat(buildData,outputMatFile,sdiRunId)
    logVars=getSimulationOutputFromMatFile(buildData,outputMatFile,sdiRunId);
    [logVars,~,~]=editLogVars(logVars);

    simOut=Simulink.SimulationOutput(logVars);
end


function simOut=getSimulationOutputInDatasetFormat(buildData,sdiRunId,outputMatFile)
    yout=[];
    index=1;
    outportList=buildData.rootOutportsInfo.rootRootOutports;
    outportData=locGenerateOutportData(outportList);

    siglogselectorFile=get_siglogselector_file(buildData.buildDir,buildData.tmpVarPrefix);
    slvrFile=get_slvr_file(buildData.buildDir,buildData.tmpVarPrefix);

    logSettings=load(siglogselectorFile{index});
    slvrSettings=load(slvrFile{index});


    [streamout,streamoutName]=Simulink.sdi.internal.getRapidAccelStreamedData(...
    buildData,logSettings,slvrSettings,[],false,sdiRunId,[],'');

    logVars=getSimulationOutputFromMatFile(buildData,outputMatFile,sdiRunId);
    [logVars,~,~]=editLogVars(logVars);

    if~isempty(streamout)
        if isequal(get_param(buildData.mdl,'DatasetSignalFormat'),'timetable')
            streamout=streamout.convertTStoTTatLeaf();
        end
        logVars.(streamoutName)=streamout;
    end

    numOutports=buildData.rootOutportsInfo.numOutports;
    if buildData.logging.SaveOutput&&numOutports>0
        [yout,youtName]=Simulink.sdi.internal.getRapidAccelStreamedData(...
        buildData,logSettings,slvrSettings,[],false,sdiRunId,[],'outport',outportData);
        haveYout=~isempty(youtName);
        if haveYout
            if isequal(get_param(buildData.mdl,'DatasetSignalFormat'),'timetable')
                yout=yout.convertTStoTTatLeaf();
            end
            logVars.(youtName)=yout;
        end
    end

    simOut=Simulink.SimulationOutput(logVars);
end

function simOut=getSimulationOutput(buildData,sdiRunId,outputMatFile)
    saveFormat=lower(buildData.logging.SaveFormat);
    if~buildData.logging.isOriginalFormatDataset&&...
        (isequal(saveFormat,'structure')||isequal(saveFormat,'structurewithtime'))
        simOut=getSimulationOutputInStructureFormat(buildData,outputMatFile,sdiRunId);
    else
        assert(isequal(saveFormat,'dataset')||buildData.logging.isOriginalFormatDataset,...
        ['simulink.compiler.getSimulationOutput : Invalid SaveFormat ',saveFormat]);
        simOut=getSimulationOutputInDatasetFormat(buildData,sdiRunId,outputMatFile);
    end
end

function[logVars,vars,nVars]=editLogVars(logVars)

    if isempty(logVars)
        vars=[];
        nVars=0;
        return;
    end

    vars=fieldnames(logVars);
    nVars=length(vars);
    for idx=1:nVars
        if isfield(logVars.(vars{idx}),'blockName')
            logVars.(vars{idx}).blockName=slsvInternal('slsvEscapeServices','unescapeString',logVars.(vars{idx}).blockName);
        end
        if isfield(logVars.(vars{idx}),'signals')
            for i=1:length(logVars.(vars{idx}).signals)
                logVars.(vars{idx}).signals(i).label=slsvInternal('slsvEscapeServices','unescapeString',logVars.(vars{idx}).signals(i).label);
                if isfield(logVars.(vars{idx}).signals(i),'blockName')
                    logVars.(vars{idx}).signals(i).blockName=slsvInternal('slsvEscapeServices','unescapeString',logVars.(vars{idx}).signals(i).blockName);
                elseif isfield(logVars.(vars{idx}).signals(i),'title')
                    logVars.(vars{idx}).signals(i).title=slsvInternal('slsvEscapeServices','unescapeString',logVars.(vars{idx}).signals(i).title);
                end
            end
        end
    end
end



function varargout=load_mat_file(buildData,index,isMenuSim,loggingFilePtr,simMetadataStruct)
    if buildData.opts.verbose
        fprintf('### %6.2fs :: Loading results for process %i/%i\n',etime(clock,buildData.startTime),index,buildData.numRuns);
    end

    iMdl=buildData.mdl;
    loc_PerfToolsTracerLogSimulinkData('Simulink Compile',...
    iMdl,'RapidAccelSim','MAT File Loading',true);


    varargout=cell(1,nargout);
    nVars=0;
    outFile=get_out_file(buildData.buildDir,buildData.tmpVarPrefix);
    operatingPointFile=get_operating_point_file(buildData.buildDir,buildData.tmpVarPrefix);
    sigstreamFile=get_sigstream_file(buildData.buildDir,buildData.tmpVarPrefix);
    siglogselectorFile=...
    get_siglogselector_file(buildData.buildDir,buildData.tmpVarPrefix);
    if Simulink.isRaccelDeployed
        if isempty(loggingFilePtr)
            signalStorageParameters=load(siglogselectorFile{index},'signalStorageParameters').signalStorageParameters;
        end
    end
    prmFile=get_prm_file(buildData.buildDir,buildData.tmpVarPrefix);
    inpFile=get_inp_file(buildData.buildDir,buildData.tmpVarPrefix);
    slvrFile=get_slvr_file(buildData.buildDir,buildData.tmpVarPrefix);
    nTmpVar=length(buildData.tmpVarPrefix);
    wksp='caller';
    logSettings=load(siglogselectorFile{index});
    bJetstreamLTF=logSettings.signalLoggingToPersistentStorage>1;

    if isMenuSim,wksp='base';end


    isMultisim=~isempty(buildData.multiSimInfo);
    if isMultisim
        isMenuSim=buildData.numReturnValues<0;
        runId=buildData.multiSimInfo.runInfo(index).RunId;
        dmrIdx=num2str(runId);
        Simulink.sdi.internal.importCompletedRapidAccelRuns(buildData.mdl,isMenuSim,dmrIdx);
    end



    if~buildData.returnDstWkspOutput


        if buildData.logging.SaveOutput&&...
            isequal(get_param(iMdl,'LoggingToFile'),'on')&&...
            isMenuSim&&evalin(wksp,['exist(''',buildData.logging.OutputSaveName,''',''var'')'])
            assignin(wksp,buildData.logging.OutputSaveName,[]);
        end

        if buildData.logging.SignalLogging&&...
            isMenuSim&&evalin(wksp,['exist(''',buildData.logging.SignalLoggingName,''',''var'')'])
            assignin(wksp,buildData.logging.SignalLoggingName,[]);
        end

        if buildData.IATesting.IntrusiveAccessorTesting&&...
            isMenuSim&&evalin(wksp,['exist(''',buildData.logging.IATestingName,''',''var'')'])
            assignin(wksp,buildData.logging.IATestingName,[]);
        end
    end

    datasetSaveFormat=isequal(lower(buildData.logging.SaveFormat),'dataset');
    nYoutVars=0;
    youtVars=[];
    stdArgs=buildData.numReturnValues;
    numOutports=buildData.rootOutportsInfo.numOutports;
    outportList=buildData.rootOutportsInfo.rootRootOutports;



    if(buildData.logging.SaveOutput&&(numOutports>0))
        if~(datasetSaveFormat||buildData.logging.isOriginalFormatDataset)
            [nYoutVars,youtVars]=loc_get_var_names(...
            buildData.logging.OutputSaveName,buildData.mdl);
        end
    end
    haveOutput=exist(outFile{index},'file')~=0;

    haveYout=false;
    haveLogsOut=false;
    haveIAOut=false;
    sigstreamMat=[];
    if exist(sigstreamFile{index},'file')&&...
        (buildData.logging.SignalLogging||...
        (buildData.logging.SaveOutput&&datasetSaveFormat))


        try
            sigstreamMat=load(sigstreamFile{index});
        catch E %#ok to ignore the error
        end
    end

    if buildData.logging.SignalLogging&&...
        isfield(sigstreamMat,'DATASET_SIGNAL_LOGGING')
        logsoutName=buildData.logging.SignalLoggingName;
        if isempty(sigstreamMat.DATASET_SIGNAL_LOGGING)
            logsout=[];
        else
            sigstreamMat.DATASET_SIGNAL_LOGGING.Dataset.Name=logsoutName;
            logsout=Simulink.SimulationData.Dataset.utcreatefromstruct(...
            sigstreamMat.DATASET_SIGNAL_LOGGING...
            );
            if isequal(buildData.logging.datasetSignalFormat,'timetable')
                logsout=logsout.convertTStoTTatLeaf();
            end
        end
        haveLogsOut=true;
        if isa(logsout,'Simulink.SimulationData.Dataset')&&...
            isa(logsout.getStorage,'Simulink.SimulationData.Storage.MatFileDatasetStorage')
            haveLogsOut=false;
            eval([logsout.Name,' = logsout;']);
            if isempty(loggingFilePtr)
                save(signalStorageParameters,logsoutName,'-append');
            else
                sigstream_mapi(...
                'saveMxArrayToOpenMatFile',...
                logsout,...
                logsout.Name,...
                loggingFilePtr);
            end
        end
    end

    if buildData.IATesting.IntrusiveAccessorTesting&&...
        isfield(sigstreamMat,'DATASET_INTRUSIVE_ACCESSOR')
        IA_output_Name=buildData.IATesting.IATestingName;
        if isempty(sigstreamMat.DATASET_INTRUSIVE_ACCESSOR)
            IA_output=[];
        else
            sigstreamMat.DATASET_INTRUSIVE_ACCESSOR.Dataset.Name=IA_output_Name;
            IA_output=Simulink.SimulationData.Dataset.utcreatefromstruct(...
            sigstreamMat.DATASET_INTRUSIVE_ACCESSOR...
            );
            haveIAOut=true;
        end
    end


    usingJetstreamOutports=bJetstreamLTF||~any(loggingFilePtr);
    if buildData.logging.SaveOutput&&(numOutports>0)&&datasetSaveFormat&&...
        ~usingJetstreamOutports
        if isfield(sigstreamMat,'DATASET_OUTPORT_LOGGING')
            if numOutports>length(sigstreamMat.DATASET_OUTPORT_LOGGING.Dataset.Elements)

                for oidx=1:numOutports
                    if oidx>length(sigstreamMat.DATASET_OUTPORT_LOGGING.Dataset.Elements)||...
                        ~isequal(outportList(oidx),...
                        sigstreamMat.DATASET_OUTPORT_LOGGING.Dataset.Elements{oidx}.BlockPath)

                        sigstreamMat.DATASET_OUTPORT_LOGGING.Dataset.Elements=...
                        [sigstreamMat.DATASET_OUTPORT_LOGGING.Dataset.Elements(1:oidx-1);...
                        loc_generate_inactive_outport_element_struct(outportList{oidx});...
                        sigstreamMat.DATASET_OUTPORT_LOGGING.Dataset.Elements(oidx:end)];
                    end
                end
            end
        else

            if isequal(get_param(iMdl,'LoggingToFile'),'on')
                sigstreamMat.DATASET_OUTPORT_LOGGING.DatasetStorageType='MatFileDatasetStorage';
                sigstreamMat.DATASET_OUTPORT_LOGGING.Dataset.FileName=...
                get_param(iMdl,'ResolvedLoggingFileName');
            else
                sigstreamMat.DATASET_OUTPORT_LOGGING.DatasetStorageType='RamDatasetStorage';
            end
            sigstreamMat.DATASET_OUTPORT_LOGGING.Dataset.Name='yout';
            sigstreamMat.DATASET_OUTPORT_LOGGING.Dataset.Elements=cell(numOutports,1);
            for oidx=1:numOutports
                sigstreamMat.DATASET_OUTPORT_LOGGING.Dataset.Elements{oidx}=...
                loc_generate_inactive_outport_element_struct(outportList{oidx});
            end
        end
        assert(numOutports==length(sigstreamMat.DATASET_OUTPORT_LOGGING.Dataset.Elements),...
        'number of outport logged mismatch');
    end

    if buildData.logging.SaveOutput&&...
        isfield(sigstreamMat,'DATASET_OUTPORT_LOGGING')
        youtName=buildData.logging.OutputSaveName;
        if isempty(sigstreamMat.DATASET_OUTPORT_LOGGING)
            yout=[];
        else
            sigstreamMat.DATASET_OUTPORT_LOGGING.Dataset.Name=youtName;
            yout=Simulink.SimulationData.Dataset.utcreatefromstruct(...
            sigstreamMat.DATASET_OUTPORT_LOGGING...
            );
            if isequal(buildData.logging.datasetSignalFormat,'timetable')
                yout=yout.convertTStoTTatLeaf();
            end
        end
        haveYout=true;
        if isa(yout,'Simulink.SimulationData.Dataset')&&...
            isa(yout.getStorage,'Simulink.SimulationData.Storage.MatFileDatasetStorage')
            haveYout=false;
            eval([yout.Name,' = yout;']);
            if isempty(loggingFilePtr)
                save(signalStorageParameters,youtName,'-append');
            else
                sigstream_mapi(...
                'saveMxArrayToOpenMatFile',...
                yout,...
                yout.Name,...
                loggingFilePtr);
            end
        end
    end


    if~isempty(buildData.tgtConnMgr)
        buildData.tgtConnMgr.stop();
    end


    mdForUpdate=simMetadataStruct;
    if isempty(mdForUpdate)
        mdForUpdate=load_simMetadata_file(buildData,index);
    end

    hasSimlog=false;
    if exist('_simscape_get_logged_data','builtin')~=0
        if simscape.logging.internal.raccel_logging()
            if isfield(buildData.simOpts,'RapidAcceleratorUpToDateCheck')
                upToDateCheck=strcmpi(buildData.simOpts.RapidAcceleratorUpToDateCheck,'on');
            else
                upToDateCheck=true;
            end
            [hasSimlog,simlog,simlogName]=...
            builtin('_simscape_get_logged_data',buildData.mdl,upToDateCheck);
        end
    end


    slvrSettings=load(slvrFile{index});


    [streamout,streamoutName]=Simulink.sdi.internal.getRapidAccelStreamedData(...
    buildData,logSettings,slvrSettings,loggingFilePtr,isMenuSim,0,mdForUpdate,'');


    needJetStreamDatasetOutput=datasetSaveFormat||buildData.logging.isOriginalFormatDataset;
    if usingJetstreamOutports&&buildData.logging.SaveOutput&&(numOutports>0)&&needJetStreamDatasetOutput
        outportData=locGenerateOutportData(outportList);
        [yout,youtName]=Simulink.sdi.internal.getRapidAccelStreamedData(...
        buildData,logSettings,slvrSettings,loggingFilePtr,isMenuSim,0,mdForUpdate,'outport',outportData);
        haveYout=~isempty(youtName);
        if haveYout&&isequal(get_param(buildData.mdl,'DatasetSignalFormat'),'timetable')
            yout=yout.convertTStoTTatLeaf();
        end
    end


    logBlkData=Simulink.sdi.internal.getRapidAccelStreamoutBlockData(buildData,slvrSettings,0);


    saveOperatingPoint=false;
    operatingPointName='';

    if buildData.logging.SaveOperatingPoint&&buildData.logging.SaveFinalState
        saveOperatingPoint=true;
        operatingPointName=buildData.logging.FinalStateName;
    end


    loggingToWorkspace=haveOutput||haveYout||...
    haveLogsOut||haveIAOut||~isempty(streamout)||...
    ~isempty(logBlkData)||saveOperatingPoint||...
    hasSimlog;
    if loggingToWorkspace
        logVars=struct();


        if haveOutput
            logVars=load(outFile{index});
        end


        if saveOperatingPoint&&exist(operatingPointFile{index},'file')
            if~isfield(logVars,operatingPointName)
                logVars.(operatingPointName)=[];
            end



            loggedStates=[];
            loggedStates.signals=[];
            loggedStates.time=0;
            opData=load(operatingPointFile{index});
            if~isempty(logVars.(operatingPointName))&&...
                isfield(opData,'loggedStates')
                loggedStates.signals=logVars.(operatingPointName).signals;
                loggedStates.time=logVars.(operatingPointName).time;
                for i=1:length(loggedStates.signals)
                    loggedStates.signals(i).values=...
                    copy_binary_data_to_mxarray(loggedStates.signals(i).values,...
                    opData.loggedStates(i).values);
                    loggedStates.signals(i).label=slsvInternal('slsvEscapeServices',...
                    'unescapeString',loggedStates.signals(i).label);
                    loggedStates.signals(i).stateName=slsvInternal('slsvEscapeServices',...
                    'unescapeString',loggedStates.signals(i).stateName);
                    if isfield(loggedStates.signals(i),'blockName')
                        loggedStates.signals(i).blockName=slsvInternal('slsvEscapeServices',...
                        'unescapeString',loggedStates.signals(i).blockName);
                    elseif isfield(loggedStates.signals(i),'title')
                        loggedStates.signals(i).title=slsvInternal('slsvEscapeServices',...
                        'unescapeString',loggedStates.signals(i).title);
                    end
                end
            end

            logVars.(operatingPointName)=Simulink.op.ModelOperatingPoint;
            SetOPFieldAccess(2);

            if Simulink.isRaccelDeployed
                logVars.(operatingPointName).version='0';
            else
                logVars.(operatingPointName).version=num2str(get_param(0,'version'));
            end



            checkSumData=load(get_checksum_file(buildData.mdl,buildData.buildDir));
            logVars.(operatingPointName).checksum=checkSumData.raccelChecksum;

            logVars.(operatingPointName).startTime=slvrSettings.slvrOpts.StartTime;
            logVars.(operatingPointName).cStateChanged=false;


            if buildData.logging.isOriginalFormatDataset

                loggedStateInDataset=buildData.templateDataset;
                dataset_initial_state_utils('warnAboutRapidNotLogging',loggedStateInDataset);

                loggedStateInDataset=populate_dataset(loggedStateInDataset,loggedStates,buildData.mdl);
                if isempty(loggedStateInDataset)
                    loggedStateInDataset=Simulink.SimulationData.Dataset;
                end
                logVars.(operatingPointName).rapidAcceleratorLoggedStates=loggedStateInDataset;
            else
                logVars.(operatingPointName).rapidAcceleratorLoggedStates=loggedStates;
            end
            assert(exist(operatingPointFile{index},'file')==2);
            logVars.(operatingPointName).simLoopSimState.execEngineSimState=opData.OperatingPointData;
            logVars.(operatingPointName).hasSolverData=true;
            logVars.(operatingPointName).platform=buildData.computer.arch;
            logVars.(operatingPointName).fundamentalStepSize=buildData.fundamentalDiscreteRate;

            if isfield(opData,'time')
                description=message('Simulink:op:ModelSimStateDefaultDescription',...
                buildData.mdl,num2str(opData.time)).getString();
            else
                description=message('Simulink:op:ModelSimStateStoppedDescription',...
                buildData.mdl).getString();
            end

            logVars.(operatingPointName).description=description;
            logVars.(operatingPointName).solver=opData.solver;
            logVars.(operatingPointName).blockSimStates=[];
            if isfield(opData,'blockSimStates')
                logVars.(operatingPointName).blockSimStates=opData.blockSimStates;
            end




            miscData=struct('timeOfNextContinuousVariableHit',[]);
            logVars.(operatingPointName).miscData=struct('miscData',miscData);
            if isfield(opData,'miscData')
                logVars.(operatingPointName).miscData=struct('miscData',opData.miscData);
            end

            SetOPFieldAccess(1);


            delete(operatingPointFile{index});
        end


        if haveYout
            logVars.(youtName)=yout;
        end


        if haveLogsOut
            logVars.(logsoutName)=logsout;
        end
        if~isempty(streamout)
            if isequal(get_param(buildData.mdl,'DatasetSignalFormat'),'timetable')
                streamout=streamout.convertTStoTTatLeaf();
            end
            logVars.(streamoutName)=streamout;
        end


        if haveIAOut
            logVars.(IA_output_Name)=IA_output;
        end


        if hasSimlog
            logVars.(simlogName)=simlog;


            loggingListener=...
            simscape.logging.sli.internal.loggingListeners(buildData.mdl);
            if~isempty(loggingListener)
                loggingListener(buildData.mdl,simlogName,simlog);
            end
        end


        if buildData.logging.SaveState
            if buildData.numReturnValues>0
                var=[buildData.loggingPfx,'xout'];
            else
                var=buildData.logging.StateSaveName;
            end
            if(isfield(logVars,var)&&isstruct(logVars.(var))&&...
                isfield(logVars.(var),'signals')&&isempty(logVars.(var).signals))
                logVars.(var)=[];
            end
        end


        if(buildData.logging.SaveFinalState)
            if buildData.numReturnValues>0
                var=[buildData.loggingPfx,'xFinal'];
            else
                var=buildData.logging.FinalStateName;
            end
            if(isfield(logVars,var)&&isstruct(logVars.(var))&&...
                isfield(logVars.(var),'signals')&&isempty(logVars.(var).signals))
                logVars.(var)=[];
            end
        end


        if~buildData.logging.isOriginalFormatDataset
            if(stdArgs>0)
                [logVars,varargout{1:stdArgs}]=loc_load_return_values(...
                logVars,1,buildData,varargout{1:stdArgs});
            elseif(nYoutVars>0)
                [logVars,youtLogData]=loc_get_yout_data(logVars,buildData,...
                nYoutVars);
                youtData=loc_pack_yout_data(...
                youtLogData,numOutports,nYoutVars,...
                buildData.logging.SaveFormat);
            end
        end



        if~isempty(logBlkData)
            loggedVarNames=loc_get_list_of_all_logged_vars(buildData.mdl,buildData.logging,logVars);
            for count=1:length(logBlkData)
                var=logBlkData(count).var;
                bp=logBlkData(count).BlockPath;
                if~isempty(var)
                    if any(strcmp(loggedVarNames,var))
                        warning(message('record_playback:errors:RapidAccelNameClash',bp,var));
                    else
                        logVars.(var)=logBlkData(count).data;
                        loggedVarNames{end+1}=var;%#ok<AGROW>
                    end
                end
            end
        end


        [logVars,vars,nVars]=editLogVars(logVars);


        if buildData.logging.isOriginalFormatDataset
            var=buildData.logging.FinalStateName;
            if buildData.logging.SaveFinalState&&...
                ~saveOperatingPoint

                LogVariableForDataset=buildData.templateDataset;
                dataset_initial_state_utils('warnAboutRapidNotLogging',LogVariableForDataset);

                if isfield(logVars,var)


                    LogVariableForDataset=populate_dataset(LogVariableForDataset,logVars.(var),buildData.mdl);
                    strLoggingToFile=get_param(buildData.mdl,'LoggingToFile');
                    loggingToFile=strcmp(strLoggingToFile,'on');
                    if loggingToFile
                        logVars=dataset_initial_state_utils('logDatasetToFile',logVars,buildData,LogVariableForDataset,loggingFilePtr);
                    else
                        logVars.(var)=LogVariableForDataset;
                    end
                end
            end
            var=buildData.logging.OutputSaveName;
            if buildData.logging.SaveOutput&&isfield(logVars,var)
                youtData=cell(1,1);
                youtData{1,1}=logVars.(var);
            end
        end

        if~buildData.treatDstWkspAsReadOnly

            if nTmpVar==1
                for idx=1:nVars
                    var=vars{idx};
                    assignin(wksp,var,getfield(logVars,var));%#ok
                end


                if buildData.logging.SaveState&&...
                    isempty(intersect(vars,buildData.logging.StateSaveName))
                    assignin(wksp,buildData.logging.StateSaveName,[]);
                end

                if buildData.logging.SaveFinalState&&...
                    isempty(intersect(vars,buildData.logging.FinalStateName))
                    assignin(wksp,buildData.logging.FinalStateName,[]);
                end

                for idx=1:nYoutVars
                    var=youtVars{idx};
                    if~isempty(youtData{idx})
                        editedData=loc_edit_yout_data(youtData{idx});
                        assignin(wksp,var,editedData);
                    end
                end
            else
                varCell=cell(1,(nVars+nYoutVars));
                for idx=1:nVars
                    varCell{idx}=cell(1,nTmpVar);
                    varCell{idx}{index}=getfield(logVars,vars{idx});%#ok
                end
                for idx=1:nYoutVars
                    varCell{idx+nVars}=cell(1,nTmpVar);


                    varCell{idx+nVars}{index}=youtData{idx};
                end
            end
        else
            for idx=1:nYoutVars
                var=youtVars{idx};
                if~isempty(youtData{idx})
                    editedData=loc_edit_yout_data(youtData{idx});
                    logVars.(var)=editedData;
                end
            end
            if(buildData.returnDstWkspOutput)



                if buildData.logging.SaveState&&...
                    isempty(intersect(vars,buildData.logging.StateSaveName))
                    logVars.(buildData.logging.StateSaveName)=[];
                end
                if buildData.logging.SaveFinalState&&...
                    isempty(intersect(vars,buildData.logging.FinalStateName))
                    logVars.(buildData.logging.FinalStateName)=[];
                end

                if(~isMenuSim&&(nargout>0))
                    if nTmpVar==1
                        if nargout==1


                            varargout{nargout}=logVars;
                        else
                            varargout{nargout}=Simulink.SimulationOutput(logVars);
                        end
                    else
                        varargout{nargout}=logVars;
                    end
                elseif(~isMenuSim&&(nargout==0))
                    varargout{1}=logVars;
                elseif(isMenuSim&&...
                    ~isempty(buildData.returnDstWkspOutputName))
                    assignin(wksp,buildData.returnDstWkspOutputName,...
                    Simulink.SimulationOutput(logVars,simMetadataStruct));


                end
            end

        end
        if exist(outFile{index},'file')&&isempty(buildData.opts.keepArtifacts)
            delete(outFile{index});
        end
        if exist(sigstreamFile{index},'file')&&isempty(buildData.opts.keepArtifacts)
            delete(sigstreamFile{index});
        end
        if exist(siglogselectorFile{index},'file')&&isempty(buildData.opts.keepArtifacts)
            delete(siglogselectorFile{index});
        end
    elseif(buildData.returnDstWkspOutput&&nargout>0)
        s=struct([]);

        if buildData.logging.SaveState
            s(1).(buildData.logging.StateSaveName)=[];
        end
        if buildData.logging.SaveFinalState
            s(1).(buildData.logging.FinalStateName)=[];
        end
        varargout{nargout}=s;
    elseif(buildData.returnDstWkspOutput&&isMenuSim&&...
        ~isempty(buildData.returnDstWkspOutputName))


        s=struct([]);
        if buildData.logging.SaveState
            s(1).(buildData.logging.StateSaveName)=[];
        end
        if buildData.logging.SaveFinalState
            s(1).(buildData.logging.FinalStateName)=[];
        end
        assignin(wksp,buildData.returnDstWkspOutputName,...
        Simulink.SimulationOutput(s,simMetadataStruct));
    else
        if buildData.logging.SaveState
            assignin(wksp,buildData.logging.StateSaveName,[]);
        end
        if buildData.logging.SaveFinalState
            assignin(wksp,buildData.logging.FinalStateName,[]);
        end
    end

    if Simulink.isRaccelDeployed
        Simulink.standalone.clearIntEnumType();
    end


    if(~isempty(prmFile{index})&&exist(prmFile{index},'file')&&isempty(buildData.opts.keepArtifacts))
        delete(prmFile{index});
    end
    if(~isempty(inpFile{index})&&exist(inpFile{index},'file')&&isempty(buildData.opts.keepArtifacts))
        delete(inpFile{index});
    end
    if(~isempty(slvrFile{index})&&exist(slvrFile{index},'file')&&isempty(buildData.opts.keepArtifacts))
        delete(slvrFile{index});
    end

    if((nTmpVar>1)&&((nVars+nYoutVars)>0))
        for idx=1:(nVars+nYoutVars)
            try
                var=vars{idx};

                assignin(wksp,var,varCell{idx});
            catch
            end
        end
    end

    loc_PerfToolsTracerLogSimulinkData('Simulink Compile',...
    iMdl,'RapidAccelSim','MAT File Loading',false);

end


function simMetadataStruct=load_simMetadata_file(buildData,index)

    simMetadataFile=get_simMetadata_file(buildData.buildDir,buildData.tmpVarPrefix);
    simMetadataStruct=struct();
    loadSuccessful=true;
    try
        vars=load(simMetadataFile{index});
    catch E %#ok to ignore the error
        loadSuccessful=false;
    end

    if loadSuccessful==true
        simMetadataStruct=vars.SimMetadataStruct;
    end

end



function[logVars,youtData]=loc_get_yout_data(...
    logVars,buildData,varargin)
    numOutports=buildData.rootOutportsInfo.numOutports;
    if nargout>1

        nYoutVars=varargin{1};
        if((nYoutVars~=1)&&(nYoutVars~=numOutports))
            error(message('Simulink:tools:rapidAccelIncorrectOutputs',buildData.mdl));
        end
        youtData=cell(1,numOutports);
        for idx=1:numOutports
            outportName=[buildData.loggingPfx,'yout',num2str(idx)];
            if isfield(logVars,outportName)
                youtData{idx}=getfield(logVars,outportName);%#ok
                logVars=rmfield(logVars,outportName);
            else
                youtData{idx}=[];
            end
        end
    else
        for idx=1:numOutports
            outportName=[buildData.loggingPfx,'yout',num2str(idx)];
            if isfield(logVars,outportName)
                logVars=rmfield(logVars,outportName);
            end
        end
    end
end



function youtData=loc_edit_yout_data(youtData)







    if(isfield(youtData,'signals'))
        idx2=1;
        while idx2<=length(youtData.signals)
            if isfield(youtData.signals(idx2),'values')&&...
                isempty(youtData.signals(idx2).values)
                youtData.signals(idx2)=[];
                continue;
            end
            youtData.signals(idx2).label=slsvInternal('slsvEscapeServices','unescapeString',youtData.signals(idx2).label);
            youtData.signals(idx2).blockName=slsvInternal('slsvEscapeServices','unescapeString',youtData.signals(idx2).blockName);
            idx2=idx2+1;
        end
    end
end



function[logVars,varargout]=loc_load_return_values(...
    logVars,curRun,buildData,varargin)

    nArgs=buildData.numReturnValues;
    oneRun=(buildData.numRuns==1);

    if(nArgs<=0),return;end
    varargout=cell(1,nArgs);
    for i=1:nArgs
        varargout{i}=varargin{i};
    end

    aIdx=1;
    if(oneRun)
        if nArgs>0
            var=[buildData.loggingPfx,'tout'];
            if isfield(logVars,var)
                varargout{aIdx}=getfield(logVars,var);%#ok
                logVars=rmfield(logVars,var);
            end
            aIdx=aIdx+1;
            nArgs=nArgs-1;
        end
        if nArgs>0
            var=[buildData.loggingPfx,'xout'];
            if isfield(logVars,var)
                varargout{aIdx}=getfield(logVars,var);%#ok
                logVars=rmfield(logVars,var);
            end
            aIdx=aIdx+1;
            nArgs=nArgs-1;
        end
        if nArgs>0
            numOutports=buildData.rootOutportsInfo.numOutports;
            [logVars,youtData]=loc_get_yout_data(logVars,buildData,nArgs);
            if nArgs==1
                for idx=1:numOutports
                    varargout{aIdx}=[varargout{aIdx},youtData{idx}];
                end
            elseif(nArgs==buildData.rootOutportsInfo.numOutports)
                for idx=1:numOutports
                    varargout{aIdx}=[varargout{aIdx},youtData{idx}];
                    aIdx=aIdx+1;
                end
            end

        end
    else
        if nArgs>0
            var=[buildData.loggingPfx,'tout'];
            if isfield(logVars,var)
                varargout{aIdx}{curRun}=getfield(logVars,var);%#ok
                logVars=rmfield(logVars,var);
            end
            aIdx=aIdx+1;
            nArgs=nArgs-1;
        end
        if nArgs>0
            var=[buildData.loggingPfx,'xout'];
            if isfield(logVars,var)
                varargout{aIdx}{curRun}=getfield(logVars,var);%#ok
                logVars=rmfield(logVars,var);
            end
            aIdx=aIdx+1;
            nArgs=nArgs-1;
        end
        if nArgs>0
            numOutports=buildData.rootOutportsInfo.numOutports;
            [logVars,youtData]=loc_get_yout_data(logVars,buildData,nArgs);

            if nArgs==1
                for idx=1:numOutports
                    varargout{aIdx}{curRun}=[varargout{aIdx}{curRun},...
                    youtData{idx}];
                end
            elseif(nArgs==buildData.rootOutportsInfo.numOutports)
                for idx=1:numOutports
                    varargout{aIdx}{curRun}=[varargout{aIdx}{curRun},...
                    youtData{idx}];
                    aIdx=aIdx+1;
                end
            end
        end
    end



end



function loc_setup_sim_opts(buildData)



    mdl=buildData.mdl;
    simOpts=buildData.simOpts;

    cs=getActiveConfigSet(mdl);
    simOptsFields=fieldnames(buildData.simOpts);






    fldStr=findStr(simOptsFields,'ZeroCross');
    if(~isempty(fldStr)&&...
        ~isempty(buildData.simOpts.(fldStr)))
        v=simOpts.(fldStr);
        if isequal(v,'on')
            set_param(cs,'ZeroCrossControl','UseLocalSettings');
        else
            set_param(cs,'ZeroCrossControl','DisableAll');
        end
    end



    fldStr=findStr(simOptsFields,'InitialState');
    if(~isempty(fldStr)&&...
        ~isempty(buildData.simOpts.(fldStr)))
        v=simOpts.(fldStr);
        if~(ischar(v)||isnumeric(v))
            error(message('Simulink:tools:rapidAccelSimOptInvVal','InitialState'));
        end
        set_param(cs,'LoadInitialState','on');
        if isnumeric(v),v=mat2str(v);end
        set_param(cs,'InitialState',v);
    end
    simOptsSupport=loc_get_sim_opts_support_struct;
    simOptsSupFields=fieldnames(simOptsSupport);
    opts=fieldnames(simOpts);
    nopts=length(opts);
    for idx=1:nopts
        nam=opts{idx};
        supNam=findStr(simOptsSupFields,nam);
        val=simOpts.(nam);
        if~isempty(supNam)
            if isempty(val),continue;end
            sup=simOptsSupport.(supNam);
        else
            sup=-1;
        end
        switch(sup)
        case-1
            try
                if(~strcmpi(nam,'simulationmode'))
                    set_param(cs,nam,val);
                end
            catch E
                error(message('Simulink:tools:rapidAccelInvCmdlSimParam',...
                nam,E.identifier,E.message));
            end
        case 0
            warning(message('Simulink:tools:rapidAccelSimOptNotSupported',nam));
        case{1,3}
            if~(ischar(val)||isnumeric(val))
                error(message('Simulink:tools:rapidAccelSimOptInvVal',nam));
            end

            if isnumeric(val),val=mat2str(val);end
            set_param(cs,nam,val);
        otherwise
            continue;
        end
    end

end



function simOptsSupport=loc_get_sim_opts_support_struct


















    simOptsSupport.AbsTol=2;
    simOptsSupport.Debug=0;
    simOptsSupport.Decimation=2;
    simOptsSupport.DstWorkspace=0;
    simOptsSupport.FinalStateName=2;
    simOptsSupport.FixedStep=1;
    simOptsSupport.InitialState=5;
    simOptsSupport.InitialStep=2;
    simOptsSupport.MaxOrder=2;
    simOptsSupport.ODENIntegrationMethod=2;
    simOptsSupport.DaesscMode=2;
    simOptsSupport.ConsecutiveZCsStepRelTol=2;
    simOptsSupport.MaxConsecutiveZCs=2;
    simOptsSupport.ZCThreshold=2;
    simOptsSupport.SaveFormat=2;
    simOptsSupport.MaxDataPoints=2;
    simOptsSupport.MaxStep=2;
    simOptsSupport.MinStep=2;
    simOptsSupport.MaxConsecutiveMinStep=2;
    simOptsSupport.OutputPoints=2;
    simOptsSupport.OutputVariables=2;
    simOptsSupport.Refine=2;
    simOptsSupport.RelTol=2;
    simOptsSupport.Solver=3;
    simOptsSupport.SrcWorkspace=5;
    simOptsSupport.Trace=0;
    simOptsSupport.SignalLogging=5;
    simOptsSupport.SignalLoggingName=5;
    simOptsSupport.ExtrapolationOrder=2;
    simOptsSupport.NumberNewtonIterations=2;
    simOptsSupport.TimeOut=4;
    simOptsSupport.ZeroCross=5;
    simOptsSupport.ConcurrencyResolvingToFileSuffix=4;
    simOptsSupport.ReturnWorkspaceOutputs=4;
    simOptsSupport.RapidAcceleratorUpToDateCheck=4;
    simOptsSupport.RapidAcceleratorParameterSets=4;
    simOptsSupport.RapidAcceleratorMultiSim=4;
    simOptsSupport.CaptureErrors=4;
    simOptsSupport.SkipParameterUpdate=0;
    if slfeature('ParsimSupportFastRestartInNAR')==0
        simOptsSupport.FastRestart=0;
    else
        simOptsSupport.FastRestart=3;
    end
    simOptsSupport.ReturnDatasetRefInSimOut=4;
    simOptsSupport.AllowPause=0;

end



function loc_check_sim_opts_with_up_to_date_off(simOpts)



    simOptsSupport=loc_get_sim_opts_support_struct;

    opts=fieldnames(simOpts);
    nopts=length(opts);
    simOptsSupFields=fieldnames(simOptsSupport);
    for idx=1:nopts
        nam=opts{idx};
        supNam=findStr(simOptsSupFields,nam);
        if~isempty(supNam)
            val=simOpts.(nam);
            if isempty(val),continue;end
            sup=simOptsSupport.(supNam);
        else
            sup=-1;
        end

        switch(sup)
        case{-1,0}
            warning(message('Simulink:tools:rapidAccelSimOptNotSupported',nam));
        case{1,5}
            warning(message(...
            'Simulink:tools:rapidAccelSimOptNotSupportedWithoutUpdate',...
            nam));
        otherwise
            continue;
        end
    end

end



function numRootInportBlocks=loc_get_post_transform_port_info(buildData)


    numRootInportBlocks=buildData.rootInportsInfo.numExternalInputPorts;
    if buildData.rootInportsInfo.containsBusElPorts&&isfield(buildData.rootInportsInfo,'bepElementNames')
        numRootInportBlocks=numel(buildData.rootInportsInfo.bepElementNames);
    end
end



function extInputs=evaluate_external_input_string(buildData)


    if~isfield(buildData.rootInportsInfo,'numExternalInputPorts')||...
        ~isnumeric(buildData.rootInportsInfo.numExternalInputPorts)||...
        ~isscalar(buildData.rootInportsInfo.numExternalInputPorts)
        return
    end

    model=buildData.mdl;
    originalExtInputExpr=get_param(model,'ExternalInput');

    if strcmp(originalExtInputExpr,'[]')




        numRootInportBlocks=loc_get_post_transform_port_info(buildData);
        extInputs=cell(1,numRootInportBlocks);
    else
        cellifiedExtInputExpr=['{',originalExtInputExpr,'}'];



        [extInputs,extInputsExprExists]=...
        eval_string_with_workspace_resolution(...
        cellifiedExtInputExpr,...
        model,...
buildData...
        );

        if~extInputsExprExists
            error(message(...
            'Simulink:ConfigSet:ConfigSetEvalErr',...
            originalExtInputExpr,...
            'ExternalInput',...
            model));
        end
    end
end

function extInputs=get_ext_inputs(buildData)
    model=buildData.mdl;
    extInputs=buildData.extInputs;

    noExtInputsSpecified=isempty(extInputs)&&...
    (isequal(get_param(model,'LoadExternalInput'),'off')||...
    isempty(get_param(model,'ExternalInput')));

    if(noExtInputsSpecified)
        if buildData.opts.verbose
            fprintf('### %6.2fs :: In get_ext_inputs: no external inputs were specified \n',etime(clock,buildData.startTime));
        end
        numRootInportBlocks=loc_get_post_transform_port_info(buildData);
        extInputs=cell(1,numRootInportBlocks);
    else
        if isempty(extInputs)
            if buildData.opts.verbose
                fprintf('### %6.2fs :: In get_ext_inputs: obtaining external inputs by evaluating config set expression \n',etime(clock,buildData.startTime));
            end
            extInputs=evaluate_external_input_string(buildData);
        else
            if buildData.opts.verbose
                fprintf('### %6.2fs :: In get_ext_inputs: obtained external inputs from buildData \n',etime(clock,buildData.startTime));
            end
            extInputs={extInputs};
        end
    end
end

function setup_ext_inputs(buildData,varargin)








    if buildData.opts.verbose
        fprintf('### %6.2fs :: Calling setup_ext_inputs\n',etime(clock,buildData.startTime));
    end

    assert(nargin<=2);
    validateOnly=false;
    if nargin==2
        assert(islogical(varargin{1}));
        validateOnly=varargin{1};
    end
    iMdl=buildData.mdl;
    numRootInportBlocks=buildData.rootInportsInfo.numExternalInputPorts;
    if(numRootInportBlocks==0&&buildData.rootInportsInfo.numFcnCallTriggerPorts==0)
        if isequal(get_param(iMdl,'LoadExternalInput'),'on')

            ex=MSLException(message('Simulink:Logging:UTNoInputs'));
            throwAsCaller(ex);
        end

        return
    end

    extInputs=get_ext_inputs(buildData);

    if isequal(numel(extInputs),1)&&ischar(extInputs{1})




        if buildData.rootInportsInfo.containsBusElPorts
            msg=message('Simulink:SimInput:BusElementPortTimeExpression',...
            extInputs{1});
            throwAsCaller(MSLException(msg));
        else
            msg=message('Simulink:SimInput:RootInportTimeExpressionRapid',...
            extInputs{1});
            throwAsCaller(MSLException(msg));
        end
    end

    if iscell(extInputs)&&~isempty(extInputs)
        indicesOfEmptyInputs=find(cellfun(@isempty,...
        extInputs,'UniformOutput',true));
        if any(indicesOfEmptyInputs)








            extInputs(indicesOfEmptyInputs)=deal({[]});
        end
    end

    originalExtInputExpr=get_param(iMdl,'ExternalInput');
    cellifiedExtInputExpr=['{',originalExtInputExpr,'}'];

    if~isempty(extInputs)&&...
        (isa(extInputs{1},'Simulink.SimulationData.Dataset')||...
        isa(extInputs{1},'Simulink.SimulationData.DatasetRef'))
        loc_setup_ext_inputs_dataset(buildData,extInputs,false,validateOnly);
    else
        varNames=get_param(iMdl,'ExternalInput');
        if isequal(varNames,'[]')||isequal(get_param(buildData.mdl,'LoadExternalInput'),'off')
            varNames=repmat({'[]'},numel(extInputs),1);
        else
            varNames=builtin('_parse_top_level_expressions',varNames);
        end
        ds=Simulink.SimulationData.Dataset;
        containsLegacyLoggingFormat=false;

        for idx=1:numel(extInputs)
            if isa(extInputs{idx},'Simulink.ModelDataLogs')||...
                isa(extInputs{idx},'Simulink.SubsysDataLogs')||...
                isa(extInputs{idx},'Simulink.Timeseries')||...
                isa(extInputs{idx},'Simulink.TsArray')
                containsLegacyLoggingFormat=true;
                break;
            end
            ds=ds.addElementWithoutChecking(extInputs{idx},varNames{idx});
        end
        if containsLegacyLoggingFormat


            loc_setup_ext_inputs_non_dataset(...
            buildData,...
            extInputs,...
            cellifiedExtInputExpr,...
            validateOnly);
        else
            loc_setup_ext_inputs_dataset(buildData,{ds},true,validateOnly);
        end
    end

end



function loc_setup_ext_inputs_dataset(buildData,extInputs,isSynthesized,validateOnly)



    if buildData.opts.verbose
        fprintf('### %6.2fs :: Calling loc_setup_ext_inputs_dataset\n',etime(clock,buildData.startTime));
    end

    iMdl=buildData.mdl;

    if length(extInputs)~=1
        error(message(...
        'Simulink:tools:rapidAccelDatasetExtInputInvalidNumberOfExtInputs',...
iMdl...
        ));
    end

    if~isscalar(extInputs{1})
        error(message(...
        'Simulink:tools:rapidAccelDatasetExtInputNonScalarDataset',...
iMdl...
        ));
    end

    numElements=extInputs{1}.numElements;
    if isequal(numElements,0)&&isSynthesized
        error(message(...
        'Simulink:tools:rapidAccelUnableToLoadExtInputsWrongNumber',...
        iMdl,...
        numElements,...
        numel(buildData.rootInportsInfo.rootInports)...
        ));
    end

    extInputSettingsFile=get_ext_input_settings_file(buildData.buildDir);
    if buildData.opts.verbose
        fprintf('### %6.2fs :: get_ext_input_settings_file done \n',etime(clock,buildData.startTime));
    end
    if exist(extInputSettingsFile,'file')


        extInputSettings=load(extInputSettingsFile,'rootInportsCompiledInfo').rootInportsCompiledInfo;
        aobHierarchy=extInputSettings.aobHierarchy;
        leafSignalOffset=extInputSettings.leafSignalOffset;
        portBusTypes=extInputSettings.portBusTypes;
        msgPortIdxs=extInputSettings.msgPortIdxs;

        fileVars=who('-file',extInputSettingsFile);
        if any(ismember(fileVars,'fxpData'))
            fxpSettings=load(extInputSettingsFile,'fxpData').fxpData;
            fxpDiagOverflow=fxpSettings.fxpDiagOverflow;
            fxpDiagSaturation=fxpSettings.fxpDiagSaturation;
            fxpBlockPaths=fxpSettings.fxpBlockPaths;
        else
            fxpDiagOverflow=[];
            fxpDiagSaturation=[];
            fxpBlockPaths=[];
        end
    else
        aobHierarchy=[];
        leafSignalOffset=[];
        portBusTypes=[];
        fxpDiagOverflow=[];
        fxpDiagSaturation=[];
        fxpBlockPaths=[];
        msgPortIdxs=[];
    end
    [boundedInports,interpolation]=loc_retrieve_inport_interpolation_and_bounds(buildData);
    if boundedInports
        warning(message('Simulink:tools:rapidAccelInportBoundsNotHonoured',iMdl));
    end

    tempDs=extInputs{1};

    if(isa(tempDs,'Simulink.SimulationData.DatasetRef'))
        tempDs=Simulink.SimulationData.util.createSimulationDatastoresForDatasetRef(tempDs);
    end
    if buildData.opts.verbose
        fprintf('### %6.2fs :: starting Serializer\n',etime(clock,buildData.startTime));
    end
    if isSynthesized
        serializer=Simulink.SimulationData.SerializeInput.RtInpNonDatasetSerializer(...
        buildData,...
        iMdl,...
        tempDs,...
        aobHierarchy,...
        interpolation,...
        portBusTypes,...
        msgPortIdxs,...
        false,...
        buildData.rootInportsInfo...
        );
    else
        if buildData.opts.verbose
            fprintf('### %6.2fs :: calling RtInpDatasetSerializer\n',etime(clock,buildData.startTime));
        end
        serializer=Simulink.SimulationData.SerializeInput.RtInpDatasetSerializer(...
        buildData,...
        iMdl,...
        tempDs,...
        aobHierarchy,...
        interpolation,...
        portBusTypes,...
        msgPortIdxs,...
        false,...
        buildData.rootInportsInfo...
        );
    end

    if buildData.opts.verbose
        fprintf("### %6.2fs :: Done loading and constructing Simulink.SimulationData.SerializeInput.RtInpDatasetSerializer\n",...
        etime(clock,buildData.startTime));
    end

    try
        serializedDataset=serializer.serializeDataset();
    catch ME
        throwAsCaller(ME);
    end

    if buildData.opts.verbose
        fprintf('### %6.2fs :: done serializeDataset\n',...
        etime(clock,buildData.startTime));
    end

    serializedDataset=...
    Simulink.SimulationData.util.addLeafOffsetsToSerializedDataset(...
    serializedDataset,...
    aobHierarchy,...
leafSignalOffset...
    );






    isSingleStructAndNotFi=isequal(extInputs{1}.numElements,1)&&...
    isstruct(extInputs{1}{1})&&...
    isfield(extInputs{1}{1},'signals');
    if isSingleStructAndNotFi
        is2DSingleTimestep=false;
        timeField=extInputs{1}{1}.time;
        canBeSingleTimestep=isempty(timeField)||isscalar(timeField);
        for idx=1:numel(extInputs{1}{1}.signals)


            if canBeSingleTimestep
                sizeOfData=size(extInputs{1}{1}.signals(idx).values);
                is2DSingleTimestep=isequal(numel(sizeOfData),2)&&...
                isfield(extInputs{1}{1}.signals,'dimensions')&&...
                isequal(sizeOfData,extInputs{1}{1}.signals.dimensions);
            end

            isFiData=isa(extInputs{1}{1}.signals(idx).values,'embedded.fi');
            if isFiData||is2DSingleTimestep
                isSingleStructAndNotFi=false;
                break
            end
        end
    end

    if validateOnly
        return;
    end
    inpFile=get_inp_file(buildData.buildDir,buildData.tmpVarPrefix);
    if~isSingleStructAndNotFi

        externalInputIsInDatasetFormat=true;
        for j=1:length(buildData.tmpVarPrefix)
            save(...
            inpFile{j},...
            '-v7',...
            'externalInputIsInDatasetFormat',...
            'interpolation',...
            'serializedDataset',...
            'fxpDiagOverflow',...
            'fxpDiagSaturation',...
'fxpBlockPaths'...
            );
        end

    else











        extInpStruct=extInputs{1}{1};
        for idx=1:numel(extInpStruct.signals)
            if isobject(extInpStruct.signals(idx).values)
                if Simulink.data.isSupportedEnumObject(extInpStruct.signals(idx).values)
                    extInpStruct.signals(idx).values=...
                    int32(extInpStruct.signals(idx).values);
                end
            end
        end


        varNames=cell(1,3);
        externalInputIsInDatasetFormat=false;

        periodicFunctionCallInports=false(1,buildData.rootInportsInfo.numInports);
        varNames{1}='externalInputIsInDatasetFormat';
        varNames{2}='periodicFunctionCallInports';
        varNames{3}='extInp1';
        extInputs=cell2struct(...
        {...
        externalInputIsInDatasetFormat,...
        periodicFunctionCallInports,...
extInpStruct...
        },...
        varNames,...
2...
        );
        for j=1:length(buildData.tmpVarPrefix)
            save(inpFile{j},'-v7','-struct','extInputs');

        end
        if buildData.opts.verbose
            fprintf('### %6.2fs :: Done saving serialized data\n',...
            etime(clock,buildData.startTime));
        end
    end

end



function loc_setup_ext_inputs_non_dataset(buildData,extInputs,utStr,validateOnly)







    if buildData.opts.verbose
        fprintf('### %6.2fs :: Calling loc_setup_ext_inputs_non_dataset\n',etime(clock,buildData.startTime));
    end

    iMdl=buildData.mdl;
    numRootInportBlocks=buildData.rootInportsInfo.numInports;

    inportIsFunctionCall=cell(1,numRootInportBlocks);
    inportPeriodOffset=cell(1,numRootInportBlocks);
    inportBounded=zeros(1,numRootInportBlocks);
    noBoundRegex='^[ ]*\[[ ]*\][ ]*$';
    rootInportBlocks=buildData.rootInportsInfo.rootInports;
    for i=1:numRootInportBlocks
        inportIsFunctionCall{i}=strcmpi('on',...
        get_param(rootInportBlocks{i},...
        'OutputFunctionCall'));
        inportPeriodOffset{i}=...
        get_param(rootInportBlocks{i},'SampleTime');
        inportOutMin=get_param(rootInportBlocks{i},'OutMin');
        inportOutMax=get_param(rootInportBlocks{i},'OutMax');
        inportBounded(i)=isempty(regexp(inportOutMin,noBoundRegex,'ONCE'))||...
        isempty(regexp(inportOutMax,noBoundRegex,'ONCE'));
    end

    n=length(extInputs);
    if(n~=1&&n~=numRootInportBlocks)
        error(message(...
        'Simulink:tools:rapidAccelUnableToLoadExtInputsWrongNumber',...
        iMdl,...
        n,...
numRootInportBlocks...
        ));
    elseif(n==0)
        return;
    end

    if any(inportBounded)
        warning(message('Simulink:tools:rapidAccelInportBoundsNotHonoured',iMdl));
    end

    periodicFunctionCallInports=false(1,numRootInportBlocks);
    if(n==numRootInportBlocks)


        for i=1:numRootInportBlocks
            if(inportIsFunctionCall{i}&&isempty(extInputs{i}))

                period=-1;
                offset=0;


                if(~isempty(inportPeriodOffset{i}))
                    if~Simulink.isRaccelDeployed
                        po=slResolve(inportPeriodOffset{i},iMdl);
                    else
                        po=eval_string_with_workspace_resolution(...
                        inportPeriodOffset{i},...
                        mdl,...
buildData...
                        );
                    end
                    if(length(po)>1)
                        if(~isempty(po(1)))
                            period=po(1);
                        end
                        if(~isempty(po(2)))
                            offset=po(2);
                        end
                    else
                        if(~isempty(po(1)))
                            period=po(1);
                        end
                        offset=0;
                    end
                end


                if(period<=0)


                    periodicFunctionCallInports(i)=false;
                    continue;
                else
                    periodicFunctionCallInports(i)=true;
                end
















                [Tstart,~]=get_start_stop_times(buildData);






                if(Tstart>=offset)



                    nperiod=ceil((Tstart-offset)/period);


                    firstHit=offset+nperiod*period;
                else


                    nperiod=floor((offset-Tstart)/period);


                    firstHit=offset-nperiod*period;
                end



                extInputs{i}=[period;firstHit];
            end
        end
    end









    varNames=cell(1,n+2);
    externalInputIsInDatasetFormat=false;
    varNames{1}='externalInputIsInDatasetFormat';
    varNames{2}='periodicFunctionCallInports';
    for i=1:n
        varNames{i+3}=['extInp',num2str(i)];
        extInputs{i}=...
        loc_check_and_fix_ext_inp(extInputs{i},utStr,iMdl);
    end


    if validateOnly
        return;
    end


    inpFile=get_inp_file(buildData.buildDir,buildData.tmpVarPrefix);

    extInputs=cell2struct(...
    {...
    externalInputIsInDatasetFormat,...
    periodicFunctionCallInports,...
    extInputs{:}...
    },...
    varNames,...
2...
    );%#ok used in save
    for j=1:length(buildData.tmpVarPrefix)


        save(inpFile{j},'-v7','-struct','extInputs');

    end
end



function extInputs=loc_check_and_fix_ext_inp(extInputs,~,iMdl)


    if(isempty(extInputs)),return;end

    if(~(isa(extInputs,'double')||isa(extInputs,'struct'))||...
        Simulink.SimulationData.utValidSignalOrCompositeData(extInputs))
        error(message('Simulink:SimInput:LoadingInvalidElementContents'));
    end

    if(isstruct(extInputs))
        [oBool,cName,extInputs]=...
        loc_check_and_fix_ext_inp_struct(extInputs);
        if oBool
            error(message(...
            'Simulink:tools:rapidAccelMCOSObjExtInputsNotSupported',...
            iMdl,cName));
        end
    else
        [oBool,cName,extInputs]=...
        loc_check_and_fix_ext_inp_array(extInputs);
        if oBool
            error(message(...
            'Simulink:tools:rapidAccelMCOSObjExtInputsNotSupported',...
            iMdl,cName));
        end
    end
end



function[oBool,cName,data]=loc_check_and_fix_ext_inp_array(data)
    cName='';
    oBool=false;
    if isobject(data)
        if Simulink.data.isSupportedEnumObject(data)
            data=int32(data);
        else
            oBool=true;
            cName=class(data);
        end
    elseif isnumeric(data)
        if any(isnan(data(:)))||any(isinf(data(:)))
            error(message('Simulink:SimInput:MdlUTNotSupportedFormat'));
        end
    end
end


function[oBool,cName,data]=loc_check_and_fix_ext_inp_struct(data)
    for i=1:length(data.signals)
        [oBool,cName,data.signals(i).values]=...
        loc_check_and_fix_ext_inp_array(data.signals(i).values);
        if(oBool),return;end
    end
end



function loc_create_build_dir(mdl,buildDir,okToPushNags)

    if Simulink.isRaccelDeploymentBuild



        folders=Simulink.filegen.internal.FolderConfiguration(mdl,true,false);
    else
        folders=Simulink.filegen.internal.FolderConfiguration(mdl);
    end

    rtwBuildDir=folders.RapidAccelerator.absolutePath('ModelCode');

    if~isequal(rtwBuildDir,buildDir)
        error(message('Simulink:utility:inconsistentBuildDir',rtwBuildDir,buildDir));
    end


    rtw_checkdir;


    coder.internal.folders.MarkerFile.checkFolderConfiguration(folders,true,okToPushNags);

    [stat,msg,~]=mkdir(buildDir);
    if stat==0
        error(message('Simulink:utility:errorCreatingDir',...
        buildDir,msg));
    end

end



function oVal=get_opt(iOpt,iDef)
    try
        env_name=['RAPID_ACCELERATOR_OPTIONS_',upper(iOpt)];
        env_value=getenv(env_name);
        if(~isempty(env_value))

            oVal=str2double(env_value);
        else
            oVal=evalin('base',['rapidAcceleratorOptions.',iOpt]);
        end
    catch E %#ok
        oVal=iDef;
    end
end




function raccel_debug_rebuild(buildData)


    if Simulink.isRaccelDeployed
        return;
    end
    disp(['### Rebuilding the rapid accelerator target for debug for: ',buildData.mdl]);


    coder.make.internal.reCompileForDebug(buildData.buildDir);

    disp(['### Successfully built the rapid accelerator target for debug for: ',buildData.mdl]);
end



function runCmd=loc_raccel_debug(buildData,interactive)

    exeName=sl('rapid_accel_target_utils','get_exe_name',...
    buildData.buildDir,buildData.mdl);


    if buildData.opts.debug
        raccel_debug_rebuild(buildData)
    end

    prmFile=sl('rapid_accel_target_utils','get_prm_file',...
    buildData.buildDir,buildData.tmpVarPrefix);
    inpFile=sl('rapid_accel_target_utils','get_inp_file',...
    buildData.buildDir,buildData.tmpVarPrefix);
    slvrFile=sl('rapid_accel_target_utils','get_slvr_file',...
    buildData.buildDir,buildData.tmpVarPrefix);
    simMetadataFile=sl('rapid_accel_target_utils','get_simMetadata_file',...
    buildData.buildDir,buildData.tmpVarPrefix);%#ok<NASGU>
    siglogselectorFile=...
    sl('rapid_accel_target_utils','get_siglogselector_file',...
    buildData.buildDir,buildData.tmpVarPrefix);

    sFcnInfoFile=sl('rapid_accel_target_utils','get_sfcn_info_file',...
    buildData.buildDir,buildData.mdl);

    loc_update_sfcn_info_file(buildData);

    simOptsFields=[];
    if~isempty(buildData.simOpts)
        simOptsFields=fieldnames(buildData.simOpts);
    end

    tmpVarPrefix{1}='';
    toutFile=sl('rapid_accel_target_utils','get_out_file',...
    buildData.buildDir,tmpVarPrefix);
    tsigstreamFile=sl('rapid_accel_target_utils','get_sigstream_file',...
    buildData.buildDir,tmpVarPrefix);
    tsiglogselectorFile=...
    sl('rapid_accel_target_utils','get_siglogselector_file',...
    buildData.buildDir,tmpVarPrefix);
    tprmFile=sl('rapid_accel_target_utils','get_prm_file',...
    buildData.buildDir,tmpVarPrefix);
    tinpFile=sl('rapid_accel_target_utils','get_inp_file',...
    buildData.buildDir,tmpVarPrefix);
    tslvrFile=sl('rapid_accel_target_utils','get_slvr_file',...
    buildData.buildDir,tmpVarPrefix);
    tsimMetadataFile=sl('rapid_accel_target_utils','get_simMetadata_file',...
    buildData.buildDir,tmpVarPrefix);
    texeActiveToken=loc_get_exe_active_token(tmpVarPrefix);
    terrorFile=sl('rapid_accel_target_utils','get_error_file',...
    tmpVarPrefix);

    disp(['Executable Name: ',exeName]);
    if buildData.opts.profile
        debugCmd='amplxe-cl -collect advanced-hotspots';
    else
        if(ismac())
            dyldLibPath=getenv('DYLD_LIBRARY_PATH');
            disp(['DYLD_LIBRARY_PATH: ',dyldLibPath]);
            debugCmd='xcrun lldb --';
        elseif(isunix())
            ldLibPath=getenv('LD_LIBRARY_PATH');
            disp(['LD_LIBRARY_PATH: ',ldLibPath]);
            debugCmd='gdb --annotate=3 --args';
        elseif(ispc())
            vs90comntools=getenv('VS90COMNTOOLS');
            vs100comntools=getenv('VS100COMNTOOLS');
            vs110comntools=getenv('VS110COMNTOOLS');
            vs120comntools=getenv('VS120COMNTOOLS');
            vs140comntools=getenv('VS140COMNTOOLS');
            vs150comntools=getenv('VS150PROCOMNTOOLS');
            if(~isempty(vs150comntools))

                debugCmd=['"',vs150comntools,'\..\IDE\devenv" /debugexe '];
            elseif(~isempty(vs140comntools))

                debugCmd=['"',vs140comntools,'\..\IDE\devenv" /debugexe '];
            elseif(~isempty(vs120comntools))

                debugCmd=['"',vs120comntools,'\..\IDE\devenv" /debugexe '];
            elseif(~isempty(vs110comntools))

                debugCmd=['"',vs110comntools,'\..\IDE\devenv" /debugexe '];
            elseif(~isempty(vs100comntools))

                debugCmd=['"',vs100comntools,'\..\IDE\devenv" /debugexe '];
            elseif(~isempty(vs90comntools))

                debugCmd=['"',vs90comntools,'..\IDE\devenv" /debugexe '];
            else


                buildData.opts.debug=1;
                debugCmd='devenv /debugexe';
            end
        else
            debugCmd='<debugger>';
        end
    end

    runCmd=[exeName,...
    ' -server_info_file ',quote(texeActiveToken{1}),...
    ' -error_file ',quote(terrorFile{1}),...
    ' -o ',quote(toutFile{1})];

    runCmd=[runCmd,' -R ',quote(Simulink.sdi.getSource())];
    if slfeature('JetstreamRapidAccelStreaming')
        runCmd=[runCmd,' -live_stream'];
    end

    runCmd=[runCmd,' -l ',quote(tsigstreamFile{1})];

    copyfile(siglogselectorFile{1},tsiglogselectorFile{1});
    runCmd=[runCmd,' -e ',quote(tsiglogselectorFile{1})];

    if exist(sFcnInfoFile,'file')
        runCmd=[runCmd,' -d ',quote(sFcnInfoFile)];
    end



    if buildData.loadFromBuildRtpFile
        paramFile=get_build_prm_file(buildData.buildDir);
        runCmd=[runCmd,' -p ',quote(paramFile)];
    else
        if exist(prmFile{1},'file')
            copyfile(prmFile{1},tprmFile{1});
            runCmd=[runCmd,' -p ',quote(tprmFile{1})];
        end
    end

    if exist(slvrFile{1},'file')
        copyfile(slvrFile{1},tslvrFile{1});
        runCmd=[runCmd,' -S ',quote(tslvrFile{1})];
    end

    if exist(inpFile{1},'file')
        copyfile(inpFile{1},tinpFile{1});
        runCmd=[runCmd,' -i ',quote(tinpFile{1})];
    end



    runCmd=[runCmd,' -m ',quote(tsimMetadataFile{1})];

    fldStr=loc_find_str(simOptsFields,'TimeOut');
    if~isempty(fldStr)
        timeOut=buildData.simOpts.(fldStr);
        if~isempty(timeOut)
            runCmd=[runCmd,' -L ',num2str(timeOut)];
        end
    end

    if buildData.runningInParallel
        runCmd=[runCmd,' -P '];
    end

    if ischar(buildData.toFileSuffix)
        runCmd=[runCmd,' -T ',quote(buildData.toFileSuffix)];
    end

    if(Simulink.isRaccelDeployed)
        runCmd=[runCmd,' -D '];
    end



    if(buildData.opts.debug==3)
        runCmd=get_run_cmd(buildData);


        if interactive
            runCmd=[runCmd{1},' -port 0 -w'];
        end
    end

    if slfeature('MLSysBlockRaccelReval')==1||...
        slfeature('FMUBlockRaccelReval')==1
        runCmd=[runCmd,' -reval_host_to_target ',num2str(buildData.qidHost2target)];
        runCmd=[runCmd,' -reval_target_to_host ',num2str(buildData.qidTarget2host)];
        runCmd=[runCmd,' -reval_service_port ',num2str(buildData.dashServicePort)];
    end

    disp(['Target command line: ',runCmd]);
    disp(['Debugger command line: ',debugCmd,' ',runCmd]);

    if(buildData.opts.debug==2||buildData.opts.debug==3)

        if(ismac()||ispc())
            sysCmd=[debugCmd,' ',runCmd];
        else
            runCmd2=regexprep(runCmd,'"','');
            sysCmd=['emacs -l ',...
            [toolboxdir('simulink_standalone'),'/shared/rapid_accel_target_utils_gdb.el'],...
            ' ''--eval=(mw-rapid-accel-debug "',runCmd2,'")'''];
        end
        if(buildData.opts.debug==2||~interactive)
            system(sysCmd);
        else
            system([sysCmd,' &']);
            fprintf('### You can now configure your breakpoints and start the process.\n');
            fprintf('### Make sure the target is waiting for a connection or finished before continuing.\n');
        end
        keyboard;
    elseif(buildData.opts.profile)
        fprintf('### You can now profile the target in vtune using the above command line\n');
        keyboard;
    elseif(buildData.opts.debug)
        use_debug_token=false;
        if~ismac()
            reply=input('### Do you want the raccel executable to wait for you to attach it to Visual Studio / gdb? y/n [n]: ','s');
            if isequal(lower(reply),'y')
                use_debug_token=true;
            end
        end
        if use_debug_token
            debugToken=[exeName,'.debug_token'];
            system(['touch ',debugToken]);
            disp('=========================== DEBUGGING INFORMATION ==================================');
            fprintf("### Rapid Accelerator Executable: %s\n",exeName);
            fprintf('### Created debug token file    : %s\n',debugToken);
            fprintf('### The raccel executable will pause until you delete it.\n');
            fprintf('### This is a good time to attach gdb to this MATLAB process (PID=%d).\n',feature('getpid'));
            disp('================ INSTRUCTIONS FOR DEBUGGING ========================================');
            disp('The rapid accelerator process will be initiated in the next phase.');
            disp('Perform the following steps to debug it in Visual Studio or gdb.');
            disp('====================================================================================');
            fprintf("1) Attach Visual Studio or gdb to the rapid accelerator process.\n");
            fprintf("2) Set the necessary breakpoints in Visual Studio or gdb.\n");
            fprintf("3) Delete the debug token file mentioned in the debugging information given above.\n");
            disp('====================================================================================');
            input('### Press any key when you are ready to continue ...','s');
            fprintf('### Launching rapid accelerator process.\n');
        else
            fprintf('### You can now run the executable using the above debugger command line.\n');
            fprintf('### When you are done, use "dbcont" to continue.\n');
            keyboard;
        end
    end

end



function exeActiveToken=loc_get_exe_active_token(tmpVarPrefix)

    nTmpVar=length(tmpVarPrefix);
    exeActiveToken=cell(1,nTmpVar);
    for i=1:nTmpVar
        exeActiveToken{i}=[tempdir,'tp',tmpVarPrefix{i},'.info'];
    end
end



function strout=loc_find_str(cellAry,strin)
    for i=1:length(cellAry)
        if strcmpi(cellAry{i},strin)
            strout=cellAry{i};
            return;
        end
    end
    strout='';
    return
end



function[fileReady,portCell,pidCell]=loc_read_server_info(buildData,filename)
    fileReady=false;
    portCell={};
    pidCell={};

    if exist(filename,'file')
        serverInfoFileContents=fileread(filename);
        if buildData.opts.verbose
            fprintf('### Server info file %s found...\n',filename);
            fprintf('### Contents of server info file %s:\n%s\n',filename,serverInfoFileContents);
        end
        portCell=regexp(serverInfoFileContents,...
        'Server Port Number: (\d*)','tokens','once');
        pidCell=regexp(serverInfoFileContents,...
        'Server PID: (\d*)','tokens','once');
        fileReady=~isempty(portCell)&&~isempty(pidCell);
    end
end



function[fileReady,portCell]=loc_read_tgtconn_server_info(filename)
    fileReady=false;
    portCell={};
    if exist(filename,'file')
        serverInfoFileContents=fileread(filename);
        portCell=regexp(serverInfoFileContents,...
        'Server Port Number: (\d*)','tokens','once');
        fileReady=~isempty(portCell);
    end
end



function runTimeParameters=loc_edit_rtp(runTimeParameters,mdl,buildDir)









    if isempty(runTimeParameters)
        return
    end

    parameterList=runTimeParameters.parameters;

    structTransitions=runTimeParameters.globalParameterInfo.structTransitionInfo;
    numStructTransitions=length(structTransitions);

    if numStructTransitions>0
        hostBasedCAPIPath=loc_construct_capi_path(mdl,buildDir);

        parameterList=get_struct_param_capi_index(...
        parameterList,...
        structTransitions,...
        mdl,...
hostBasedCAPIPath...
        );

        for i=1:numStructTransitions
            parameterList(structTransitions(i)).values=...
            simulink.rapidaccelerator.internal.convertStructFieldsToTargetFormat(...
            parameterList(structTransitions(i)).values...
            );
        end
    end

    fixPtTransitions=runTimeParameters.globalParameterInfo.fixedPointTransitionInfo;
    numFixPtTransitions=length(fixPtTransitions);

    if numFixPtTransitions>0
        for i=1:numFixPtTransitions

            transitionInfo=fixPtTransitions(i);
            numParamsInThisTransition=length(parameterList(transitionInfo.transitionIndex).values);
            storedIntegerValues=[];

            if iscell(parameterList(transitionInfo.transitionIndex).values)
                for j=1:numParamsInThisTransition

                    prmValue=parameterList(transitionInfo.transitionIndex).values{j};

                    prmIsComplex=~isreal(prmValue);

                    prmValue=prmValue.interleavedsimulinkarray();
                    prmValue=prmValue(:).';









                    if prmIsComplex
                        prmValue=complex(prmValue);
                    end

                    storedIntegerValues=cat(2,storedIntegerValues,prmValue);
                end
                parameterList(transitionInfo.transitionIndex).values=storedIntegerValues;
            end
        end
    end

    runTimeParameters.parameters=parameterList;
end


function hostBasedCAPIPath=loc_construct_capi_path(mdlName,buildDir)
    folder=fullfile(buildDir,'tmwinternal');

    filename=[mdlName,'_capi_host.',mexext];
    hostBasedCAPIPath=fullfile(folder,filename);
end




function set_fxpBlockProps(buildData,fxpBlockPaths,fxpDiagOverflow,fxpDiagSaturation)
    extInputSettingsFile=get_ext_input_settings_file(buildData.buildDir);
    fxpData.fxpBlockPaths=fxpBlockPaths;
    fxpData.fxpDiagOverflow=fxpDiagOverflow;
    fxpData.fxpDiagSaturation=fxpDiagSaturation;
    save(extInputSettingsFile,'-append','fxpData');
end



function retrieve_aob_hierarchy(buildData,blockHandles)
    model=buildData.mdl;


    [aobHierarchy,leafSignalOffset,portBusTypes,msgPortIdxs]=...
    Simulink.SimulationData.util.retrieveAoBHierarchy(model,blockHandles,[]);
    rootInportsCompiledInfo.aobHierarchy=aobHierarchy;
    rootInportsCompiledInfo.leafSignalOffset=leafSignalOffset;
    rootInportsCompiledInfo.portBusTypes=portBusTypes;
    rootInportsCompiledInfo.msgPortIdxs=msgPortIdxs;


    [rootInportsInfo.numExternalInputPorts,...
    rootInportsInfo.rootInports,rootInportsInfo.numInports,...
    rootInportsInfo.enablePort,rootInportsInfo.numEnablePorts,rootInportsInfo.enablePortIdx,...
    rootInportsInfo.triggerPort,rootInportsInfo.numTriggerPorts,rootInportsInfo.triggerPortIdx,...
    rootInportsInfo.numFcnCallTriggerPorts,rootInportsInfo.containsBusElPorts]=...
    Simulink.SimulationData.util.countRootInportsByType(model);
    modelHandle=get_param(model,'Handle');
    rootInportsInfo.bepElementNames=Simulink.internal.CompositePorts.TreeNode.getLeafDotStrsForDataInputInterface(...
    modelHandle);


    buildData.rootInportsInfo=rootInportsInfo;
    set_param(model,'RapidAcceleratorBuildData',buildData);


    extInputSettingsFile=get_ext_input_settings_file(buildData.buildDir);
    save(extInputSettingsFile,'-v7','rootInportsInfo','rootInportsCompiledInfo');
end



function reval_instantiate_obj(varName,className)
    assignin('base',varName,evalin('base',className));
end



function reval_obj_setup(varName)
    evalin('base',[varName,'.setup(0)']);
end



function y=reval_obj_step(varName,u)
    y=step(evalin('base',varName),u);
end



function reval_destroy_obj(varName)
    evalin('base',['clear(''',varName,''')']);
end



function[boundedInports,interpolation]=loc_retrieve_inport_interpolation_and_bounds(buildData)
    numExternalInputPorts=buildData.rootInportsInfo.numExternalInputPorts;
    rootInports=buildData.rootInportsInfo.rootInports;
    numInports=buildData.rootInportsInfo.numInports;
    enablePort=buildData.rootInportsInfo.enablePort;
    numEnablePorts=buildData.rootInportsInfo.numEnablePorts;
    triggerPort=buildData.rootInportsInfo.triggerPort;
    numTriggerPorts=buildData.rootInportsInfo.numTriggerPorts;

    interpolation=zeros(1,numExternalInputPorts);
    inportBounded=zeros(1,numExternalInputPorts);
    noBoundRegex='^[ ]*\[[ ]*\][ ]*$';

    for rootInportIdx=1:numInports
        interpolation(rootInportIdx)=...
        strcmp(...
        get_param(rootInports{rootInportIdx},'Interpolate'),...
'on'...
        );
        inportOutMin=get_param(rootInports{rootInportIdx},'OutMin');
        inportOutMax=get_param(rootInports{rootInportIdx},'OutMax');
        inportBounded(rootInportIdx)=isempty(regexp(inportOutMin,noBoundRegex,'ONCE'))||...
        isempty(regexp(inportOutMax,noBoundRegex,'ONCE'));
    end

    if numEnablePorts==1
        interpolation(numInports+1)=...
        strcmp(...
        get_param(enablePort{1},'Interpolate'),...
'on'...
        );
        inportOutMin=get_param(enablePort,'OutMin');
        inportOutMax=get_param(enablePort,'OutMax');
        inportBounded(numInports+1)=...
        isempty(regexp(inportOutMin,noBoundRegex,'ONCE'))||...
        isempty(regexp(inportOutMax,noBoundRegex,'ONCE'));

    end

    if numTriggerPorts==1
        interpolation(numInports+numEnablePorts+1)=...
        strcmp(...
        get_param(triggerPort{1},'Interpolate'),...
'on'...
        );
        inportOutMin=get_param(triggerPort,'OutMin');
        inportOutMax=get_param(triggerPort,'OutMax');
        inportBounded(numInports+numEnablePorts+1)=...
        isempty(regexp(inportOutMin,noBoundRegex,'ONCE'))||...
        isempty(regexp(inportOutMax,noBoundRegex,'ONCE'));
    end
    boundedInports=any(inportBounded);
end

function elem=loc_generate_inactive_outport_element_struct(outportPath)
    elem.ElementType='signal';
    elem.Name='';
    elem.PropagatedName='';



    if(~Simulink.isRaccelDeployed)

        try
            portHdls=get_param(outportPath,'PortHandles');
            hLine=get(portHdls.Inport,'Line');
            if ishandle(hLine)
                srcOutportHdl=get(hLine,'SrcPortHandle');
                if ishandle(srcOutportHdl)
                    elem.Name=get(srcOutportHdl,'Name');
                    if isequal(get(srcOutportHdl,'ShowPropagatedSignals'),'on')
                        elem.PropagatedName=get(srcOutportHdl,'PropagatedSignals');
                    end
                end
            end
        catch me %#ok<NASGU>


        end
    end
    elem.BlockPath=outportPath;
    elem.PortType='inport';
    elem.PortIndex=1;
    elem.Values.LeafMarker=...
    Simulink.SimulationData.Storage.DatasetStorage.LeafMarkerValue;
    elem.Values.ElementType='timeseries';
    elem.Values.IsEmpty=true;
end

function ret=locGenerateOutportData(outportList)
    ret=cell(size(outportList));
    for idx=1:length(outportList)
        ret{idx}=loc_generate_inactive_outport_element_struct(outportList{idx});
    end
end

function savenameMap=loc_check_logging_save_name(inName,isSingle,inType,savenameMap)
    savename=strtrim(inName);
    if isSingle
        if~isvarname(savename)
            error(message('Simulink:Logging:InvDataLogSaveName',message(inType).getString));
        end
        if savenameMap.isKey(savename)
            error(message('Simulink:Logging:DupDataLogVarName2',...
            savename,message(inType).getString,savenameMap(savename)));
        end
        savenameMap(savename)=message(inType).getString;
    else
        savenames=strsplit(savename,',');
        for ni=1:length(savenames)
            savenameMap=loc_check_logging_save_name(savenames{ni},true,inType,savenameMap);
        end
    end
end

function loggedVars=loc_get_list_of_all_logged_vars(mdlName,mdlLevelLoggingData,logVars)
    loggedVars={};

    if strcmpi(get_param(mdlName,'SaveTime'),'on')&&~isempty(mdlLevelLoggingData.TimeSaveName)
        loggedVars{end+1}=mdlLevelLoggingData.TimeSaveName;
    end

    if strcmpi(get_param(mdlName,'SaveState'),'on')&&~isempty(mdlLevelLoggingData.StateSaveName)
        loggedVars{end+1}=mdlLevelLoggingData.StateSaveName;
    end

    if strcmpi(get_param(mdlName,'SaveOutput'),'on')&&~isempty(mdlLevelLoggingData.OutputSaveName)...
        &&~isempty(find_system(mdlName,'SearchDepth',1,'BlockType','Outport'))
        loggedVars{end+1}=mdlLevelLoggingData.OutputSaveName;
    end

    if strcmpi(get_param(mdlName,'SaveFinalState'),'on')&&~isempty(mdlLevelLoggingData.FinalStateName)
        loggedVars{end+1}=mdlLevelLoggingData.FinalStateName;
    end

    if strcmpi(get_param(mdlName,'SignalLogging'),'on')&&~isempty(mdlLevelLoggingData.SignalLoggingName)
        loggedVars{end+1}=mdlLevelLoggingData.SignalLoggingName;
    end

    loggedVars=[loggedVars,fieldnames(logVars).'];

    loggedVars=unique(loggedVars);
end

function loc_update_sfcn_info_file(buildData)
    sFcnInfoFile=get_sfcn_info_file(buildData.buildDir,buildData.mdl);

    try
        fileContents=load(sFcnInfoFile);
    catch E
        if strcmp(E.identifier,'MATLAB:load:couldNotReadFile')
            return
        end
    end

    assert(isfield(fileContents,'sFcnInfo'));
    sFcnInfo=fileContents.sFcnInfo;
    assert(isfield(sFcnInfo,'mexPath')&&isfield(sFcnInfo,'sFcnName'));

    anyChanges=false;
    for i=1:length(sFcnInfo)

        if~sFcnInfo(i).willBeDynamicallyLoaded
            continue;
        end

        currentPath=which(sFcnInfo(i).sFcnName);
        if isempty(currentPath)
            error(message(...
            'Simulink:tools:rapidAccelSFcnMexFileNotFoundDuringUTDCOffSim',...
            sFcnInfo(i).sFcnName,buildData.mdl));
        end


        if~isequal(currentPath,sFcnInfo(i).mexPath)
            sFcnInfo(i).mexPath=currentPath;
            anyChanges=true;
        end

        if buildData.opts.verbose
            fprintf('### %6.2fs :: Finalized S-Function path: %s\n',...
            etime(clock,buildData.startTime),...
            sFcnInfo(i).mexPath);
        end
    end

    if anyChanges
        fileContents.sFcnInfo=sFcnInfo;
        save(sFcnInfoFile,'-v7','-struct','fileContents');
    end
end

function loc_PerfToolsTracerLogSimulinkData(logtype,mdlName,point1,point2,someboolflag)
    if slfeature('RapidAcceleratorLightweightParallelSimulation')==0||...
        ~Simulink.isRaccelDeployed
        PerfTools.Tracer.logSimulinkData(logtype,mdlName,point1,point2,someboolflag);
    end
end

function simOutStruct=add_datasetref_to_simoutstruct(loggingData,filePath,simOutStruct)
    if strcmpi(loggingData.SaveFormat,'Dataset')||loggingData.isOriginalFormatDataset
        varNames=Simulink.SimulationData.DatasetRef.getDatasetVariableNames(filePath);

        if loggingData.SaveFinalState&&...
            ~loggingData.SaveCompleteFinalSimState
            name=loggingData.FinalStateName;
            if any(find(cellfun(@(x)(strcmp(x,name)),varNames)))
                if isempty(simOutStruct)
                    simOutStruct=struct(name,Simulink.SimulationData.DatasetRef(filePath,name));
                else
                    simOutStruct.(name)=...
                    Simulink.SimulationData.DatasetRef(filePath,name);
                end
            end
        end


        if loggingData.SignalLogging
            name=loggingData.SignalLoggingName;
            if any(find(cellfun(@(x)(strcmp(x,name)),varNames)))
                if isempty(simOutStruct)
                    simOutStruct=struct(name,Simulink.SimulationData.DatasetRef(filePath,name));
                else
                    simOutStruct.(name)=...
                    Simulink.SimulationData.DatasetRef(filePath,name);
                end
            end
        end


        if loggingData.SaveOutput
            name=loggingData.OutputSaveName;
            if any(find(cellfun(@(x)(strcmp(x,name)),varNames)))
                if isempty(simOutStruct)
                    simOutStruct=struct(name,Simulink.SimulationData.DatasetRef(filePath,name));
                else
                    simOutStruct.(name)=...
                    Simulink.SimulationData.DatasetRef(filePath,name);
                end
            end
        end
    end
end

function loc_add_sfunction_parameter_info_to_sfcn_info_file(mdl,buildDir,sFcnParameterInfo)
    sFcnInfoFile=get_sfcn_info_file(buildDir,mdl);

    try
        fileContents=load(sFcnInfoFile);
    catch E
        if strcmp(E.identifier,'MATLAB:load:couldNotReadFile')
            return
        end
    end

    assert(isfield(fileContents,'sFcnInfo'));
    sFcnInfo=fileContents.sFcnInfo;
    assert(isfield(sFcnInfo,'mexPath')&&isfield(sFcnInfo,'sFcnName'));

    for i=1:length(sFcnParameterInfo)
        blockSID=sFcnParameterInfo.blockSID;
        for j=1:length(sFcnInfo)
            if isequal(blockSID,sFcnInfo.blockSID)
                sFcnInfo(j).('stringParameterFlags')=...
                sFcnParameterInfo(i).stringParameterFlags;

                break;
            end
        end
    end

    fileContents.sFcnInfo=sFcnInfo;
    save(sFcnInfoFile,'-v7','-struct','fileContents');
end

function diaglogdb_ptr=loc_init_diagdb(buildData)

    slsvInternal('slsvDiagnosticLoggerDB','sethome',buildData.buildDir);
    diaglogdb_ptr=...
    slsvInternal('slsvDiagnosticLoggerDB','init',buildData.diaglogdb_sid);
end

function dataLoggingOverrideMcos=loc_dataLoggingOverride_check_signals(dataLoggingOverrideMcos,mdl)
    [signals,bInvalidSignals]=...
    dataLoggingOverrideMcos.checkForDuplicates(...
    dataLoggingOverrideMcos.Signals,...
'remove'...
    );

    sfSigToRemove=[];
    for idx=1:length(signals)
        if~isempty(signals(idx).BlockPath.SubPath)
            sfSigToRemove(end+1)=idx;%#ok<AGROW>
        end
    end
    if(~isempty(sfSigToRemove))
        warning(message('Simulink:Logging:SubsetOfSiglogRaccelIsNotSupported'));
        signals(sfSigToRemove)=[];
    end

    dataLoggingOverrideMcos.Signals=signals;
    if bInvalidSignals
        warning(message(...
        'Simulink:Logging:MdlLogInfoDupSignalInRapidAccel',...
mdl...
        ));
    end
end


function outfilename=makeSureIsDotMat(filename)
    if(length(filename)<=3)
        appendExt=true;
    else
        appendExt=~strcmpi(filename(end-3:end),'.mat');
    end
    if(appendExt)
        outfilename=strcat(filename,'.mat');
    else
        outfilename=filename;
    end
end

function close_models(iMdls)
    if~Simulink.isRaccelDeployed
        nMdls=length(iMdls);
        for i=1:nMdls
            close_system(iMdls{i},0);
        end
    end
end







function computedMaxNumThreads=loc_get_ForEach_parallel_execution_max_num_threads(mdl)
    computedMaxNumThreads=min([get_param(mdl,'ParallelExecutionNumThreads'),...
    feature('numcores'),...
    maxNumCompThreads]);
end



function youtLogData=reshapeOutputIfNecessary(youtLogData)




    sizei=size(youtLogData);
    if(length(sizei)>2)
        if(any(sizei(1:end-1)>1))
            error(message('Simulink:tools:rapidAccelOutportInvalidArrayDataLogging'));
        end
        youtLogData=reshape(youtLogData,...
        [sizei(end),1]);
    end
end



function buildData=setup_reval_service(buildData)






    revalServiceGuardCondition=isempty(buildData.revalHost)...
    &&isempty(buildData.dashServicePort)...
    &&isempty(buildData.qidHost2target)...
    &&isempty(buildData.qidTarget2host);

    assert(revalServiceGuardCondition);

    if slfeature('MLSysBlockRaccelReval')==1||...
        slfeature('FMUBlockRaccelReval')==1

        buildData.revalHost=reval.Host;
        buildData.dashServicePort=buildData.revalHost.ServicePort;
        buildData.qidHost2target=buildData.revalHost.host2target;
        buildData.qidTarget2host=buildData.revalHost.target2host;
    end
end


















