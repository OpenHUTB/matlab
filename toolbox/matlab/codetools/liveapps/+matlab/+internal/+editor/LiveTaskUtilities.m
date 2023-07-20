classdef LiveTaskUtilities<handle





    methods
        function utility=LiveTaskUtilities
            mlock;
        end
    end

    methods(Static)

        function figure=getFigure(task)
            utility=matlab.task.LiveTaskUtilitiesBridge;
            figure=utility.getFigure(task);
        end


        function layoutManager=getLayoutManager(task)
            utility=matlab.task.LiveTaskUtilitiesBridge;
            layoutManager=utility.getLayoutManager(task);
        end


        function[code,outputs]=generateScript(task)
            utility=matlab.task.LiveTaskUtilitiesBridge;
            [code,outputs]=utility.generateScript(task);


            code=regexprep(code,sprintf('(\r\n)|\r|\n'),newline);


            if isstring(code)
                code=code.join(newline);
            end
        end


        function code=generateVisualizationScript(task)
            utility=matlab.task.LiveTaskUtilitiesBridge;
            code=utility.generateVisualizationScript(task);
        end


        function summary=generateSummary(task)
            utility=matlab.task.LiveTaskUtilitiesBridge;
            summary=utility.generateSummary(task);
        end


        function state=getState(task)
            utility=matlab.task.LiveTaskUtilitiesBridge;
            state=utility.getState(task);
        end


        function setState(task,state)
            utility=matlab.task.LiveTaskUtilitiesBridge;
            utility.setState(task,state);
        end


        function reset(task)
            utility=matlab.task.LiveTaskUtilitiesBridge;
            utility.reset(task);
        end


        function updateApp(task,variableMappings)
            utility=matlab.task.LiveTaskUtilitiesBridge;
            utility.updateApp(task,variableMappings);
        end



        function hasUpdate=hasUpdateMethod(task)
            utility=matlab.task.LiveTaskUtilitiesBridge;
            hasUpdate=utility.hasUpdateMethod(task);
        end


        function initialize(task,initializeData)
            utility=matlab.task.LiveTaskUtilitiesBridge;
            utility.initialize(task,initializeData);
        end

        function flag=isMathworksAuthored(appIdentifier)
            flag=startsWith(which(appIdentifier),matlabroot);
        end
    end
end