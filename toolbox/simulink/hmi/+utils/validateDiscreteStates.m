function[states,stateLabels,success,errormsg]=validateDiscreteStates(obj)
    mdl=get_param(bdroot(get(obj.blockObj,'handle')),'Name');
    blk=get_param(obj.blockObj.handle,'Name');
    fullBlkPath=[mdl,'/',blk];
    propMap=obj.propMap;
    states=[];
    stateKeys=[];
    stateLabels={};
    success=true;
    errormsg='';
    keys=propMap.keys;
    param1=sprintf('''%s''',fullBlkPath);
    param2=sprintf('''%s''','States');
    invalidIndices={};
    scChannel='/hmi_discrete_knob_controller_/';

    emptyCell=false;
    emptyIndices={};
    for i=1:length(keys)
        if isempty(propMap(keys{i}).states)
            emptyIndices{end+1}={keys{i},1};
            emptyCell=true;
        end
        if isempty(propMap(keys{i}).stateLabels)
            emptyIndices{end+1}={keys{i},2};
            emptyCell=true;
        end

        stateLabels{end+1}=propMap(keys{i}).stateLabels;%#ok
        if~isnumeric(propMap(keys{i}).states)
            tmpState=str2double(propMap(keys{i}).states);
        else
            tmpState=propMap(keys{i}).states;
        end
        if~isempty(tmpState)&&~any(isnan(tmpState))&&isfloat(tmpState)&&~isempty(propMap(keys{i}).stateLabels)&&~isinf(tmpState)
            states(end+1)=tmpState;%#ok
            stateKeys(end+1)=keys{i};%#ok
        else
            success=false;
            errormsg=[DAStudio.message('SimulinkHMI:dialogs:SetError',param1,param2),' ',...
            DAStudio.message('SimulinkHMI:dialogs:NonNumericStatesError')];
            invalidIndices{end+1}={keys{i},1};%#ok
        end
    end
    stateLabels=strtrim(stateLabels);

    if emptyCell
        errormsg=DAStudio.message('SimulinkHMI:dialogs:EmptyValueOrLabelError');
        message.publish([scChannel,'showInvalidStateData'],{emptyIndices,errormsg});
        return;
    end

    if~success
        InspectorErrormsg=DAStudio.message('SimulinkHMI:dialogs:NonNumericStatesError');
        message.publish([scChannel,'showInvalidStateData'],{invalidIndices,InspectorErrormsg});
        return;
    end


    dupStateCellArr={};
    uniqStates=unique(states,'stable');
    if length(states)>length(uniqStates)
        success=false;
        errormsg=[DAStudio.message('SimulinkHMI:dialogs:SetError',param1,param2),' ',...
        DAStudio.message('SimulinkHMI:dialogs:NonUniqueStatesError')];
        for i=1:length(uniqStates)
            dupStateKeys=stateKeys((states==uniqStates(i)));
            if length(dupStateKeys)>1
                dupStateCellArr{end+1}=dupStateKeys;%#ok
            end
        end

        message.publish([scChannel,'showDuplicateStates'],dupStateCellArr);
        return;
    end
end