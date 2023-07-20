classdef StateflowDecisionCount<metric.SimpleMetric





    methods
        function obj=StateflowDecisionCount()
            obj.AlgorithmID='slcomp.StateflowDecisions';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64Vector);
            obj.Version=1;
        end

        function res=algorithm(this,resultFactory,component)


            res=resultFactory.createResult(this.ID,component);

            graphical_decisions=uint64(0);
            code_decisions=uint64(0);

            sfObj=Simulink.ID.getHandle(metric.internal.getSIDFromArtifact(component));

            if isnumeric(sfObj)
                tempVar=sfprivate('block2chart',sfObj);
                sfObj=idToHandle(sfroot,tempVar);
            end


            [graphdec,codedec]=this.getNrOfDecisionForTransitions(sfObj);
            graphical_decisions=graphical_decisions+graphdec;
            code_decisions=code_decisions+codedec;


            [graphdec,codedec]=this.getNrOfDecisionForTruthTable(sfObj);
            graphical_decisions=graphical_decisions+graphdec;
            code_decisions=code_decisions+codedec;


            [graphdec,codedec]=this.getNrOfDecisionForStates(sfObj);
            graphical_decisions=graphical_decisions+graphdec;
            code_decisions=code_decisions+codedec;

            res.Value=[graphical_decisions,code_decisions];
        end
    end

    methods(Access=private)

        function[graphdec,codedec]=getNrOfDecisionForTransitions(~,sfObj)


            transitions=sfObj.find('-isa','Stateflow.Transition');

            transitions=transitions(arrayfun(@(x)~strcmp(transitions(x).Condition,''),(1:length(transitions))));
            graphdec=length(transitions);

            codedec=uint64(0);
            for i=1:length(transitions)










                code="dummy = "+string(transitions(i).Condition);
                codedec=codedec+metric.internal.ca.getDecisionCount(code);
            end
        end

        function[graphdec,codedec]=getNrOfDecisionForTruthTable(~,sfObj)





            graphdec=uint64(0);
            codedec=uint64(0);

            tabels=sfObj.find('-isa','Stateflow.TruthTable');
            for i=1:length(tabels)


                ctsize=size(tabels(i).ConditionTable);


                ctsize=ctsize-[1,2];
                graphdec=graphdec+(prod(ctsize));


                code=strjoin(tabels(i).ActionTable(:,2),newline);
                codedec=codedec+metric.internal.ca.getDecisionCount(code);
            end
        end

        function[graphdec,codedec]=getNrOfDecisionForStates(~,sfObj)


            codedec=uint64(0);
            graphdec=uint64(0);

            states=sfObj.find('-isa','Stateflow.State');


            graphdec=max(0,length(states)-1);

            for i=1:length(states)



                code=strjoin({states(i).EntryAction,states(i).DuringAction,states(i).ExitAction},newline);
                codedec=codedec+metric.internal.ca.getDecisionCount(code);
            end
        end

    end

end
