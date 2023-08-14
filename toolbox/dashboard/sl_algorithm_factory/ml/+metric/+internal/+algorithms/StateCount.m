classdef StateCount<metric.SimpleMetric


    properties

    end

    methods
        function obj=StateCount()
            obj.AlgorithmID='slcomp.StateflowStates';
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

            states=sfObj.find('-isa','Stateflow.State');


            if~isempty(states)
                states=sf('find',[states.Id],'.comment.xplicit',0,...
                '.comment.implicit',0);
            end

            res.Value=uint64(length(states));
        end
    end
end
