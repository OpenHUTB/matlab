









classdef UnsupportedTransitionPathsConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Paths from a state must be one of the following: inner transition to a substate, or outer transition to a sibling, direct parent, or direct substate';
        end

        function obj=UnsupportedTransitionPathsConstraint
            obj.setEnum('UnsupportedTransitionPaths');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            state=aObj.ParentState;
            substates=state.getSubstates;
            substateMap=containers.Map('KeyType','double','ValueType','logical');
            for i=1:numel(substates)
                substateMap(substates(i).getSfId)=true;
            end

            out=checkTransitions(aObj,state.getDefaultTransitions(),state.getUDDObject,substateMap);
            if~isempty(out)
                return;
            end

            out=checkTransitions(aObj,state.getInnerTransitions(),state.getUDDObject,substateMap);
            if~isempty(out)
                return;
            end

            out=checkTransitions(aObj,state.getOuterTransitions(),state.getUDDObject,substateMap);
            if~isempty(out)
                return;
            end

        end

    end
end

function out=checkTransitions(aObj,transitions,state,substateMap)
    out=[];
    if~isempty(transitions)
        transitionMap=containers.Map('KeyType','double','ValueType','logical');
        for i=1:numel(transitions)
            transition=transitions(i);
            if checkTransition(transition.getUDDObject,...
                state,...
                transitionMap,...
                substateMap)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'UnsupportedTransitionPaths',...
                aObj.ParentBlock().getName());
                return;
            end
        end
    end
end

function problem=checkTransition(transition,state,transitionMap,substateMap)
    problem=false;

    if~transitionMap.isKey(transition.Id)
        transitionMap(transition.Id)=true;
        parentChartOrState=getNonGraphicalParent(state);



        transitionParent=getNonGraphicalParent(transition);
        if transitionParent~=state&&...
            transitionParent~=parentChartOrState
            problem=true;
            return
        end





        transDst=transition.Destination;
        if isa(transDst,'Stateflow.Junction')
            outgoingTrans=slci.internal.getSFActiveObjs(...
            transDst.sourcedTransitions);
            for i=1:numel(outgoingTrans)
                problem=checkTransition(outgoingTrans(i),...
                state,...
                transitionMap,...
                substateMap);
                if problem
                    return
                end
            end

        elseif state==transDst
            problem=true;
            return;

        elseif transDst~=parentChartOrState&&...
            getNonGraphicalParent(transDst)~=parentChartOrState&&...
            ~substateMap.isKey(transDst.Id)
            problem=true;
            return;
        end
    end
end



function out=getNonGraphicalParent(obj)
    out=obj.getParent;
    while isa(out,'Stateflow.Box')
        out=out.getParent;
    end
end
