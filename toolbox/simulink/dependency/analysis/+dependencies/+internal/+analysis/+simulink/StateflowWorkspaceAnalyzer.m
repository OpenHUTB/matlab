classdef StateflowWorkspaceAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        StateNamePattern=namedPattern(textBoundary("start")+wildcardPattern+("/"|lineBoundary("end")),"stateName")

        ChangeDetectionOperators=["change","hasChanged","hasChangedFrom","hasChangedTo"]
        EdgeDetectionOperators=["crossing","falling","rising"]
        MessageActivityOperators=["discard","forward","isvalid","length","receive","send"]
        SignalGenerationOperators=["square","sawtooth","triangle","ramp","heaviside","latch"]
        StateActivityOperators=["enter","exit","in"]
        TemporalOperators=["t","et","after","at","before","count","duration","elapsed","every","temporalCount","tick","sec","msec","usec"]
    end

    methods

        function this=StateflowWorkspaceAnalyzer()
            import dependencies.internal.analysis.simulink.queries.StateflowQuery
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery

            this@dependencies.internal.analysis.simulink.AdvancedModelAnalyzer(true)

            queries.data=StateflowQuery.createDataQuery("name");
            queries.event=StateflowQuery.createEventQuery("name");
            queries.states=StateflowQuery.createStateQuery("labelString");
            queries.stateName=StateflowQuery.createStateQuery("activeStateOutput/customName");
            queries.stateEnum=StateflowQuery.createStateQuery("activeStateOutput/enumTypeName");
            queries.functions=StateflowQuery.createStateQuery("labelString",type="FUNC_STATE");
            queries.simFunctions=BlockParameterQuery.createParameterQuery("FunctionName",BlockType="TriggerPort",IsSimulinkFunction="on");

            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,~,matches)
            deps=dependencies.internal.graph.Dependency.empty;


            for data=[matches.data,matches.event]
                workspace=handler.getStateflowWorkspace(data.ParentID);
                workspace.addVariables(data.Value);
            end


            isState=~ismember(string([matches.states.ID]),string([matches.functions.ID]));
            stateNames=extract(string([matches.states.Value]),this.StateNamePattern);
            for n=find(isState)
                workspace=handler.getStateflowWorkspace(matches.states(n).ParentID);
                workspace.addVariables(stateNames(n));
            end


            for name=[matches.stateName,matches.stateEnum]
                workspace=handler.getStateflowWorkspace(name.ParentID);
                workspace.addVariables(name.Value);
            end


            for func=matches.functions
                tree=mtree("function "+func.Value);
                if~isempty(tree.Fname)
                    name=tree.Fname.strings{1};
                    workspace=handler.getStateflowWorkspace(func.ParentID);
                    workspace.addFunctions({name});
                end
            end


            handler.MachineWorkspace.addFunctions([...
            string(matches.simFunctions.Value)...
            ,this.ChangeDetectionOperators...
            ,this.EdgeDetectionOperators...
            ,this.MessageActivityOperators...
            ,this.SignalGenerationOperators...
            ,this.StateActivityOperators...
            ,this.TemporalOperators...
            ]);
        end

    end

end
