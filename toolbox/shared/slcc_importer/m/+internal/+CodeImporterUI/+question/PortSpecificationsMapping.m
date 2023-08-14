

classdef PortSpecificationsMapping<internal.CodeImporterUI.QuestionBase
    methods
        function obj=PortSpecificationsMapping(env)
            id='PortSpecificationsMapping';
            topic=message('Simulink:CodeImporterUI:Topic_WhatToImport').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='WhatToImportType';
            obj.getAndAddOption(env,'PortSpecificationsMapping_Table');
            obj.HasSummaryMessage=false;
        end

        function onNext(obj)
            onNext@internal.CodeImporterUI.QuestionBase(obj);
            env=obj.Env;
            parseInfo=env.CodeImporter.ParseInfo;
            assert(~isempty(parseInfo));
            env.CodeImporter.cacheFunctionSettings();
            if isempty(parseInfo.AvailableTypes)
                obj.NextQuestionId='Finish';
            else
                obj.NextQuestionId='WhatToImportType';
            end
        end
    end
end

