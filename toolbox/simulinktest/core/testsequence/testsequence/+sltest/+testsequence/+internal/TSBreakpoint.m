classdef TSBreakpoint<Stateflow.Debug.SFBreakpoint
    methods
        function obj=TSBreakpoint(udd,stateBpType)
            tagEnum=checkInputs(udd,stateBpType);
            obj=obj@Stateflow.Debug.SFBreakpoint(udd,tagEnum);
        end

        function status=shouldShowInBreakpointDialog(~)
            status=false;
        end

    end

    methods(Static)

        function bp=createBreakpoint(udd)
            if~sltest.testsequence.internal.TSBreakpoint.hasBreakpoint(udd)
                bpTypes=getBreakPointTypes(udd);
                for bpType=bpTypes
                    bp=sltest.testsequence.internal.TSBreakpoint(udd,bpType);
                    bp.triggerBreakpointAddedEvent();
                    Simulink.Debug.BreakpointList.addBreakpointToList(bp);
                    Stateflow.Debug.update_breakpoint_badges_for_object(udd);
                end
            else
                bp=[];
            end
        end

        function result=hasBreakpoint(udd)
            if~isempty(udd)
                if isa(udd,'Stateflow.State')
                    tagEnum=checkInputs(udd,"During");
                else
                    tagEnum=checkInputs(udd,"Transition");
                end
                result=Stateflow.Debug.SFBreakpoint.hasBreakpointOfType(udd,tagEnum);
            else
                result=false;
            end
        end

        function lookupAndDeleteBreakpoint(udd)
            if~isempty(udd)
                bpTypes=getBreakPointTypes(udd);
                for bpType=bpTypes
                    tagEnum=checkInputs(udd,bpType);
                    Stateflow.Debug.SFBreakpoint.lookupAndDeleteBreakpoint(udd,tagEnum);
                end
            end
        end

        function setBreakpointCondition(udd,condition)
            if~isempty(udd)
                bpTypes=getBreakPointTypes(udd);
                for bpType=bpTypes
                    tagEnum=checkInputs(udd,bpType);
                    bp=Stateflow.Debug.SFBreakpoint.findBreakpoint(udd,tagEnum);
                    bp.condition=condition;
                end
            end
        end

        function condition=getBreakpointCondition(udd)
            if~isempty(udd)
                bpTypes=getBreakPointTypes(udd);


                assert(numel(bpTypes)>0);
                tagEnum=checkInputs(udd,bpTypes{1});
                bp=Stateflow.Debug.SFBreakpoint.findBreakpoint(udd,tagEnum);
                if~isempty(bp)
                    condition=bp.condition;
                else
                    condition='';
                end
            else
                condition='';
            end
        end

    end

end

function tagEnum=checkInputs(udd,stateBpType)
    assert((isa(udd,'Stateflow.State')&&ismember(stateBpType,["Entry","During"]))||...
    (isa(udd,'Stateflow.Transition')&&strcmp(stateBpType,'Transition')));
    assert(isa(udd.Chart,'Stateflow.ReactiveTestingTableChart'));

    if isa(udd,'Stateflow.State')
        switch stateBpType
        case "Entry"
            tagEnum=Stateflow.Debug.BreakpointTypeEnums.onStateEntry;
        case "During"
            tagEnum=Stateflow.Debug.BreakpointTypeEnums.onStateDuring;
        end
    else
        tagEnum=Stateflow.Debug.BreakpointTypeEnums.whenTransitionValid;
    end
end

function bpTypes=getBreakPointTypes(udd)
    if isa(udd,'Stateflow.State')
        if strcmp(udd.Chart.StateMachineType,'Classic')
            bpTypes=["Entry","During"];
        else
            bpTypes="During";
        end
    else
        bpTypes="Transition";
    end
end
