classdef TransitionCount<metric.SimpleMetric


    properties

    end

    methods
        function obj=TransitionCount()
            obj.AlgorithmID='slcomp.StateflowTransitions';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;
        end

        function res=algorithm(this,resultFactory,component)

            res=resultFactory.createResult(this.ID,component);
            sfObj=Simulink.ID.getHandle(metric.internal.getSIDFromArtifact(component));

            if isnumeric(sfObj)
                tempVar=sfprivate('block2chart',sfObj);
                sfObj=idToHandle(sfroot,tempVar);
            end

            transitions=sfObj.find('-isa','Stateflow.Transition');


            if~isempty(transitions)
                transitions=sf('find',[transitions.Id],'.comment.xplicit',0,...
                '.comment.implicit',0);
            end

            res.Value=uint64(length(transitions));
        end
    end
end
