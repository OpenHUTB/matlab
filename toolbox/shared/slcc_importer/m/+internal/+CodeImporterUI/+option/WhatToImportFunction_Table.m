classdef WhatToImportFunction_Table<internal.CodeImporterUI.OptionBase




    methods
        function obj=WhatToImportFunction_Table(env)
            id='WhatToImportFunction_Table';
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

            allFcnNames=parseInfo.AvailableFunctions;

            selectedFcnNames=string([]);
            lastAnswer=env.LastAnswer;
            if strcmp(lastAnswer.Type,'onchange')


                selectedFcnNames=obj.lastSelectedFunctions(lastAnswer);
            elseif isempty(env.CodeImporter.FunctionsToImport)
                if env.State.FilterEntryFunctions

                    selectedFcnNames=parseInfo.EntryFunctions;
                else
                    selectedFcnNames=allFcnNames;
                end
            else
                selectedFcnNames=intersect(env.CodeImporter.FunctionsToImport,allFcnNames);
            end

            isEntryFcn=ismember(allFcnNames,parseInfo.EntryFunctions);

            obj.Value=struct('Name',cellstr(allFcnNames),'isEntryFunction',num2cell(isEntryFcn),'Enabled',true);

            if isscalar(obj.Value)
                obj.Value={obj.Value};
            end
            if isempty(selectedFcnNames)
                obj.Answer=zeros(size(allFcnNames));
            else
                obj.Answer=ismember(allFcnNames,selectedFcnNames);

                if isscalar(obj.Answer)
                    obj.Answer={obj.Answer};
                end
            end
        end
        function applyOnNext(obj)
            env=obj.Env;
            env.CodeImporter.FunctionsToImport=obj.lastSelectedFunctions(env.LastAnswer);
        end

        function ret=lastSelectedFunctions(obj,lastAnswer)
            ret={};
            for i=1:length(lastAnswer.Value)
                o=lastAnswer.Value(i);
                if strcmp(o.option,obj.Id)
                    choice=o.value;
                    if isempty(choice)
                        return;
                    end
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
