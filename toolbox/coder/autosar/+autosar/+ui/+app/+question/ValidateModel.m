



classdef ValidateModel<autosar.ui.app.base.QuestionBase

    properties
        HelpViewID='autosar_composition_linking_requirements';
    end

    methods

        function obj=ValidateModel(env)

            id='ValidateModel';
            topic=DAStudio.message('autosarstandard:ui:uiValidationTopic');

            obj@autosar.ui.app.base.QuestionBase(id,topic,env);


            if strcmp(env.ValMsgs.failures.dictionaryMigrationCheckFail,'FailWithConflicts')

                obj.NextQuestionId='ResolveDictionaryConflicts';
            elseif~isempty(env.ValMsgs.warnings.ioWarn)

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



            obj.HasBack=false;


            if obj.DisplayFixAllButton

                obj.HintMessage=DAStudio.message('autosarstandard:ui:uiLinkingFixAllHint');
            elseif obj.DisplayFinishButton

                obj.HintMessage=DAStudio.message('autosarstandard:ui:uiLinkingFinishHint');
            else

                obj.HintMessage=DAStudio.message('autosarstandard:ui:uiConfigureModelHint');
            end


            obj.showValidationResults(env);
        end

        function showValidationResults(obj,env)



            valMsgs=env.ValMsgs;


            refModelName=env.ModelToLink;
            [~,refModelName,~]=fileparts(refModelName);

            obj.TrailTable=obj.loc_getInitAnalysisTable;

            if~isempty(valMsgs.failures.complianceFail)
                obj.updateTrailTableContent(DAStudio.message('autosarstandard:ui:uiIsAUTOSARCompliant'),'Fail')
            else
                obj.updateTrailTableContent(DAStudio.message('autosarstandard:ui:uiIsAUTOSARCompliant'),'Pass')
            end

            if~isempty(valMsgs.failures.mappingFail)
                obj.updateTrailTableContent(DAStudio.message('autosarstandard:ui:uiIsComponentMapped'),'Fail')
            else
                obj.updateTrailTableContent(DAStudio.message('autosarstandard:ui:uiIsComponentMapped'),'Pass')
            end

            if~isempty(valMsgs.failures.portsFail)


                obj.updateTrailTableContent(DAStudio.message('autosarstandard:ui:uiBEPRequirement'),'Fail')
            else
                obj.updateTrailTableContent(DAStudio.message('autosarstandard:ui:uiBEPRequirement'),'Pass')
            end

            if~isempty(valMsgs.failures.solverTypeFail)


                obj.updateTrailTableContent(DAStudio.message('autosarstandard:ui:uiFixedStepRequirement'),'Fail')
            else
                obj.updateTrailTableContent(DAStudio.message('autosarstandard:ui:uiFixedStepRequirement'),'Pass')
            end


            if autosar.api.Utils.isMapped(refModelName)
                if any(~structfun(@isempty,valMsgs.msgs))
                    obj.addMessageHeaderToTailMsg();
                    structfun(@obj.updateTailMessage,valMsgs.msgs);
                end
            end


            if any(~structfun(@isempty,valMsgs.warnings))
                obj.addWarningHeaderToTailMsg();
                structfun(@obj.updateTailWarnings,valMsgs.warnings);
            end

            if~valMsgs.flags.IsLinkingAUTOSARModel&&valMsgs.flags.HasLinkedArchitectureDictionary
                if~isempty(valMsgs.failures.dictionaryMigrationCheckFail)
                    obj.updateTrailTableContent(DAStudio.message('autosarstandard:ui:uiIsDataAndInterfaceMigrated'),'Fail')
                else
                    obj.updateTrailTableContent(DAStudio.message('autosarstandard:ui:uiIsDataAndInterfaceMigrated'),'Pass')
                end
            end

        end


        function updateTrailTableContent(obj,checkName,checkResult)
            out=obj.TrailTable.Content;
            out=[out,'<tr><td>',checkName,'</td>'];
            if strcmp(checkResult,'Pass')
                out=[out,'<td style="color:green;text-align:right;">',checkResult,'</td></tr>'];
            elseif strcmp(checkResult,'Fail')
                out=[out,'<td style="color:red;text-align:right;">',checkResult,'</td></tr>'];
            else
                error('Impossible result!');
            end
            obj.TrailTable.Content=out;
        end


        function detailErrorOnTrailTable(obj,errMsg)

            errMsg=convertStringsToChars(errMsg);
            out=obj.TrailTable.Content;
            out=[out,'<tr><td style="color:red;padding-left:20px;">',errMsg,'</td>','<td></tr>'];
            obj.TrailTable.Content=out;
        end


        function addMessageHeaderToTailMsg(obj)
            out=obj.TrailTable.TailMessage;
            out=[out,'<tr><th>','Messages:','</th></tr>'];
            obj.TrailTable.TailMessage=out;
        end

        function updateTailMessage(obj,msg)
            if~isempty(msg)

                msg=convertStringsToChars(msg);
                out=obj.TrailTable.TailMessage;
                out=[out,'<tr><td style="color:#474747;">',msg,'</td>','<td></tr>'];
                obj.TrailTable.TailMessage=out;
            end
        end


        function addWarningHeaderToTailMsg(obj)
            out=obj.TrailTable.TailMessage;
            out=[out,'<tr><th>','Warnings:','</th></tr>'];
            obj.TrailTable.TailMessage=out;
        end


        function updateTailWarnings(obj,warningMsg)
            if iscell(warningMsg)
                warningMsgCell=warningMsg;
                for i=1:length(warningMsgCell)
                    obj.updateTailWarnings(warningMsgCell{i});
                end
            elseif~isempty(warningMsg)

                warningMsg=convertStringsToChars(warningMsg);
                out=obj.TrailTable.TailMessage;
                out=[out,'<tr><td style="color:#CA6F1E;">',warningMsg,'</td>','<td></tr>'];
                obj.TrailTable.TailMessage=out;
            end
        end



        function toggleFinishButton(obj)
            obj.DisplayFixAllButton=false;
            obj.DisplayFinishButton=true;
        end
    end

    methods(Static)
        function TrailTable=loc_getInitAnalysisTable()

            TrailTable.Title=['<table width="100%"><tr><td style="text-align:left;border:none;">',message('autosarstandard:ui:uiValidationQuestion').getString,...
            '</td><td style="text-align:right;border:none;padding-right:20px;" class="warning">','</td></tr></table>'];
            out='<table id="analysisSummaryTbl">';
            TrailTable.Content=out;


            TrailTable.TailMessage='<table id="analysisSummaryTbl">';
        end
    end

end



