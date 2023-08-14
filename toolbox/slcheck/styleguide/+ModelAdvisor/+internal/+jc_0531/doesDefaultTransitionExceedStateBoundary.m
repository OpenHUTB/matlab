
function[result,failingElements]=doesDefaultTransitionExceedStateBoundary(...
    transitions,states)
    result=true;
    failingElements={};

    if isempty(transitions)||isempty(states)
        result=false;
        return;
    end

    for k=1:length(transitions)
        for p=1:length(states)
            if ModelAdvisor.internal.doTransitionBoxOverlap(transitions(k),...
                states(p))
                failingElements=[failingElements;transitions(k)];%#ok<AGROW>
            end
        end
    end

    if isempty(failingElements)
        result=false;
    else
        failingElements=unique(failingElements);
    end
end