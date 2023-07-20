

classdef ModelStructure<handle



    properties
SymbolData
DefaultTransitions
Transitions
States
Junctions
GraphicalFunctions
MATLABFunctions
    end

    methods
        function obj=ModelStructure()
        end

        function obj=cleanupTransitions(obj)


            for i=1:length(obj.Transitions)



                if isequal(obj.Transitions(i).LabelString,'?')



                    obj.Transitions(i).LabelString='';
                end


                if isequal(class(obj.Transitions(i).Destination),'Stateflow.State')
                    for j=1:length(obj.States)


                        if learning.stateflow.ModelStructure.transitionInArray(obj.Transitions(i),obj.States(j).Inputs)
                            obj.Transitions(i).Destination=obj.States(j);
                            break;
                        end
                    end
                else
                    for j=1:length(obj.Junctions)
                        if learning.stateflow.ModelStructure.transitionInArray(obj.Transitions(i),obj.Junctions(j).Inputs)
                            obj.Transitions(i).Destination=obj.Junctions(j);
                            break;
                        end
                    end
                end


                if isequal(class(obj.Transitions(i).Source),'Stateflow.State')

                    for j=1:length(obj.States)
                        if learning.stateflow.ModelStructure.transitionInArray(obj.Transitions(i),obj.States(j).Outputs)
                            obj.Transitions(i).Source=obj.States(j);
                            break;
                        end
                    end
                else

                    for j=1:length(obj.Junctions)
                        if learning.stateflow.ModelStructure.transitionInArray(obj.Transitions(i),obj.Junctions(j).Outputs)
                            obj.Transitions(i).Source=obj.Junctions(j);
                            break;
                        end
                    end
                end
            end
            for i=1:length(obj.DefaultTransitions)




                if isequal(class(obj.DefaultTransitions(i).Destination),'Stateflow.State')
                    for j=1:length(obj.States)


                        if learning.stateflow.ModelStructure.transitionInArray(obj.DefaultTransitions(i),obj.States(j).Inputs)
                            obj.DefaultTransitions(i).Destination=obj.States(j);
                            break;
                        end
                    end
                else
                    for j=1:length(obj.Junctions)
                        if learning.stateflow.ModelStructure.transitionInArray(obj.DefaultTransitions(i),obj.Junctions(j).Inputs)
                            obj.DefaultTransitions(i).Destination=obj.Junctions(j);
                            break;
                        end
                    end
                end
            end
        end
        function obj=reduceTransitions(obj)









            import learning.stateflow.ModelStructure;
            if isempty(obj.Transitions)
                return;
            end
            for i=length(obj.Transitions):-1:1



                if isequal(class(obj.Transitions(i).Destination),'learning.stateflow.Junction')&&...
                    ModelStructure.junctionHasOneInputAndOutput(obj.Transitions(i).Destination)&&...
                    ~ModelStructure.isConditionAction(obj.Transitions(i))
                    if ModelStructure.hasCondition(obj.Transitions(i).LabelString)&&...
                        ModelStructure.hasCondition(obj.Transitions(i).Destination.Outputs{1}.LabelString)



                        newLabelString=[obj.Transitions(i).LabelString(1:end-1),';',obj.Transitions(i).Destination.Outputs{1}.LabelString(2:end)];
                    else
                        newLabelString=[obj.Transitions(i).LabelString,obj.Transitions(i).Destination.Outputs{1}.LabelString];
                    end
                    newDestination=obj.Transitions(i).Destination.Outputs{1}.Destination;
                    oldTransition=obj.Transitions(i).Destination.Outputs{1};


                    for j=1:length(obj.Junctions)
                        if isequal(obj.Transitions(i).Destination,obj.Junctions(j))
                            obj.Junctions(j)=[];
                            break;
                        end
                    end
                    for j=1:length(obj.Transitions)
                        if isequal(oldTransition,obj.Transitions(j))



                            obj.Transitions(j)=learning.stateflow.Transition();
                            break;
                        end
                    end
                    obj.Transitions(i).LabelString=newLabelString;
                    obj.Transitions(i).Destination=newDestination;


                    for j=1:length(obj.Transitions(i).Destination.Inputs)
                        if isequal(obj.Transitions(i).Destination.Inputs{j},oldTransition)
                            obj.Transitions(i).Destination.Inputs{j}=obj.Transitions(i);
                            break;
                        end
                    end
                end
            end

            if~isempty(obj.Transitions)
                for i=length(obj.Transitions):-1:1
                    if isempty(obj.Transitions(i).LabelString)&&isempty(obj.Transitions(i).ExecutionOrder)&&...
                        isempty(obj.Transitions(i).Source)&&isempty(obj.Transitions(i).Destination)
                        obj.Transitions(i)=[];
                    end
                end
            end

        end
    end

    methods(Static)
        function isInArray=transitionInArray(transition,searchArray)


            isInArray=false;
            for k=1:length(searchArray)
                if isequal(transition,searchArray{k})
                    isInArray=true;
                    return;
                end
            end
        end

        function hasCondition=hasCondition(LabelString)


            hasCondition=false;
            if isempty(LabelString)
                return;
            end
            if(isequal(LabelString(1),'[')...
                &&isequal(LabelString(end),']'))
                hasCondition=true;
            end
        end

        function nextIsAction=nextIsAction(transition)


            nextIsAction=false;
            if~isequal(class(transition.Destination),'learning.stateflow.Junction')
                return;
            end
            if length(transition.Destination.Inputs)~=1||length(transition.Destination.Outputs)~=1



                return;
            end
            if isempty(transition.Destination.Outputs{1}.LabelString)
                return;
            end
            if(isequal(transition.Destination.Outputs{1}.LabelString(1),'{')...
                &&isequal(transition.Destination.Outputs{1}.LabelString(end),'}'))
                nextIsAction=true;
            end
        end

        function hasOneInputAndOutput=junctionHasOneInputAndOutput(junction)
            hasOneInput=isequal(numel(junction.Inputs),1);
            hasOneOutput=isequal(numel(junction.Outputs),1);
            hasOneInputAndOutput=hasOneInput&&hasOneOutput;
        end

        function isConditionAction=isConditionAction(transition)
            isConditionAction=false;
            if isempty(transition.LabelString)
                return;
            end
            isConditionAction=isequal(transition.LabelString(1),'[')&&...
            isequal(transition.LabelString(end),'}');
        end
    end

end

