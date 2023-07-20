classdef MigratorMainPage<sl.interface.dict.migrator.base.QuestionBase




    properties
        HelpViewID='interface_dictionary_migrator';
    end

    methods
        function obj=MigratorMainPage(env)

            env.ValMsgs.warnings.ioWarn='';
            env.ValMsgs.failures.mappingFail='';
            env.ValMsgs.flags.ConflictsBehavior='Error';


            id='MigratorMainPage';
            topic=DAStudio.message('interface_dictionary:migrator:uiMigratorWizardMainPage');

            obj@sl.interface.dict.migrator.base.QuestionBase(id,topic,env);

            obj.HasBack=false;

            if~isempty(env.ValMsgs.flags.Conflicts)
                obj.QuestionMessage=DAStudio.message('interface_dictionary:migrator:uiMigratorWizardMigrateWithConflicts');
                obj.HintMessage=DAStudio.message('interface_dictionary:migrator:uiMigratorWizardMigrateWithConflictsHelp');
                obj.updateNextQuestionInfo('ResolveDictionaryConflicts',false);
            else
                obj.QuestionMessage=DAStudio.message('interface_dictionary:migrator:uiMigratorWizardMigrateNoConflicts');
                obj.HintMessage=DAStudio.message('interface_dictionary:migrator:uiMigratorWizardMigrateNoConflictsHelp');
                obj.updateNextQuestionInfo('',true);
            end

            obj.TrailTable=obj.createMigrateTable();

            migrationResult=[env.ValMsgs.flags.MigratedInterfaces(:)',env.ValMsgs.flags.MigratedDataTypes(:)'];
            for i=1:length(migrationResult)
                entry=migrationResult{i};
                obj.updateTrailTableContent(entry.Name,entry.Source);
            end
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

        function updateTrailTableContent(obj,name,source)
            out=obj.TrailTable.Content;
            out=[out,'<tr><td style="text-align:left;border:none;">',name,'</td>'];
            out=[out,'<td style="text-align:left;border:none;">',source,'</td></tr>'];
            obj.TrailTable.Content=out;
        end
    end

    methods(Static)
        function TrailTable=createMigrateTable()

            TrailTable.Title=['<table style="margin-right:150px"><tr><td style="text-align:left;border:none;">',DAStudio.message('interface_dictionary:migrator:uiMigratorWizardTableTitle'),...
            '</td></tr></table>'];
            out='<table width="100%" id="migrationSummary">';
            TrailTable.Content=out;


            TrailTable.TailMessage='</table>';
        end
    end
end


