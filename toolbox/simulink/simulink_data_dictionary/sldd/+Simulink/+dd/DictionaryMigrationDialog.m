classdef DictionaryMigrationDialog<handle





    properties
        mModel='';
        mDictionary='';
        mDlgOpen=false;
        mMigrationAction='';
        mVarNames={};
        mModelEnumTypes={};
        mImported={};
        mExisting='';
        mUnsupported='';
        mConflicts='';
        mActionOption='';
        mRunTunableVars=false;
        mSaveDicts=true;
        mWaitHandle=0;
        hCleanup='';
        mExistingDictRefs={};
        bLaunchedFromStandalone=true;
        mDialogH='';
        migrateDD=true;
        hasAccessToBaseWorkspace=false;
        mBWSCheckbox=true;
    end
    properties(Access=public)
        m_modelCloseListener=[];
    end

    methods

        function obj=DictionaryMigrationDialog(hModel,dictionary,actionOption,dialogH)
            obj.mModel=hModel;
            obj.mDictionary=dictionary;
            obj.mDlgOpen=true;
            obj.mActionOption=actionOption;
            obj.hCleanup=onCleanup(@()Simulink.dd.DictionaryMigrationDialog.closeProgress(obj.mWaitHandle));
            obj.mDialogH=dialogH;
            if~isempty(obj.mDictionary)
                dictConn=Simulink.dd.open(obj.mDictionary);
                obj.hasAccessToBaseWorkspace=dictConn.HasAccessToBaseWorkspace;
                dictConn.close;
            end
            if ishandle(dialogH)
                obj.bLaunchedFromStandalone=dialogH.isStandAlone;




                if dialogH.isWidgetValid('EnableBWSAccess')
                    obj.mBWSCheckbox=dialogH.getWidgetValue('EnableBWSAccess');
                elseif slfeature('SLModelAllowedBaseWorkspaceAccess')>1
                    obj.mBWSCheckbox=strcmp(obj.mModel.EnableAccessToBaseWorkspace,'on');
                end
            end
            obj.m_modelCloseListener=Simulink.listener(hModel,'CloseEvent',...
            @(src,eventData)obj.modelCloseListener(src,eventData,obj));

        end

        function hasHierarchy=isModelRefHierarchy(obj)
            try


                hasHierarchy=(length(find_mdlrefs(obj.mModel.name,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false))>1);
            catch
                hasHierarchy=false;
            end
        end

        function schema=getDialogSchema(obj)

            hasHierarchy=false;
            currentDictionary='';
            newDictionary='';
            if~isequal(obj.mModel,'')
                hasHierarchy=obj.isModelRefHierarchy;
                currentDictionary=obj.mModel.DataDictionary;
                newDictionary=obj.mDictionary;
            end

            buttons={{'Simulink:editor:DialogYes',''},...
            {'Simulink:editor:DialogNo',''},...
            {'',''},...
            };



            msgQuestion='';
            msgWarning='';
            msgDetails='';
            schema=[];
            extraWidget=[];
            title='';
            lastRow=1;

            if isequal(obj.mActionOption,'linkv2')||isequal(obj.mActionOption,'linkAndMigrateV2')
                [msgInstruct,msgQuestion,msgWarning,msgDetails,buttons,title]=doLinkAndMigrate_New(obj,currentDictionary,newDictionary,hasHierarchy,buttons);
            elseif isequal(obj.mActionOption,'migrateV2')
                [msgInstruct,msgQuestion,msgWarning,msgDetails,buttons,extraWidget,title]=doMigrate_New(obj,currentDictionary,newDictionary,hasHierarchy,buttons);
                lastRow=2;
            else
                [msgInstruct,msgQuestion,msgWarning,msgDetails,buttons,schema]=doLinkAndMigrate_Original(obj,currentDictionary,newDictionary,hasHierarchy,buttons);
            end

            if isempty(schema)
                if~isempty(msgDetails)
                    colWidth=9;
                elseif~isempty(msgQuestion)
                    colWidth=10;
                else
                    colWidth=4;
                end

                image.Type='image';
                image.Tag='image';
                image.RowSpan=[lastRow,lastRow];
                image.ColSpan=[1,1];
                image.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','dialog_info_32.png');

                description.Name=msgInstruct;
                description.Type='text';
                description.Tag='Instructions';
                description.RowSpan=[lastRow,lastRow];
                description.ColSpan=[2,colWidth];

                if~isempty(msgDetails)
                    lastRow=lastRow+1;
                    details.Name=msgDetails;
                    details.Type='text';
                    details.WordWrap=true;
                    details.Tag='Details';
                    details.RowSpan=[lastRow,lastRow];
                    details.ColSpan=[3,colWidth];
                end

                if~isempty(msgWarning)
                    lastRow=lastRow+1;
                    warning.Name=msgWarning;
                    warning.Type='text';
                    warning.WordWrap=true;
                    warning.Tag='Warning';
                    warning.RowSpan=[lastRow,lastRow];
                    warning.ColSpan=[2,colWidth];
                end

                if~isempty(extraWidget)
                    lastRow=lastRow+1;
                    extraWidget.RowSpan=[lastRow,lastRow];
                    extraWidget.ColSpan=[2,colWidth];
                end

                if~isempty(msgQuestion)
                    lastRow=lastRow+1;
                    question.Name=msgQuestion;
                    question.Type='text';
                    question.WordWrap=true;
                    question.Tag='Question';
                    question.RowSpan=[lastRow,lastRow];
                    question.ColSpan=[2,colWidth];
                end

                if isempty(title)
                    schema.DialogTitle=DAStudio.message('Simulink:dialog:ModelDesignDataGroupName');
                else
                    schema.DialogTitle=title;
                end
                schema.DialogTag='SLDDMigrate';
                schema.StandaloneButtonSet={''};
                schema.Sticky=true;

                buttonCol=1;
                for i=1:numel(buttons)
                    if~isempty(buttons{i}{1})
                        button.Type='pushbutton';
                        button.Name=DAStudio.message(buttons{i}{1});
                        button.Tag=['DictMigrateDlg_',buttons{i}{1}];
                        button.MatlabMethod='Simulink.dd.DictionaryMigrationDialog.buttonCB';
                        button.MatlabArgs={'%dialog',button.Tag,buttons{i}{2}};
                        button.RowSpan=[1,1];
                        button.ColSpan=[buttonCol,buttonCol];
                        items{buttonCol}=button;%#ok
                        buttonCol=buttonCol+1;
                    end
                end

                lastRow=lastRow+1;
                spacer.Name=' ';
                spacer.Type='text';
                spacer.Tag='spacer';
                spacer.RowSpan=[lastRow,lastRow];
                spacer.ColSpan=[1,1];

                lastRow=lastRow+1;
                buttonGroup.Type='panel';
                buttonGroup.LayoutGrid=[1,1];
                buttonGroup.Items=items;
                buttonGroup.RowSpan=[lastRow,lastRow];
                buttonGroup.ColSpan=[(colWidth-2),(colWidth+2)];

                schema.LayoutGrid=[lastRow,(colWidth+2)];
                schema.CloseArgs={'%dialog','%closeaction',''};
                schema.CloseCallback='Simulink.dd.DictionaryMigrationDialog.buttonCB';
                if isempty(title)
                    schema.Items={image,description};
                else
                    schema.Items={description};
                end
                if~isempty(msgDetails)
                    schema.Items=[schema.Items,{details}];
                end
                if~isempty(msgWarning)
                    schema.Items=[schema.Items,{warning}];
                end
                if~isempty(extraWidget)
                    schema.Items=[schema.Items,{extraWidget}];
                end
                if~isempty(msgQuestion)
                    schema.Items=[schema.Items,{question}];
                end
                schema.Items=[schema.Items,{spacer}];
                schema.Items=[schema.Items,{buttonGroup}];
            end
        end

        function[msgInstruct,msgQuestion,msgWarning,msgDetails,buttons,title]=doLinkAndMigrate_New(obj,currentDictionary,newDictionary,hasHierarchy,buttons)
            msgQuestion='';
            msgWarning='';
            msgDetails='';
            title=DAStudio.message('Simulink:dialog:SimpleMigrationDialogTitle');

            if isempty(newDictionary)
                msgInstruct=DAStudio.message('SLDD:sldd:NewLinkToBWS',currentDictionary);
                if hasHierarchy
                    buttons{1}{1}='SLDD:sldd:MigrateLinkAllBtn';
                    buttons{1}{2}='changeDictInHierarchy';
                    buttons{2}{1}='SLDD:sldd:MigrateLinkOneBtn';
                    buttons{2}{2}='modelToBWS';
                    buttons{3}{1}='Simulink:editor:DialogCancel';
                    buttons{3}{2}='';
                else


                    msgQuestion=DAStudio.message('SLDD:sldd:MigrateContinue');
                    buttons{1}{2}='modelToDiffDict';
                end
            elseif isempty(currentDictionary)
                if hasHierarchy
                    msgInstruct=DAStudio.message('SLDD:sldd:NewLinkToDD',newDictionary);
                    buttons{1}{1}='SLDD:sldd:MigrateLinkAllBtn';
                    buttons{1}{2}='changeDictInHierarchy';
                    buttons{2}{1}='SLDD:sldd:MigrateLinkOneBtn';
                    buttons{2}{2}='changeDictInModel';
                    buttons{3}{1}='Simulink:editor:DialogCancel';
                    buttons{3}{2}='';
                else
                    msgInstruct=DAStudio.message('SLDD:sldd:NewLinkToDD_Mdl',newDictionary);
                    buttons{1}{1}='Simulink:editor:DialogApply';
                    buttons{1}{2}='modelToDiffDict';
                    buttons{2}{1}='Simulink:editor:DialogCancel';
                end
            elseif~isequal(currentDictionary,newDictionary)
                if hasHierarchy
                    msgInstruct=DAStudio.message('SLDD:sldd:NewLinkSwitchDD',...
                    currentDictionary,newDictionary);
                    buttons{1}{1}='SLDD:sldd:MigrateLinkAllBtn';
                    buttons{1}{2}='changeDictInHierarchy';
                    buttons{2}{1}='SLDD:sldd:MigrateLinkOneBtn';
                    buttons{2}{2}='modelToDiffDict';
                    buttons{3}{1}='Simulink:editor:DialogCancel';
                    buttons{3}{2}='';
                else

                    msgInstruct=DAStudio.message('SLDD:sldd:MigrateChangeDictNoHierarchy',...
                    currentDictionary,newDictionary);
                    buttons{1}{2}='modelToDiffDict';
                    msgQuestion=' ';
                end
            else


                msgInstruct=DAStudio.message('SLDD:sldd:MigrateContinue');
                buttons{1}{2}='modelToDiffDict';
            end
        end


        function[msgInstruct,msgQuestion,msgWarning,msgDetails,buttons,extraWidget,title]=doMigrate_New(obj,currentDictionary,newDictionary,hasHierarchy,buttons)
            msgInstruct='';
            msgWarning='';
            msgDetails='';
            extraWidget=[];

            title=DAStudio.message('SLDD:sldd:MigrateTitle');

            msgInstruct=DAStudio.message('SLDD:sldd:NewMigrateMsg',newDictionary);
            msgQuestion=DAStudio.message('SLDD:sldd:NewMigrateUpdateDiagramWarning');
            buttons{1}{1}='SLDD:sldd:MigrateBtn';
            buttons{1}{2}='migrateDataV2';
            buttons{2}{1}='Simulink:editor:DialogCancel';
            buttons{2}{2}='';

            hierarchyCheck.Type='checkbox';
            hierarchyCheck.Tag='SLDD:sldd:NewMigrateHierarchyMsg';
            hierarchyCheck.Name=DAStudio.message(hierarchyCheck.Tag);
            hierarchyCheck.RowSpan=[2,2];
            if hasHierarchy
                hierarchyCheck.Value=true;
                extraWidget.Visible=true;
            else
                hierarchyCheck.Value=false;
                extraWidget.Visible=false;
            end

            space2.Type='text';
            space2.Name=' ';
            space2.RowSpan=[3,3];

            extraWidget.Type='panel';
            extraWidget.LayoutGrid=[3,2];
            extraWidget.Items={hierarchyCheck,space2};

        end

        function[msgInstruct,msgQuestion,msgWarning,msgDetails,buttons,schema]=doLinkAndMigrate_Original(obj,currentDictionary,newDictionary,hasHierarchy,buttons)
            msgInstruct='';
            msgQuestion='';
            msgWarning='';
            msgDetails='';
            schema=[];

            DDMigrateChkboxName='';
            constructSimpleDialogForMigrationFromBWS=false;

            if isempty(newDictionary)
                if hasHierarchy
                    msgInstruct=DAStudio.message('SLDD:sldd:MigrateToBWS');
                    buttons{1}{1}='SLDD:sldd:MigrateLinkAllBtn';
                    buttons{1}{2}='hierarchyToBWS';
                    buttons{2}{1}='SLDD:sldd:MigrateLinkOneBtn';
                    buttons{2}{2}='modelToBWS';
                    buttons{3}{1}='Simulink:editor:DialogCancel';
                    buttons{3}{2}='';
                else


                    msgInstruct=DAStudio.message('SLDD:sldd:MigrateToBWS');
                    msgQuestion=DAStudio.message('SLDD:sldd:MigrateContinue');
                    buttons{1}{2}='modelToDiffDict';
                end
            elseif isempty(currentDictionary)
                if(~obj.hasAccessToBaseWorkspace)
                    if slfeature('EnableDictionaryToLookIntoBWS')==1
                        constructSimpleDialogForMigrationFromBWS=true;
                        DDMigrateChkboxName=DAStudio.message('SLDD:sldd:DDMigrateChkboxName',newDictionary);
                        buttons{1}{1}='Simulink:editor:DialogOK';
                        buttons{2}{1}='Simulink:editor:DialogCancel';
                        if hasHierarchy
                            if obj.migrateDD
                                msgDetails=DAStudio.message('SLDD:sldd:SimpleMigratePt1a');
                                buttons{1}{2}='migrateModelHierarchy';
                            else
                                msgDetails=DAStudio.message('SLDD:sldd:SimpleMigratePt1b');
                                buttons{1}{2}='connectModelHierarchy';
                            end
                            msgDetails=[msgDetails,DAStudio.message('SLDD:sldd:SimpleMigratePt2',newDictionary)];
                        else
                            if obj.migrateDD
                                msgDetails=DAStudio.message('SLDD:sldd:SimpleMigratePt1a');
                                if~isempty(get_param(obj.mModel.name,'TunableVars'))
                                    obj.mRunTunableVars=true;
                                    msgDetails=[msgDetails,DAStudio.message('SLDD:sldd:SimpleMigratePt3')];
                                end
                                buttons{1}{2}='singleModelMigrate';
                            else
                                msgDetails=DAStudio.message('SLDD:sldd:SimpleMigratePt1b');
                                buttons{1}{2}='singleModelConnect';
                            end
                        end
                    else
                        if hasHierarchy
                            msgInstruct=DAStudio.message('SLDD:sldd:SimpleMigrate1');
                            msgDetails=[DAStudio.message('SLDD:sldd:SimpleMigratePt1_featureOff'),...
                            DAStudio.message('SLDD:sldd:SimpleMigratePt2_featureOff',newDictionary),...
                            DAStudio.message('SLDD:sldd:SimpleMigratePt2a_featureOff'),...
                            DAStudio.message('SLDD:sldd:SimpleMigratePt3_featureOff')];
                            msgQuestion=DAStudio.message('SLDD:sldd:MigrateContinue');
                            msgWarning=DAStudio.message('SLDD:sldd:MigrateSaveWarning');
                            buttons{1}{2}='migrateModelHierarchy';
                        else

                            if~isempty(get_param(obj.mModel.name,'TunableVars'))
                                obj.mRunTunableVars=true;
                            end
                            msgInstruct=DAStudio.message('SLDD:sldd:SimpleMigrate1');
                            msgDetails=[DAStudio.message('SLDD:sldd:SimpleMigratePt1_featureOff'),...
                            DAStudio.message('SLDD:sldd:SimpleMigratePt2_featureOff',newDictionary)];
                            if(obj.mRunTunableVars)
                                msgDetails=[msgDetails,DAStudio.message('SLDD:sldd:SimpleMigratePt2b_featureOff')];
                            end
                            msgDetails=[msgDetails,DAStudio.message('SLDD:sldd:SimpleMigratePt3_featureOff')];
                            msgQuestion=DAStudio.message('SLDD:sldd:MigrateContinue');
                            buttons{1}{2}='singleModelMigrate';
                        end
                    end
                end
            elseif~isequal(currentDictionary,newDictionary)
                if isequal(obj.mActionOption,'link')
                    if hasHierarchy
                        msgQuestion='';
                        msgInstruct=DAStudio.message('SLDD:sldd:MigrateChangeDict',...
                        currentDictionary,newDictionary);
                        buttons{1}{1}='SLDD:sldd:MigrateLinkAllBtn';
                        buttons{1}{2}='hierarchyToDiffDict';
                        buttons{2}{1}='SLDD:sldd:MigrateLinkOneBtn';
                        buttons{2}{2}='modelToDiffDict';
                        buttons{3}{1}='Simulink:editor:DialogCancel';
                        buttons{3}{2}='';
                    else

                        msgInstruct=DAStudio.message('SLDD:sldd:MigrateChangeDictNoHierarchy',...
                        currentDictionary,newDictionary);
                        buttons{1}{2}='modelToDiffDict';
                        msgQuestion=' ';
                    end
                else

                    if hasHierarchy
                        msgInstruct=DAStudio.message('SLDD:sldd:SimpleComponentize1');
                        msgDetails=[DAStudio.message('SLDD:sldd:SimpleComponentizePt1',currentDictionary),...
                        DAStudio.message('SLDD:sldd:SimpleComponentizePt2',newDictionary),...
                        DAStudio.message('SLDD:sldd:SimpleComponentizePt2a'),...
                        DAStudio.message('SLDD:sldd:SimpleComponentizePt3')];
                        msgQuestion=DAStudio.message('SLDD:sldd:MigrateContinue');
                        msgWarning=DAStudio.message('SLDD:sldd:ComponentizeSaveWarning');
                        buttons{1}{2}='componentizeModelHierarchy';
                    else
                        msgInstruct=DAStudio.message('SLDD:sldd:SimpleComponentize1');
                        msgDetails=[DAStudio.message('SLDD:sldd:SimpleComponentizePt1',currentDictionary),...
                        DAStudio.message('SLDD:sldd:SimpleComponentizePt2',newDictionary),...
                        DAStudio.message('SLDD:sldd:SimpleComponentizePt3')];
                        msgQuestion=DAStudio.message('SLDD:sldd:MigrateContinue');
                        buttons{1}{2}='componentizeSingleModel';
                    end
                end
            else


                msgInstruct=DAStudio.message('SLDD:sldd:MigrateContinue');
                buttons{1}{2}='modelToDiffDict';
            end

            if constructSimpleDialogForMigrationFromBWS
                schema=constructMigrationWithBWS(obj,DDMigrateChkboxName,...
                msgDetails,buttons);
            end
        end

        function relaunchModelProps(obj)
            dlgProps=searchOpenDialogs(obj);



            if~isempty(dlgProps)&&strcmp(dlgProps.dialogTag,'Simulink:Model:Properties')
                dlgProps.setWidgetValue('DataDictionary',obj.mModel.DataDictionary);
                dlgProps.clearWidgetDirtyFlag('DataDictionary');
                return;
            end


            if isempty(dlgProps)
                tag=['_DDG_MP_',obj.mModel.name,'_TAG_'];
                dlgProps=DAStudio.Dialog(obj.mModel,tag,'DLG_STANDALONE');
            end

            imd=DAStudio.imDialog.getIMWidgets(dlgProps);
            tabbar=imd.find('tag','Tabcont');
            tabs=tabbar.find('-isa','DAStudio.imTab');
            if slfeature('ShowExternalDataNode')>0
                tabName=DAStudio.message('Simulink:dialog:ModelDataTabName_External');
            else
                tabName=DAStudio.message('Simulink:dialog:ModelDataTabName');
            end
            for i=1:length(tabs)
                if isequal(tabs(i).getName,tabName)
                    dlgProps.setActiveTab('Tabcont',i-1);
                    break;
                end
            end


            dlgProps.setUserData('DataDictionary','');
            if slfeature('SLDataDictionaryMigrateUI')>0
                if~isequal(obj.mModel.DataDictionary,dlgProps.getWidgetValue('DataDictionary'))
                    dlgProps.setWidgetValue('DataDictionary',dlgProps.getWidgetValue('DataDictionary'));
                    dlgProps.enableApplyButton(1);
                end
            else
                dlgProps.enableApplyButton(1);
                if isempty(obj.mDictionary)
                    dlgProps.setWidgetValue('DataDictionary',obj.mModel.DataDictionary);
                    dlgProps.setWidgetValue('DataSourceSelect',0);
                else
                    dlgProps.setWidgetValue('DataDictionary',obj.mDictionary);
                    dlgProps.setWidgetValue('DataSourceSelect',1);
                end
            end

            if slfeature('SLModelAllowedBaseWorkspaceAccess')==0


                modelddg_cb(dlgProps,'doSelectDataSource');
            end
            dlgProps.show;

        end

        function resetModelProps(obj)



            dlgProps=searchOpenDialogs(obj);

            if~isempty(dlgProps)

                dlgProps.setUserData('DataDictionary','');
                if isempty(obj.mDictionary)
                    dlgProps.setWidgetValue('DataDictionary',obj.mModel.DataDictionary);
                    dlgProps.setWidgetValue('DataSourceSelect',0);
                else
                    dlgProps.setWidgetValue('DataDictionary',obj.mDictionary);
                    dlgProps.setWidgetValue('DataSourceSelect',1);
                end
                modelddg_cb(dlgProps,'doSelectDataSource');
                dlgProps.enableApplyButton(0);
            end
        end

        function dialogH=searchOpenDialogs(obj)
            if ishandle(obj.mDialogH)
                dialogH=obj.mDialogH;
                return;
            end

            h=obj.mModel;
            openDialogs=DAStudio.ToolRoot.getOpenDialogs(h);
            dialogH=[];

            for i=1:length(openDialogs)
                bdH=openDialogs(i).getSource;
                if isa(bdH,'Simulink.BlockDiagram')
                    if(strcmp(bdH.Name,h.name)&&~strcmp('Simulink:Model:Info',openDialogs(i).DialogTag))

                        if isequal(openDialogs(i).isStandAlone,obj.bLaunchedFromStandalone)
                            dialogH=openDialogs(i);
                            break;
                        end
                    end
                end
            end
        end

        function performAction(obj,migrationAction,hWait)
            obj.mWaitHandle=hWait;
            obj.mImported={};
            obj.mExisting='';
            obj.mUnsupported='';
            obj.mConflicts='';
            obj.mMigrationAction=migrationAction;
            switch migrationAction
            case 'modelToDiffDict'

                continueAction(obj,'');
            case 'changeDictInModel'

                continueAction(obj,'');
            case 'modelToBWS'

                continueAction(obj,'');
            case 'hierarchyToBWS'
                continueAction(obj,'');
            case 'hierarchyToDiffDict'
                continueAction(obj,'');
            case 'changeDictInHierarchy'
                continueAction(obj,'');
            case 'singleModelMigrate'
                saveExistingDictReferences(obj);
                migrate(obj,true);
            case{'singleModelConnect','singleModelConnectWithoutDDSetting'}
                continueAction(obj,'');
            case{'connectModelHierarchy','connectModelHierarchyWithoutDDSetting'}
                try
                    saveExistingDictReferences(obj);
                    linkSubDictionaries(obj,'');
                    continueAction(obj,'');
                catch E
                    restoreExistingDictReferences(obj);
                    msgGeneral='SLDD:sldd:MigrationError';
                    dlg=Simulink.dd.DictionaryMigrationResults(msgGeneral,E.message);
                    DAStudio.Dialog(dlg,'','DLG_STANDALONE');
                    completeAction(obj,'');
                end
            case 'migrateModelHierarchy'
                try
                    saveExistingDictReferences(obj);
                    linkSubDictionaries(obj,'');
                    migrate(obj,true);
                catch E
                    restoreExistingDictReferences(obj);
                    msgGeneral='SLDD:sldd:MigrationError';
                    dlg=Simulink.dd.DictionaryMigrationResults(msgGeneral,E.message);
                    DAStudio.Dialog(dlg,'','DLG_STANDALONE');
                    completeAction(obj,'');
                end
            case 'componentizeSingleModel'
                componentizeCheck(obj);
            case 'componentizeModelHierarchy'
                componentizeCheck(obj);
            case 'migrateModelDataV2'
                saveExistingDictReferences(obj);
                migrate(obj,false);
            case 'migrateHierarchyDataV2'
                try
                    saveExistingDictReferences(obj);
                    migrate(obj,true);
                catch E
                    restoreExistingDictReferences(obj);
                    msgGeneral='SLDD:sldd:MigrationError';
                    dlg=Simulink.dd.DictionaryMigrationResults(msgGeneral,E.message);
                    DAStudio.Dialog(dlg,'','DLG_STANDALONE');
                    completeAction(obj,'');
                end
            end
        end

        function continueAction(obj,msgSpecifics)
            progressAmt=.9;
            if isequal(obj.mMigrationAction,'componentizeSingleModel')||...
                isequal(obj.mMigrationAction,'componentizeModelHierarchy')
                progressAmt=.1;
            end

            showProgress(obj,progressAmt,DAStudio.message('SLDD:sldd:CopyVarsWaitMsg'));


            msgGeneral='';
            bSaveSystem=false;
            bNotify=false;
            switch obj.mMigrationAction
            case 'modelToDiffDict'

                bSaveSystem=false;
            case 'changeDictInModel'

                bSaveSystem=false;
            case 'modelToBWS'

                bSaveSystem=false;
            case 'hierarchyToBWS'
                propagateDD(obj,true,'');
                bSaveSystem=true;
            case 'hierarchyToDiffDict'
                prevDict=obj.mModel.DataDictionary;
                propagateDD(obj,false,prevDict);
                bSaveSystem=true;
            case 'changeDictInHierarchy'
                prevDict=obj.mModel.DataDictionary;
                propagateDD(obj,false,prevDict);
                bSaveSystem=true;
            case 'singleModelMigrate'
                bNotify=true;
                changeSignalResolution(obj);
            case{'migrateModelHierarchy','connectModelHierarchy','connectModelHierarchyWithoutDDSetting'}
                changeSignalResolution(obj);
                propagateDD(obj,false,'');
                bSaveSystem=true;
                bNotify=true;
            case 'componentizeSingleModel'
                if~isempty(obj.mVarNames)||isempty(msgSpecifics)
                    doComponentize(obj);
                    bSaveSystem=false;
                else
                    msgGeneral='SLDD:sldd:ComponentError';
                end
            case 'componentizeModelHierarchy'
                if~isempty(obj.mVarNames)||isempty(msgSpecifics)
                    doComponentize(obj);
                    prevDict=obj.mModel.DataDictionary;
                    propagateDD(obj,false,prevDict);
                    bSaveSystem=true;
                else
                    msgGeneral='SLDD:sldd:ComponentError';
                end
            end
            if isempty(msgGeneral)
                wBWS=warning('off','Simulink:dialog:BWSAccessViaDD');
                updateBWS=false;
                if slfeature('SLModelAllowedBaseWorkspaceAccess')>1&&...
                    isempty(obj.mDictionary)
                    set_param(obj.mModel.name,'EnableAccessToBaseWorkspace',...
                    int8(obj.mBWSCheckbox));
                    updateBWS=true;
                end
                set_param(obj.mModel.name,'DataDictionary',obj.mDictionary);



                if slfeature('SLModelAllowedBaseWorkspaceAccess')>1&&~updateBWS
                    set_param(obj.mModel.name,'EnableAccessToBaseWorkspace',...
                    int8(obj.mBWSCheckbox));
                end
                warning(wBWS);
            end
            if bNotify
                Simulink.data.internal.notifyDictionaryLinked(obj.mModel.name);
            end
            if~isempty(obj.mModel.DataDictionary)
                ddConn=Simulink.dd.open(obj.mDictionary);
                ddConn.show();

                if ddConn.hasUnsavedChanges
                    ddConnSave=false;
                else
                    ddConnSave=true;
                end
                hasMadeDictDirty=false;
                if isequal(obj.mMigrationAction,'singleModelConnect')||...
                    isequal(obj.mMigrationAction,'connectModelHierarchy')
                    if~ddConn.HasAccessToBaseWorkspace
                        ddConn.EnableAccessToBaseWorkspace=true;
                        hasMadeDictDirty=true;
                    end
                end
                if ddConnSave&&hasMadeDictDirty
                    ddConn.saveChanges;
                end

            end
            if bSaveSystem
                try
                    save_system(obj.mModel.name);
                catch E
                    w=warning('off','backtrace');
                    warning(E.identifier,'%s',E.message);
                    warning(w);
                end
            end

            dlg='';
            if isequal(obj.mMigrationAction,'singleModelMigrate')||...
                isequal(obj.mMigrationAction,'migrateModelHierarchy')||...
                isequal(obj.mMigrationAction,'migrateModelDataV2')||...
                isequal(obj.mMigrationAction,'migrateHierarchyDataV2')
                if isempty(msgSpecifics)
                    if obj.mRunTunableVars
                        showProgress(obj,.1,DAStudio.message('SLDD:sldd:TunableVarsWaitMsg'));
                        tunablevars2parameterobjects(obj.mModel.name);
                        showProgress(obj,.9);
                    end
                    if isequal(obj.mMigrationAction,'singleModelMigrate')||...
                        isequal(obj.mMigrationAction,'migrateModelHierarchy')||...
                        slfeature('DuplicateModeForOneModelCompilation')<3
                        dlg=Simulink.dd.DictionaryPostImport(ddConn,obj.mImported,obj.mModelEnumTypes,obj.mExisting,obj.mUnsupported,obj.mConflicts,'');
                    else
                        dlg='';
                    end
                else
                    msgGeneral='SLDD:sldd:MigrationError';
                    dlg=Simulink.dd.DictionaryMigrationResults(msgGeneral,msgSpecifics);
                end
            elseif isequal(obj.mActionOption,'linkAndMigrateV2')
                dlg=Simulink.dd.DictionaryMigrationDialog(obj.mModel,obj.mDictionary,'migrateV2',obj.mDialogH);
            elseif~isempty(msgGeneral)
                dlg=Simulink.dd.DictionaryMigrationResults(msgGeneral,msgSpecifics);
            elseif isequal(obj.mMigrationAction,'singleModelConnect')||...
                isequal(obj.mMigrationAction,'connectModelHierarchy')||...
                isequal(obj.mMigrationAction,'singleModelConnectWithoutDDSetting')||...
                isequal(obj.mMigrationAction,'connectModelHierarchyWithoutDDSetting')
                dlg='';
            elseif isequal(obj.mMigrationAction,'changeDictInHierarchy')||...
                isequal(obj.mMigrationAction,'changeDictInModel')
                dlg='';
            else
                msgGeneral=['SLDD:sldd:MigrationSuccess_',obj.mMigrationAction];
                dlg=Simulink.dd.DictionaryMigrationResults(msgGeneral,'');
            end

            completeAction(obj,dlg);

        end

        function completeAction(obj,dlg)

            obj.cleanup();
            if~isempty(dlg)
                obj.resetModelProps();
            else
                obj.relaunchModelProps();
            end
            obj.mDlgOpen=false;
            delete(obj);
            if~isempty(dlg)
                DAStudio.Dialog(dlg,'','DLG_STANDALONE');
            end
        end

        function cleanup(obj)
            Simulink.dd.DictionaryMigrationDialog.closeProgress(obj.mWaitHandle);
            obj.mWaitHandle=0;
            obj.hCleanup='';
        end

        function migrate(obj,searchHierarchy)
            try
                if~bdIsLoaded('simulink')

                    load_system('simulink')
                end

                showProgress(obj,.1,DAStudio.message('SLDD:sldd:FindVarsWaitMsg'));
                if slfeature('SLDataDictionaryMigrateUI')<1
                    Simulink.dd.private.suspendMdlDictCheck(1);
                end



                activeCS=getActiveConfigSet(obj.mModel.name);
                if isa(activeCS,'Simulink.ConfigSetRef')
                    activeCS.refresh;
                end


                referencedVars=Simulink.findVars(obj.mModel.name,...
                'WorkspaceType','base','SearchReferencedModels','on');
                obj.mModelEnumTypes=Simulink.findEnumTypes(obj.mModel.name,...
                'SearchReferencedModels',true);
                Simulink.dd.private.suspendMdlDictCheck(0);

                if slfeature('SLDataDictionaryMigrateUI')>0
                    mdlsUsingDict=getDictionaryUsers(obj,searchHierarchy);
                else
                    mdlsUsingDict={};
                end

                obj.mVarNames=checkReferencedVars(obj,referencedVars,mdlsUsingDict);
                ddConn=Simulink.dd.open(obj.mDictionary);
                bContinue=true;
                if~isempty(obj.mVarNames)
                    showProgress(obj,.6,DAStudio.message('SLDD:sldd:CopyVarsWaitMsg'));
                    bTestForConflicts=true;
                    bOverwriteDuplicates=false;
                    sourceFile='';
                    scope='';
                    if~ddConn.hasUnsavedChanges
                        ddConnSave=true;
                    else
                        ddConnSave=false;
                    end

                    [obj.mImported,obj.mExisting,obj.mConflicts,obj.mUnsupported]=...
                    ddConn.interactiveImport(bTestForConflicts,bOverwriteDuplicates,sourceFile,scope,obj.mVarNames);
                    clear tmp;
                    if~isempty(obj.mConflicts)
                        Simulink.dd.DictionaryMigrationDialog.closeProgress(obj.mWaitHandle);
                        obj.mWaitHandle=0;
                        bAllowOverwriteOption='off';
                        bContinue=false;
                        dlg=Simulink.dd.DictionaryPreImport(ddConn,obj.mConflicts,sourceFile,bAllowOverwriteOption,@obj.continueMigrate);
                        DAStudio.Dialog(dlg,'','DLG_STANDALONE');
                    elseif ddConnSave&&obj.mSaveDicts
                        ddConn.saveChanges;
                    end
                end
                if bContinue
                    continueAction(obj,'');
                end
            catch E
                Simulink.dd.private.suspendMdlDictCheck(0);
                continueAction(obj,E.message);
            end
        end

        function changeSignalResolution(obj)
            try
                if isequal(get_param(obj.mModel.name,'SignalResolutionControl'),'TryResolveAll')
                    set_param(obj.mModel.name,'SignalResolutionControl','TryResolveAllWithWarning');
                end
            catch E
                w=warning('off','backtrace');
                warning(E.identifier,E.message);
                warning(w);
            end
        end

        function componentizeCheck(obj)
            try
                if~bdIsLoaded('simulink')

                    load_system('simulink')
                end
                showProgress(obj,.1,DAStudio.message('SLDD:sldd:FindVarsWaitMsg'));
                if slfeature('SLDataDictionaryMigrateUI')<1
                    Simulink.dd.private.suspendMdlDictCheck(1);
                end
                referencedVars=Simulink.findVars(obj.mModel.name,'SourceType','data dictionary');
                Simulink.dd.private.suspendMdlDictCheck(0);
                obj.mVarNames={referencedVars.Name};

                currentDictionary=obj.mModel.DataDictionary;
                newDictionary=obj.mDictionary;
                bContinue=true;
                if~isempty(obj.mVarNames)
                    showProgress(obj,.5,DAStudio.message('SLDD:sldd:FindVarsWaitMsg'));

                    conflictCheck(obj);

                    if~isempty(obj.mConflicts)
                        bAllowOverwriteOption='off';
                        sourceFile=currentDictionary;
                        ddConnNew=Simulink.dd.open(newDictionary);
                        dlg=Simulink.dd.DictionaryPreImport(ddConnNew,obj.mConflicts,sourceFile,bAllowOverwriteOption,@obj.continueComponentize);
                        Simulink.dd.DictionaryMigrationDialog.closeProgress(obj.mWaitHandle);
                        obj.mWaitHandle=0;
                        bContinue=false;
                        DAStudio.Dialog(dlg,'','DLG_STANDALONE');
                    end
                end

                if bContinue
                    showProgress(obj,.9,'');
                    continueAction(obj,'');
                end
            catch E
                Simulink.dd.private.suspendMdlDictCheck(0);
                continueAction(obj,E.message);
            end
        end

        function continueMigrate(obj,ddConn,sourceFile,bContinue,bOverwrite,varargin)
            if bContinue
                bTestForConflicts=false;
                scope='';
                if~ddConn.hasUnsavedChanges
                    ddConnSave=true;
                else
                    ddConnSave=false;
                end
                if bOverwrite
                    varsToImport=obj.mVarNames;
                else

                    conflictVars=obj.mConflicts(:,1);
                    varsToImport=setdiff(obj.mVarNames,conflictVars);
                end



                if~isempty(varsToImport)
                    try
                        [obj.mImported,obj.mExisting,~,obj.mUnsupported]=...
                        ddConn.interactiveImport(bTestForConflicts,bOverwrite,sourceFile,scope,varsToImport);
                        if~isempty(conflictVars)&&~bOverwrite


                            obj.mExisting=[obj.mExisting;conflictVars];
                        end
                    catch E
                        w=warning('off','backtrace');
                        warning(E.identifier,E.message);
                        warning(w);
                    end
                end
                clear tmp;
                if ddConnSave&&obj.mSaveDicts
                    ddConn.saveChanges;
                end
                if bOverwrite
                    obj.mConflicts={};
                end

                continueAction(obj,'');
            else
                restoreExistingDictReferences(obj);
                completeAction(obj,'');
            end
        end

        function continueComponentize(obj,ddConn,sourceFile,bContinue,bOverwrite,varargin)%#ok
            if bContinue
                continueAction(obj,'');
            else
                completeAction(obj,'');
            end
        end

        function conflictCheck(obj)
            ddConnNew=Simulink.dd.open(obj.mDictionary);
            ddConnCurrent=Simulink.dd.open(obj.mModel.DataDictionary);
            if(ddConnNew.numEntries>0)
                len=length(obj.mVarNames);
                for i=1:len
                    scope='';
                    try


                        if ddConnCurrent.entryExists(['Global.',obj.mVarNames{i}],false)
                            scope='Global';
                        elseif ddConnCurrent.entryExists(['Configurations.',obj.mVarNames{i}],false)
                            scope='Configurations';
                        end
                        if~isempty(scope)&&ddConnNew.entryExists([scope,'.',obj.mVarNames{i}],false)
                            if~isequal(ddConnNew.getEntry([scope,'.',obj.mVarNames{i}]),...
                                ddConnCurrent.getEntry([scope,'.',obj.mVarNames{i}]))
                                obj.mConflicts=[obj.mConflicts;{obj.mVarNames{i},scope}];
                            else
                                obj.mExisting=[obj.mExisting,obj.mVarNames(i)];
                            end
                        end
                    catch
                        obj.mConflicts=[obj.mConflicts;{obj.mVarNames{i},scope}];
                    end
                end
            end
        end

        function doComponentize(obj)
            ddNewName=obj.mDictionary;
            ddConnNew=Simulink.dd.open(ddNewName);
            if~ddConnNew.hasUnsavedChanges
                ddConnNewSave=true;
            else
                ddConnNewSave=false;
            end
            ddCurrentName=obj.mModel.DataDictionary;
            ddConnCurrent=Simulink.dd.open(ddCurrentName);
            if~ddConnCurrent.hasUnsavedChanges
                ddConnCurrentSave=true;
            else
                ddConnCurrentSave=false;
            end

            w=warning('off','backtrace');

            conflictingNames={};
            if~isempty(obj.mConflicts)
                conflictingNames=obj.mConflicts(:,1);
            end
            newRefsToAdd={};
            varsToMove={};
            len=length(obj.mVarNames);
            for i=1:len
                amt=i/len;
                amt=max(.1,min(.9,amt));
                showProgress(obj,amt,DAStudio.message('SLDD:sldd:CopyVarsWaitMsg'));

                if~any(ismember(conflictingNames,obj.mVarNames{i}))


                    scope='';
                    dataSource='';
                    try

                        if ddConnCurrent.entryExists(['Global.',obj.mVarNames{i}],false)
                            scope='Global';
                        elseif ddConnCurrent.entryExists(['Configurations.',obj.mVarNames{i}],false)
                            scope='Configurations';
                        end
                        if~isempty(scope)
                            dataSource=ddConnCurrent.getEntryDataSource([scope,'.',obj.mVarNames{i}]);
                        end
                    catch E
                        warning(E.identifier,E.message);
                    end

                    if isequal(dataSource,ddCurrentName)


                        try
                            if any(ismember(obj.mExisting,obj.mVarNames{i}))



                                if~isempty(scope)
                                    ddConnCurrent.deleteEntry([scope,'.',obj.mVarNames{i}]);
                                end
                            else


                                if~isempty(scope)
                                    varsToMove=[varsToMove,[scope,'.',obj.mVarNames{i}]];%#ok
                                end
                            end
                        catch E
                            warning(E.identifier,E.message);
                        end
                    else


                        try
                            if any(ismember(obj.mExisting,obj.mVarNames{i}))



                                if~isempty(scope)
                                    if~isequal(dataSource,ddNewName)
                                        newRefsToAdd=[newRefsToAdd,dataSource];%#ok
                                        ddConnNew.deleteEntry([scope,'.',obj.mVarNames{i}]);
                                    end
                                end
                            else


                                newRefsToAdd=[newRefsToAdd,dataSource];%#ok
                            end
                        catch E
                            warning(E.identifier,E.message);
                        end
                    end

                end

            end



            ddConnCurrent.addReference(ddNewName);



            len=length(varsToMove);
            for i=1:len
                try
                    ddConnCurrent.setEntryDataSource(varsToMove{i},ddNewName);
                catch E
                    warning(E.identifier,E.message);
                end
            end

            len=length(newRefsToAdd);
            for i=1:len
                ddConnNew.addReference(newRefsToAdd{i});
            end
            if ddConnCurrentSave&&obj.mSaveDicts
                ddConnCurrent.saveChanges;
            end
            if ddConnNewSave&&obj.mSaveDicts
                ddConnNew.saveChanges;
            end
            showProgress(obj,.95,'');



            linkSubDictionaries(obj,ddCurrentName);

            warning(w);

        end

        function linkSubDictionaries(obj,dictToExclude)
            if slfeature('SLDataDictionaryDataScopeSimSystemOfSystems')>0
                return;
            end
            try


                allRefs=find_mdlrefs(obj.mModel.name,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            catch
                allRefs='';
            end
            len=length(allRefs);
            ddConn=Simulink.dd.open(obj.mDictionary);
            if~ddConn.hasUnsavedChanges
                ddConnSave=true;
            else
                ddConnSave=false;
            end
            for i=1:len
                nextSys=allRefs{i};
                if~isequal(nextSys,obj.mModel.name)
                    bCloseSys=false;
                    if~bdIsLoaded(nextSys)
                        load_system(nextSys);
                        bCloseSys=true;
                    end
                    subDictionary=get_param(nextSys,'DataDictionary');
                    if~isempty(subDictionary)&&~isequal(subDictionary,obj.mDictionary)&&...
                        ~isequal(subDictionary,dictToExclude)
                        ddConn.addReference(subDictionary);
                    end
                    if bCloseSys
                        close_system(nextSys);
                    end
                end
            end
            if ddConnSave&&obj.mSaveDicts
                ddConn.saveChanges;
            end
        end

        function mdlsUsingDict=getDictionaryUsers(obj,checkMdlHierarchy)
            mdlsUsingDict={obj.mModel.name};
            if checkMdlHierarchy
                try


                    allRefs=find_mdlrefs(obj.mModel.name,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
                catch
                    allRefs='';
                end
                len=length(allRefs);

                for i=1:len
                    nextSys=allRefs{i};
                    if~isequal(nextSys,obj.mModel.name)
                        bCloseSys=false;
                        if~bdIsLoaded(nextSys)
                            load_system(nextSys);
                            bCloseSys=true;
                        end
                        subDictionary=get_param(nextSys,'DataDictionary');
                        if isequal(subDictionary,obj.mDictionary)
                            mdlsUsingDict{end+1}=nextSys;
                        end
                        if bCloseSys
                            close_system(nextSys);
                        end
                    end
                end
            end
        end

        function saveExistingDictReferences(obj)
            obj.mExistingDictRefs={};
            ddConn=Simulink.dd.open(obj.mDictionary);
            dependencies=ddConn.Dependencies;
            len=length(dependencies);
            for i=1:len
                [~,name,ext]=fileparts(dependencies{i});
                obj.mExistingDictRefs=[obj.mExistingDictRefs,[name,ext]];
            end
        end

        function restoreExistingDictReferences(obj)
            ddConn=Simulink.dd.open(obj.mDictionary);
            if~ddConn.hasUnsavedChanges
                ddConnSave=true;
            else
                ddConnSave=false;
            end

            dependencies=ddConn.Dependencies;
            len=length(dependencies);
            for i=1:len
                [~,name,ext]=fileparts(dependencies{i});
                if isempty(intersect(obj.mExistingDictRefs,[name,ext]))


                    ddConn.removeReference([name,ext]);
                end
            end

            if ddConnSave&&obj.mSaveDicts
                ddConn.saveChanges;
            end
        end

        function propagateDD(obj,bForceChange,valueToReplace)

            showProgress(obj,0,DAStudio.message('Simulink:dialog:ModelPropagateWaitMsg'));



            w=warning('off','backtrace');
            if slfeature('SLModelAllowedBaseWorkspaceAccess')>1


                if isempty(obj.mDictionary)
                    set_param(obj.mModel.name,'EnableAccessToBaseWorkspace',...
                    int8(obj.mBWSCheckbox));
                end
            end
            set_param(obj.mModel.name,'DataDictionary',obj.mDictionary);


            mdlrefList=find_mdlrefs(obj.mModel.name,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);

            len=length(mdlrefList);
            for i=1:len
                showProgress(obj,i/len,'');
                nextSys=mdlrefList{i};
                if~isequal(nextSys,obj.mModel.name)
                    bCloseSys=false;
                    if~bdIsLoaded(nextSys)
                        load_system(nextSys);
                        bCloseSys=true;
                    end
                    bNeedToSave=false;
                    if bForceChange||isequal(get_param(nextSys,'DataDictionary'),valueToReplace)
                        if~isequal(get_param(nextSys,'DataDictionary'),obj.mDictionary)
                            checkboxApplied=false;
                            if slfeature('SLModelAllowedBaseWorkspaceAccess')>1...
                                &&isempty(obj.mDictionary)&&obj.mBWSCheckbox
                                set_param(nextSys,'EnableAccessToBaseWorkspace',...
                                int8(obj.mBWSCheckbox));
                                checkboxApplied=true;
                            end

                            set_param(nextSys,'DataDictionary',obj.mDictionary);
                            if slfeature('SLModelAllowedBaseWorkspaceAccess')>1&&~checkboxApplied&&...
                                isempty(obj.mDictionary)


                                set_param(nextSys,'EnableAccessToBaseWorkspace',...
                                int8(obj.mBWSCheckbox));
                            end
                            bNeedToSave=true;
                        end
                    end
                    try
                        if bCloseSys
                            close_system(nextSys,bNeedToSave);
                        elseif bNeedToSave
                            save_system(nextSys);
                        end
                    catch E
                        warning(E.identifier,'%s',E.message);
                    end
                end
            end
            warning(w);
        end




        function rtnList=checkReferencedVars(obj,vars,mdlsUsingDict)%#ok

            rtnList={};
            bExcludeFromWSData=false;

            for i=1:length(vars)
                okToImport=false;
                for j=1:length(vars(i).Users)
                    blockUser=vars(i).Users(j);
                    blkType=get_param(blockUser{1},'Type');
                    if isequal('block',blkType)
                        blkType=get_param(blockUser{1},'BlockType');
                    end
                    if isequal('FromWorkspace',blkType)&&bExcludeFromWSData
                        varNameProperty=get_param(blockUser{1},'VariableName');

                        if~isequal(vars(i).Name,varNameProperty)
                            okToImport=true;
                            break;
                        end
                    elseif isequal('block_diagram',blkType)




                        nonWorkspaceCase=findobj(vars(i).DirectUsageDetails,'-not','Properties',{'InitialState'},...
                        '-not','Properties',{'ExternalInput'});
                        if~isempty(nonWorkspaceCase)

                            okToImport=true;
                        end
                        break;
                    else
                        if~isempty(mdlsUsingDict)
                            okToImport=ismember(strtok(blockUser{1},'/'),mdlsUsingDict);
                        else
                            okToImport=true;
                        end
                        if okToImport
                            break;
                        end
                    end
                end

                if okToImport
                    rtnList=[rtnList,vars(i).Name];%#ok
                end
            end
        end

        function showProgress(obj,amount,message)
            try
                if isempty(message)
                    if isequal(0,obj.mWaitHandle)
                        obj.mWaitHandle=waitbar(amount,DAStudio.message('SLDD:sldd:MigrateWaitMsg'));
                    else
                        waitbar(amount,obj.mWaitHandle);
                    end
                else
                    if isequal(0,obj.mWaitHandle)
                        obj.mWaitHandle=waitbar(amount,message);
                    else
                        waitbar(amount,obj.mWaitHandle,message);
                    end
                end
            catch E
                if isequal(E.identifier,'MATLAB:waitbar:InvalidSecondInput')
                    obj.mWaitHandle=0;
                end
            end
        end

        function rtnSchema=constructMigrationWithBWS(obj,DDMigrateChkboxName,...
            msgDetails,buttons)

            lastRow=1;
            colWidth=30;
            DDGroup=constructDDGroup(obj,DDMigrateChkboxName,...
            msgDetails,lastRow,colWidth);

            schema.DialogTitle=DAStudio.message('Simulink:dialog:SimpleMigrationDialogTitle');
            schema.DialogTag='SLDDMigrate';
            schema.StandaloneButtonSet={''};
            schema.Sticky=true;

            buttonCol=1;
            for i=1:numel(buttons)
                if~isempty(buttons{i}{1})
                    button.Type='pushbutton';
                    button.Name=DAStudio.message(buttons{i}{1});
                    button.Tag=['DictMigrateDlg_',buttons{i}{1}];
                    button.MatlabMethod='Simulink.dd.DictionaryMigrationDialog.buttonCB';
                    button.MatlabArgs={'%dialog',button.Tag,buttons{i}{2}};
                    button.RowSpan=[1,1];
                    button.ColSpan=[buttonCol,buttonCol];
                    items{buttonCol}=button;%#ok
                    buttonCol=buttonCol+1;
                end
            end

            lastRow=lastRow+1;
            spacer.Type='panel';
            spacer.Tag='spacer';
            spacer.RowSpan=[lastRow,lastRow];
            spacer.ColSpan=[1,colWidth];

            lastRow=lastRow+1;
            buttonGroup.Type='panel';
            buttonGroup.LayoutGrid=[1,colWidth];
            buttonGroup.Items=items;
            buttonGroup.RowSpan=[lastRow,lastRow];
            buttonGroup.ColSpan=[(colWidth-2),colWidth];

            schema.LayoutGrid=[lastRow,colWidth];
            schema.CloseArgs={'%dialog','%closeaction',''};
            schema.CloseCallback='Simulink.dd.DictionaryMigrationDialog.buttonCB';

            schema.RowStretch=[0,1,0];
            schema.Items={DDGroup,spacer};
            schema.Items=[schema.Items,{buttonGroup}];
            rtnSchema=schema;
        end

        function rtnGroup=constructDDGroup(obj,DDMigrateChkboxName,...
            msgDetails,lastRow,colWidth)
            DDGroupRow=1;
            if~isempty(DDMigrateChkboxName)
                DDMigrateChkbox.Name=DDMigrateChkboxName;
                DDMigrateChkbox.Tag='MigrateBWSData';
                DDMigrateChkbox.Type='checkbox';
                DDMigrateChkbox.Graphical=true;
                DDMigrateChkbox.Value=obj.migrateDD;
                DDMigrateChkbox.RowSpan=[DDGroupRow,DDGroupRow];
                DDMigrateChkbox.ColSpan=[1,10];
                DDMigrateChkbox.MatlabMethod='Simulink.dd.DictionaryMigrationDialog.chkboxCB';
                DDMigrateChkbox.MatlabArgs={'%dialog',DDMigrateChkbox.Tag};
                DDGroupRow=DDGroupRow+1;
            end

            msgNote.Name=DAStudio.message('SLDD:sldd:msgNote');
            msgNote.Type='text';
            msgNote.Tag='Note';
            msgNote.RowSpan=[DDGroupRow,DDGroupRow];
            msgNote.ColSpan=[1,5];
            DDGroupRow=DDGroupRow+1;

            if~isempty(msgDetails)
                details.Name=msgDetails;
                details.Type='text';
                details.WordWrap=true;
                details.Tag='Details';
                details.RowSpan=[DDGroupRow,DDGroupRow];
                details.ColSpan=[1,colWidth];
                DDGroupRow=DDGroupRow+1;
            end

            DDGroup.Type='panel';
            DDGroup.Name='Design data';
            DDGroup.LayoutGrid=[DDGroupRow,colWidth];
            DDGroup.RowSpan=[lastRow,lastRow];
            DDGroup.ColSpan=[1,colWidth];
            DDGroup.Items={};

            if~isempty(DDMigrateChkboxName)
                DDGroup.Items=[DDGroup.Items,{DDMigrateChkbox}];
            end
            DDGroup.Items=[DDGroup.Items,{msgNote}];
            if~isempty(msgDetails)
                DDGroup.Items=[DDGroup.Items,{details}];
            end
            rtnGroup=DDGroup;
        end
    end

    methods(Static,Access=public)
        function modelCloseListener(a,b,obj)
            try
                dialogs=DAStudio.ToolRoot.getOpenDialogs(obj);
                dialogs=dialogs';
                for dialog=dialogs
                    if isequal(obj,dialog.getSource)
                        dialog.delete;
                    end
                end
            catch
            end
        end
    end

    methods(Static)


        function buttonCB(dlg,closeaction,migrationaction)
            if isequal(closeaction,['DictMigrateDlg_','Simulink:editor:DialogOK'])||...
                isequal(closeaction,['DictMigrateDlg_','Simulink:editor:DialogYes'])||...
                isequal(closeaction,['DictMigrateDlg_','Simulink:editor:DialogApply'])||...
                isequal(closeaction,['DictMigrateDlg_','SLDD:sldd:MigrateLinkAllBtn'])||...
                isequal(closeaction,['DictMigrateDlg_','SLDD:sldd:MigrateLinkOneBtn'])
                hWait=waitbar(0,DAStudio.message('SLDD:sldd:MigrateWaitMsg'));

                dlg.hide;
                dlgsrc=dlg.getDialogSource;
                dlgsrc.performAction(migrationaction,hWait);
            elseif isequal(closeaction,['DictMigrateDlg_','Simulink:editor:DialogNo'])||...
                isequal(closeaction,['DictMigrateDlg_','Simulink:editor:DialogCancel'])
                dlgsrc=dlg.getDialogSource;
                dlgsrc.cleanup();
                dlgsrc.relaunchModelProps();
                dlgsrc.mDlgOpen=false;
                delete(dlg);
            elseif isequal(closeaction,'cancel')
                dlgsrc=dlg.getDialogSource;
                dlgsrc.cleanup();
                if dlgsrc.mDlgOpen
                    dlgsrc.relaunchModelProps();
                    dlgsrc.mDlgOpen=false;
                end
            elseif isequal(closeaction,['DictMigrateDlg_','SLDD:sldd:MigrateHelpBtn'])
                helpview([docroot,'/mapfiles/simulink.map'],migrationaction);
            elseif isequal(closeaction,['DictMigrateDlg_','SLDD:sldd:MigrateBtn'])
                checkHierarchy=dlg.getWidgetValue('SLDD:sldd:NewMigrateHierarchyMsg');
                if checkHierarchy
                    migrationaction='migrateHierarchyDataV2';
                else
                    migrationaction='migrateModelDataV2';
                end
                hWait=waitbar(0,DAStudio.message('SLDD:sldd:MigrateWaitMsg'));

                dlg.hide;
                dlgsrc=dlg.getDialogSource;
                dlgsrc.performAction(migrationaction,hWait);
            end
        end

        function chkboxCB(dlg,chkboxTag)
            obj=dlg.getDialogSource;
            if dlg.getWidgetValue(chkboxTag)
                obj.migrateDD=true;
            else
                obj.migrateDD=false;
            end
            dlg.refresh;
        end

        function closeProgress(hWait)
            if~isequal(0,hWait)
                try
                    close(hWait);
                catch
                end
            end
        end
    end

end
