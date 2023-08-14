classdef LiveTaskUtilitiesBridge<matlab.internal.editor.LiveTaskUtilitiesBase



    methods
        function utility=LiveTaskUtilitiesBridge
            mlock;
        end
    end

    methods(Static)

        function figure=getFigure(task)
            if isa(task,'matlab.task.LiveTask')
                figure=task.getFigure();
            else
                figure=matlab.internal.editor.LiveTaskUtilitiesBase.getFigure(task);
            end

        end


        function layoutManager=getLayoutManager(task)
            if isa(task,'matlab.task.LiveTask')
                layoutManager=task.getLayoutManager();
            else
                layoutManager=matlab.internal.editor.LiveTaskUtilitiesBase.getLayoutManager(task);
            end
        end


        function[code,outputs]=generateScript(task)
            if isa(task,'matlab.task.LiveTask')
                [code,outputs]=task.getCodeAndOutputs();
            else
                [code,outputs]=matlab.internal.editor.LiveTaskUtilitiesBase.generateScript(task);
            end
            code=strtrim(code);
        end



        function code=generateVisualizationScript(task)
            if isa(task,'matlab.task.LiveTask')
                code='';
            else
                code=matlab.internal.editor.LiveTaskUtilitiesBase.generateVisualizationScript(task);
            end
            code=strtrim(code);
        end


        function summary=generateSummary(task)
            if isa(task,'matlab.task.LiveTask')
                summary=task.getSummary();
            else
                summary=matlab.internal.editor.LiveTaskUtilitiesBase.generateSummary(task);
            end
        end


        function state=getState(task)
            if isa(task,'matlab.task.LiveTask')
                state=jsonencode(task.getState,'ConvertInfAndNaN',false);
            else
                state=matlab.internal.editor.LiveTaskUtilitiesBase.getState(task);
            end
        end


        function setState(task,state)
            if isa(task,'matlab.task.LiveTask')
                stateStruct=jsondecode(state);
                task.setState(stateStruct);
            else
                matlab.internal.editor.LiveTaskUtilitiesBase.setState(task,state);
            end
        end


        function reset(task)
            if isa(task,'matlab.task.LiveTask')
                task.resetState();
            else
                matlab.internal.editor.LiveTaskUtilitiesBase.reset(task);
            end
        end


        function updateApp(task,variableMappings)
            if isa(task,'matlab.task.LiveTask')
                if ismethod(task,'postExecutionUpdate')


                    if isempty(variableMappings)
                        task.postExecutionUpdate(builtin('struct'));
                    else
                        task.postExecutionUpdate(evalin('base',['builtin(''struct'',',variableMappings,')']));
                    end
                end
            else
                matlab.internal.editor.LiveTaskUtilitiesBase.updateApp(task,variableMappings);
            end
        end


        function hasUpdate=hasUpdateMethod(task)
            if isa(task,'matlab.task.LiveTask')
                hasUpdate=ismethod(task,'postExecutionUpdate');
            else
                hasUpdate=matlab.internal.editor.LiveTaskUtilitiesBase.hasUpdateMethod(task);
            end
        end


        function initialize(task,initializeData)
            if isa(task,'matlab.task.LiveTask')
                initialize(task,'Code',initializeData.code);
            else
                matlab.internal.editor.LiveTaskUtilitiesBase.initialize(task,initializeData);
            end
        end
    end
end
