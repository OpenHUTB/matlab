classdef RoadRunnerDataTable




    properties(Constant)
        tableNamePrefix='RoadRunner';
    end

    methods(Static)
        function callbackForICTable()
            ssm.maskcallbacks.RoadRunnerDataTable.loadBussesIfNotLoaded();
            maskObj=Simulink.Mask.get(gcb);



            initialValues='';
            values=eval(maskObj.getParameter('ICTable').Value);
            for i=1:size(values,1)
                initialValues=[initialValues...
                ,values{i,1},'|',values{i,2},'|'];%#ok
            end
            runtimeBlockName=[gcb,'/'...
            ,ssm.maskcallbacks.RoadRunnerDataTable.tableNamePrefix,'ActorRuntime'];
            set_param(runtimeBlockName,'InitialValue',initialValues);


            set_param(runtimeBlockName,'Logging',...
            maskObj.getParameter('EnableLogging').Value);
        end
    end

    methods(Access=private,Static)
        function loadBussesIfNotLoaded()
            if~evalin('base',[...
'exist(''ActionEvent'') && '...
                ,'exist(''ActorRuntime'') && '...
                ,'exist(''ActorStatic'')'])
                ssm.maskcallbacks.RoadRunnerDataTable.loadBusStructures();
            elseif~evalin('base',[...
'isa(ActionEvent, ''Simulink.Bus'') &&'...
                ,'isa(ActorRuntime, ''Simulink.Bus'') &&'...
                ,'isa(ActorStatic, ''Simulink.Bus'')'])
                ssm.maskcallbacks.RoadRunnerDataTable.loadBusStructures();
            end
        end

        function loadBusStructures()
            currDir=pwd;
            cd([matlabroot,filesep,'toolbox',filesep,'ssm',filesep...
            ,'ssm_m',filesep,'+ssm',filesep,'+maskcallbacks']);
            evalin('base','load(''mActorBusses.mat'')');
            cd(currDir);
        end

        function clearBusStructures()
            evalin('base','clear ActionEvent ActorRuntime ActorStatic')
        end
    end
end