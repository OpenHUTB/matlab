classdef LiveTaskUtilitiesBase<handle




    methods
        function utility=LiveTaskUtilitiesBase
            mlock;
        end
    end

    methods(Static)

        function figure=getFigure(task)
            props=properties(task);

            for i=1:length(props)
                prop=props{i};
                component=task.(prop);
                if isequal(isprop(component,'Type'),true)&&isequal(strcmp(component.Type,'figure'),true)
                    figure=component;
                    return;
                end
            end
        end



        function layoutManager=getLayoutManager(task)
            layoutManager=[];
        end


        function[code,outputs]=generateScript(task)
            [code,outputs]=task.generateScript();
            code=strtrim(code);
        end



        function code=generateVisualizationScript(task)
            if ismethod(task,'generateVisualizationScript')
                code=strtrim(task.generateVisualizationScript());
            else
                code='';
            end
        end


        function summary=generateSummary(task)
            summary=task.generateSummary();
        end



        function state=getState(task)
            if ismethod(task,'getState')
                stateStruct=task.getState();
                state=jsonencode(stateStruct,'ConvertInfAndNaN',false);
            else
                state='';
            end
        end


        function setState(task,state)
            if ismethod(task,'setState')
                stateStruct=jsondecode(state);
                task.setState(stateStruct);
            end
        end


        function reset(task)
            if ismethod(task,'reset')
                task.reset();
            end
        end


        function updateApp(task,variableMappings)
            if ismethod(task,'update')


                if isempty(variableMappings)
                    task.update(builtin('struct'));
                else
                    task.update(evalin('base',['builtin(''struct'',',variableMappings,')']));
                end
            end
        end


        function hasUpdate=hasUpdateMethod(task)
            hasUpdate=ismethod(task,'update');
        end


        function initialize(task,initializeData)
            code=initializeData.code;
            initialize(task,"Code",code);
        end
    end
end