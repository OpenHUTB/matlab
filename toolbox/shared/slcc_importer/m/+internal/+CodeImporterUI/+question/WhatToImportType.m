

classdef WhatToImportType<internal.CodeImporterUI.QuestionBase
    methods
        function obj=WhatToImportType(env)
            id='WhatToImportType';
            topic=message('Simulink:CodeImporterUI:Topic_WhatToImport').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='Finish';
            obj.getAndAddOption(env,'WhatToImportType_TypeNameFilter');
            obj.getAndAddOption(env,'WhatToImportType_Table');
            obj.HasSummaryMessage=false;
        end

    end
end

