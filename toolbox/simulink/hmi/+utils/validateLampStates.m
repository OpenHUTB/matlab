function[states,stateColors,success,errormsg]=validateLampStates(obj)
    scChannel='/hmi_lamp_controller_/';

    states=[];
    stateColors=[];
    success=true;
    errormsg='';


    invStateIndexes=[];
    for idx=1:length(obj.States)
        data=str2double(obj.States{idx});
        if isempty(data)||~isreal(data)||isnan(data)||isinf(data)
            invStateIndexes{end+1}={idx};%#ok<*AGROW>
            success=false;
        else
            states=[states,data];
        end
    end


    if isequal(success,false)
        errormsg=DAStudio.message('SimulinkHMI:dialogs:NonNumericStatesError');
        message.publish([scChannel,'showInvalidStateData'],...
        invStateIndexes);
        return;
    end


    if length(states)>length(unique(states))
        errormsg=DAStudio.message('SimulinkHMI:dialogs:LampNonUniqueStatesError');
        success=false;

        dupMap=containers.Map('KeyType','double','ValueType','any');
        dupMap(states(1))={1};
        for idx=2:length(states)
            if~dupMap.isKey(states(idx))
                temp={};
            else
                temp=dupMap(states(idx));
            end

            temp{length(temp)+1}=idx;
            dupMap(states(idx))=temp;
        end


        dupStateCellArr={};
        dupMapKeys=dupMap.keys();
        for idx=1:length(dupMapKeys)
            if length(dupMap(dupMapKeys{idx}))>1
                dupStateCellArr{length(dupStateCellArr)+1}=dupMap(dupMapKeys{idx});
            end
        end


        message.publish([scChannel,'showDuplicateStates'],...
        dupStateCellArr);

        return;
    end

    stateColors=obj.StateColors;
end