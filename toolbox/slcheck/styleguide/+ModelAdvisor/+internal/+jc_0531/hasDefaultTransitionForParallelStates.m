
function[result,states]=hasDefaultTransitionForParallelStates(...
    defaultTransitions,parallelStates)
    states=[];
    result=true;


    if size(defaultTransitions,1)==0||...
        size(parallelStates,1)==0
        result=false;
        return;
    end


    statesWithDefTrans=arrayfun(@(x)x.Destination,defaultTransitions,...
    'UniformOutput',false);
    statesWithDefTrans=statesWithDefTrans(~cellfun(@isempty,statesWithDefTrans));
    if iscell(statesWithDefTrans)
        statesWithDefTrans=cell2mat(statesWithDefTrans);
    end



    states=intersect(statesWithDefTrans,parallelStates);
    if isempty(states)
        result=false;
        return;
    end
end