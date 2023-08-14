classdef MigratorConflicts<sl.interface.dict.migrator.base.QuestionBase





    properties
        HelpViewID='interface_dictionary_migrator';
    end

    methods
        function obj=MigratorConflicts(env)

            id='ResolveDictionaryConflicts';
            topic=DAStudio.message('interface_dictionary:migrator:uiConflictsResolutionDialogTitle');

            obj@sl.interface.dict.migrator.base.QuestionBase(id,topic,env);

            obj.TrailTable=obj.createConflictsTable();

            conflicts=env.ValMsgs.flags.Conflicts;
            for i=1:length(conflicts)
                entry=conflicts{i};
                obj.updateTrailTableContent(entry{1},entry{2});
            end


            obj.getAndAddOption('Migrator_ConflictsKeepDictionary');
            obj.getAndAddOption('Migrator_ConflictsOverride');

            obj.QuestionMessage=DAStudio.message('interface_dictionary:migrator:uiConflictsResolutionDialogMessage');
            obj.HintMessage=DAStudio.message('interface_dictionary:migrator:uiConflictsResolutionHelp');

            if~isempty(env.ValMsgs.warnings.ioWarn)

                obj.NextQuestionId='Properties';
            elseif~isempty(env.ValMsgs.failures.mappingFail)

                obj.NextQuestionId='Component';
            else



                if any(~structfun(@isempty,env.ValMsgs.failures))
                    obj.DisplayFixAllButton=true;
                else
                    obj.DisplayFinishButton=true;
                end
            end
        end

        function updateTrailTableContent(obj,name,source)
            out=obj.TrailTable.Content;
            out=[out,'<tr><td style="text-align:left;border:none;">',name,'</td>'];
            out=[out,'<td style="text-align:left;border:none;">',source,'</td></tr>'];
            obj.TrailTable.Content=out;
        end

        function ret=onNext(obj)


            ret=0;
            for i=1:length(obj.Options)
                ret=obj.Options{i}.applyOnNext();
                if ret<0
                    return
                end
            end
        end
    end

    methods(Static)
        function TrailTable=createConflictsTable()

            TrailTable.Title=['<table width="100%"><tr><td style="text-align:left;border:none;">',DAStudio.message('interface_dictionary:migrator:uiConflictsTableTitle'),...
            '</td></tr></table>'];
            out='<table width="100%" id="migrationSummary">';
            TrailTable.Content=out;


            TrailTable.TailMessage='</table>';
        end
    end
end
