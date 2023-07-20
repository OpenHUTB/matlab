

classdef ModelStructureBuilder<handle





    methods(Static)
        function modelStructure=Construct(modelName)

            import learning.stateflow.ModelStructureBuilder;
            modelStructure=learning.stateflow.ModelStructure();
            [model,needsToBeClosed]=ModelStructureBuilder.getModel(modelName);
            if isempty(model)
                return;
            end
            chart=model.find('-isa','Stateflow.Chart','Name','Chart');
            if numel(chart)>1
                for i=1:length(chart)
                    if isequal(chart(i).Path,[modelName,'/Chart'])
                        chart=chart(i);
                        break;
                    end
                end
            end
            if~isempty(chart)
                modelStructure.SymbolData=ModelStructureBuilder.getSymbolData(chart);
                [modelStructure.DefaultTransitions,modelStructure.Transitions]=ModelStructureBuilder.getTransitions(chart);
                modelStructure.States=ModelStructureBuilder.getStates(chart,modelStructure.DefaultTransitions,modelStructure.Transitions);
                modelStructure.Junctions=ModelStructureBuilder.getJunctions(chart,modelStructure.DefaultTransitions,modelStructure.Transitions);
                modelStructure.cleanupTransitions();
                modelStructure.reduceTransitions();
                modelStructure.GraphicalFunctions=ModelStructureBuilder.getGraphicalFunctions(chart);
                modelStructure.MATLABFunctions=ModelStructureBuilder.getMATLABFunctions(chart);
            end
            if needsToBeClosed
                close_system(modelName);
            end
        end

        function[m,needsToBeClosed]=getModel(modelName)

            assert(~isempty(which(modelName)));
            needsToBeClosed=false;
            courseNames=cellfun(@(k)(learning.simulink.SimulinkAppInteractions.getCourseNameFromCode(k)),...
            learning.simulink.preferences.slacademyprefs.CourseMap.keys,'UniformOutput',false);
            courseNames=strrep(courseNames,' ','');

            if~any(contains(courseNames,modelName))


                load_system(modelName);
                needsToBeClosed=true;
            end
            rt=sfroot;
            m=rt.find('-isa','Simulink.BlockDiagram','Name',modelName);
        end

        function symbolData=getSymbolData(chart)

            symbolData=[];
            d=chart.find('-isa','Stateflow.Data');
            if isempty(d)
                return;
            end
            paths=cell(1,length(d));
            for i=1:length(d)



                paths{i}=d(i).Path;
            end
            symbolData=learning.stateflow.StateflowConverter.getSymbolData(d,paths,chart);
        end

        function[defaultTransitions,transitions]=getTransitions(chart)

            defaultTransitions=[];
            transitions=[];
            allTransitions=chart.find('-isa','Stateflow.Transition');
            if isempty(allTransitions)
                return;
            end
            [defaultTransitions,transitions]=learning.stateflow.StateflowConverter.getTransitions(allTransitions);
        end

        function states=getStates(chart,defaultTransitions,transitions)

            states=[];
            s=chart.find('-isa','Stateflow.State');
            if isempty(s)
                return;
            end
            states=learning.stateflow.StateflowConverter.getStates(s,defaultTransitions,transitions);
            states=learning.stateflow.StateflowConverter.cleanStates(states);
        end

        function junctions=getJunctions(chart,defaultTransitions,transitions)

            junctions=[];
            j=chart.find('-isa','Stateflow.Junction');
            if isempty(j)
                return;
            end
            junctions=learning.stateflow.StateflowConverter.getJunctions(j,defaultTransitions,transitions);
        end

        function graphicalFunctions=getGraphicalFunctions(chart)
            graphicalFunctions=[];
            gf=chart.find('-isa','Stateflow.Function');
            if isempty(gf)
                return;
            end
            graphicalFunctions=learning.stateflow.StateflowConverter.getGraphicalFunctions(gf);
        end

        function MATLABFunctions=getMATLABFunctions(chart)
            MATLABFunctions=[];
            ml=chart.find('-isa','Stateflow.EMFunction');
            if isempty(ml)
                return;
            end
            MATLABFunctions=learning.stateflow.StateflowConverter.getMATLABFunctions(ml);
        end
    end
end

