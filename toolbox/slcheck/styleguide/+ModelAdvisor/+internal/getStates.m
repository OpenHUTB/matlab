
function[parallelStates,exclusiveStates]=getStates(context,depth,...
    includeItself,checkInsideBoxes)

    parallelStates=[];
    exclusiveStates=[];

    if isempty(context)
        return;
    end

    allStates=context.find('-isa','Stateflow.State','-depth',depth);

    if checkInsideBoxes
        boxes=context.find('-isa','Stateflow.Box','-depth',depth);
        if~isempty(boxes)
            allStates=[allStates;boxes.find('-isa','Stateflow.State','-depth',depth)];
        end
    end

    if~includeItself
        allStates=setdiff(allStates,context);
    end

    if isempty(allStates)
        return;
    end

    for d=1:length(allStates)
        if strcmp(allStates(d).Type,'AND')
            parallelStates=[parallelStates;allStates(d)];%#ok<AGROW>
        else

            exclusiveStates=[exclusiveStates;allStates(d)];%#ok<AGROW>
        end
    end
end