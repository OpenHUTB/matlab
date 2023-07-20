classdef WhatToImportType_Table<internal.CodeImporterUI.OptionBase




    methods
        function obj=WhatToImportType_Table(env)
            id='WhatToImportType_Table';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='checklist_table';
            obj.Value='';
            obj.HasMessage=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
        function preShow(obj)
            env=obj.Env;
            parseInfo=obj.Env.CodeImporter.ParseInfo;

            typeNames=parseInfo.AvailableTypes;
            typesUsedByFunctions=parseInfo.computeTypesUsedByFunctions(obj.Env.CodeImporter.FunctionsToImport);



            missingTypesUsedByFcns=setdiff(typesUsedByFunctions,typeNames);
            if~isempty(missingTypesUsedByFcns)
                typesUsedByFunctions=intersect(typesUsedByFunctions,typeNames);
                env.handle_warning(MException(message('Simulink:CodeImporter:TypeToImportMismatch',join(missingTypesUsedByFcns,", "))));
            end

            optionalTypes=setdiff(typeNames,typesUsedByFunctions);
            obj.Value=[struct('Name',cellstr(typesUsedByFunctions),'Enabled',false),...
            struct('Name',cellstr(optionalTypes),'Enabled',true)];


            if isscalar(obj.Value)
                obj.Value={obj.Value};
            end

            selectedTypeNames=string([]);
            lastAnswer=env.LastAnswer;
            if strcmp(lastAnswer.Type,'onchange')

                selectedTypeNames=obj.lastSelectedTypes(lastAnswer);
            else
                selectedTypeNames=env.CodeImporter.TypesToImport;
            end

            if isempty(typesUsedByFunctions)
                typesUsedByFunctions=string([]);
            end
            usedTypesByFcnAnswer=ones(size(typesUsedByFunctions));
            if isempty(selectedTypeNames)
                optionalTypesAnswer=zeros(size(optionalTypes));
                obj.Answer=[usedTypesByFcnAnswer,optionalTypesAnswer];
            else
                optionalTypesAnswer=ismember(optionalTypes,selectedTypeNames);
                obj.Answer=[usedTypesByFcnAnswer,optionalTypesAnswer];
            end






            if isscalar(obj.Answer)
                obj.Answer={obj.Answer};
            end

        end
        function applyOnNext(obj)
            env=obj.Env;
            env.CodeImporter.TypesToImport=obj.lastSelectedTypes(env.LastAnswer);
        end

        function ret=lastSelectedTypes(obj,lastAnswer)
            ret={};
            for i=1:length(lastAnswer.Value)
                o=lastAnswer.Value(i);
                if strcmp(o.option,obj.Id)
                    choice=o.value;
                    checkedArr=[choice.checked];
                    checkedIdx=find(checkedArr(:)==true);
                    ret=cell(1,length(checkedIdx));
                    for j=1:length(checkedIdx)
                        ret{j}=choice(checkedIdx(j)).value;
                    end
                end
            end
        end

    end
end
