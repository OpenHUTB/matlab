function[success,states]=validateSwitchStates(obj)
    success=false;
    states=[];
    hBlk=get(obj.getBlock(),'Handle');
    propMap=obj.propMap;
    keys=propMap.keys;
    newNumStates=length(keys);
    scChannel='/hmi_discrete_knob_controller_/';


    currentConfig=jsondecode(get_param(hBlk,'Configuration'));
    currentSettings=customwebblocks.utils.getSwitchSettingsFromDialog(currentConfig);
    currentStates=currentSettings.states;
    currNumStates=length(currentStates);


    newStates=[];
    newValues=[];
    emptyIndices={};
    invalidIndices={};


    if~isequal(newNumStates,currNumStates)
        for i=1:newNumStates
            if keys{i}>currNumStates


                newState=currentStates(currNumStates);

                if~isnumeric(propMap(keys{i}).states)
                    newValue=str2double(propMap(keys{i}).states);
                else
                    newValue=propMap(keys{i}).states;
                end
                newLabel=propMap(keys{i}).stateLabels;

                newState.Value=newValue;
                newState.Label.text.content=newLabel;
                newStates=[newStates,newState];
                newValues=[newValues,newValue];
            else
                newStates=[newStates,currentStates(keys{i})];
                newValues=[newValues,currentStates(keys{i}).Value];
            end
        end
    else

        for i=1:newNumStates

            if isempty(propMap(keys{i}).states)
                emptyIndices{end+1}={keys{i},1};
            end

            if~isnumeric(propMap(keys{i}).states)
                newValue=str2double(propMap(keys{i}).states);
            else
                newValue=propMap(keys{i}).states;
            end

            if isnan(newValue)||isinf(newValue)
                invalidIndices{end+1}={keys{i},1};
            end

            newState=currentStates(keys{i});
            newLabel=propMap(keys{i}).stateLabels;

            newState.Value=newValue;
            newState.Label.text.content=newLabel;

            newStates=[newStates,newState];
            newValues=[newValues,newValue];
        end
    end


    if~isempty(emptyIndices)
        errormsg=DAStudio.message('SimulinkHMI:dialogs:EmptyValueOrLabelError');
        message.publish([scChannel,'showInvalidStateData'],{emptyIndices,errormsg});
        return;
    end

    if~isempty(invalidIndices)
        InspectorErrormsg=DAStudio.message('SimulinkHMI:dialogs:NonNumericStatesError');
        message.publish([scChannel,'showInvalidStateData'],{invalidIndices,InspectorErrormsg});
        return;
    end


    if length(newValues)>1
        uniqueStates=unique(newValues);
        if~isequal(length(uniqueStates),length(newValues))
            dupStateCellArr={};
            for i=1:length(uniqueStates)
                indices=find(newValues==uniqueStates(i));
                if length(indices)>1
                    dupStateCellArr{end+1}=indices;
                end
            end

            message.publish([scChannel,'showDuplicateStates'],dupStateCellArr);
            return;
        end
    end



    success=true;
    states=newStates;
end

