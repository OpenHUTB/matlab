

classdef WhatToImportFunction<internal.CodeImporterUI.QuestionBase
    methods
        function obj=WhatToImportFunction(env)
            id='WhatToImportFunction';
            topic=message('Simulink:CodeImporterUI:Topic_WhatToImport').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='PortSpecificationsMapping';
            obj.getAndAddOption(env,'WhatToImportFunction_EntryFunctions');
            obj.getAndAddOption(env,'WhatToImportFunction_FunctionNameFilter');
            obj.getAndAddOption(env,'WhatToImportFunction_Table');
            obj.HasSummaryMessage=false;
        end

        function onNext(obj)
            onNext@internal.CodeImporterUI.QuestionBase(obj);
            env=obj.Env;
            env.Gui.MessageHandler.portspec_create;
            if obj.hasIOPort()
                obj.NextQuestionId='PortSpecificationsMapping';
            elseif isempty(env.CodeImporter.ParseInfo.AvailableTypes)
                obj.NextQuestionId='Finish';
            else
                obj.NextQuestionId='WhatToImportType';
            end
        end

        function ret=hasIOPort(obj)
            ret=false;
            env=obj.Env;
            parseInfo=env.CodeImporter.ParseInfo;
            fcnObjs=parseInfo.getFunctions(env.CodeImporter.FunctionsToImport);
            for fcn=fcnObjs
                allArguments=[fcn.PortSpecification.ReturnArgument...
                ,fcn.PortSpecification.InputArguments...
                ,fcn.PortSpecification.GlobalArguments];
                if~isempty(allArguments)
                    ret=true;
                    return;
                end
            end
        end
    end
end

