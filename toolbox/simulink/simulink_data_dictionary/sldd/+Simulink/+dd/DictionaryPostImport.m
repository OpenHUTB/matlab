



classdef DictionaryPostImport<handle
    properties
        mSourceFile='';
        mImportedList='';
        mModelEnumTypesList={};
        mExistingList='';
        mUnsupportedList='';
        mConflictsList='';
        mDDConn='';
    end

    methods

        function obj=DictionaryPostImport(ddConn,importedList,modelEnumTypesList,existingList,unsupportedList,conflictsList,sourceFile)
            obj.mDDConn=ddConn;
            obj.mSourceFile=sourceFile;
            obj.mImportedList=importedList;
            obj.mModelEnumTypesList=modelEnumTypesList;
            obj.mExistingList=existingList;
            obj.mUnsupportedList=unsupportedList;
            if~isempty(conflictsList)
                obj.mConflictsList=conflictsList(:,1);
            end
        end

        function schema=getDialogSchema(obj)
            image.Type='image';
            image.Tag='image';
            image.RowSpan=[1,1];
            image.ColSpan=[1,1];
            image.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','dialog_info_32.png');

            if isempty(obj.mExistingList)&&isempty(obj.mConflictsList)
                justDupList={};
            elseif isempty(obj.mConflictsList)
                justDupList=obj.mExistingList;
            else
                justDupList=setxor(obj.mExistingList,obj.mConflictsList);
            end
            if isempty(obj.mSourceFile)
                description.Name=DAStudio.message('SLDD:sldd:ImportResultsBWS',length(obj.mImportedList));
            else
                description.Name=DAStudio.message('SLDD:sldd:ImportResults',length(obj.mImportedList));
            end
            description.WordWrap=false;
            description.Type='text';
            description.Tag='DictImportResults_GeneralMsg';
            description.RowSpan=[1,1];
            description.ColSpan=[2,4];


            detailDesc.Name=DAStudio.message('SLDD:sldd:ImportResultsUnimported',...
            length([justDupList;obj.mConflictsList;obj.mUnsupportedList]));
            detailDesc.Type='text';
            detailDesc.Tag='DictImportResults_detailDesc';
            detailDesc.RowSpan=[2,2];
            detailDesc.ColSpan=[2,4];

            details.Type='spreadsheet';
            details.Columns={DAStudio.message('SLDD:sldd:Unimported_Vars_ColumnName'),...
            DAStudio.message('SLDD:sldd:Unimported_Reason_ColumnName'),...
            DAStudio.message('SLDD:sldd:Unimported_AdditionalDetails_ColumnName')};
            details.Tag='slddUnimportedList_tag';
            ssSource=Simulink.dd.UnimportedSpreadSheetSource(details.Tag,justDupList,obj.mConflictsList,obj.mUnsupportedList);
            details.Source=ssSource;
            details.ColSpan=[2,4];
            details.RowSpan=[3,3];

            spacer.Name='                                         ';
            spacer.Type='text';
            spacer.Tag='spacer';
            spacer.RowSpan=[2,2];
            spacer.ColSpan=[4,4];

            spacer2.Name='                                        ';
            spacer2.Type='text';
            spacer2.Tag='spacer';
            spacer2.RowSpan=[2,2];
            spacer2.ColSpan=[3,3];

            question.Name=DAStudio.message('SLDD:sldd:RemoveImported');
            question.Type='text';
            question.WordWrap=true;
            question.Tag='DictImportResults_Question';
            question.ColSpan=[2,5];
            question.Alignment=9;

            btnYes.Type='pushbutton';
            btnYes.Tag='Simulink:editor:DialogYes';
            btnYes.Name=DAStudio.message(btnYes.Tag);
            btnYes.MatlabMethod='Simulink.dd.DictionaryPostImport.buttonCB';
            btnYes.MatlabArgs={'%dialog',btnYes.Tag};
            btnYes.RowSpan=[1,1];
            btnYes.ColSpan=[1,1];

            btnNo.Type='pushbutton';
            btnNo.Tag='Simulink:editor:DialogNo';
            btnNo.Name=DAStudio.message(btnNo.Tag);
            btnNo.MatlabMethod='Simulink.dd.DictionaryPostImport.buttonCB';
            btnNo.MatlabArgs={'%dialog',btnNo.Tag};
            btnNo.RowSpan=[1,1];
            btnNo.ColSpan=[2,2];

            buttons.Type='panel';
            buttons.Tag='buttonPanel';
            buttons.Items={btnYes,btnNo};
            buttons.LayoutGrid=[1,2];

            if isempty(obj.mSourceFile)
                schema.DialogTitle=DAStudio.message('SLDD:sldd:ImportFromBaseWorkspace');
                if isempty(obj.mImportedList)
                    bAllowRemove=false;
                else
                    bAllowRemove=true;
                end
            else
                schema.DialogTitle=DAStudio.message('SLDD:sldd:ImportFromFile');
                bAllowRemove=false;
            end

            schema.Items={image,description};

            if~isempty(obj.mConflictsList)
                schema.Items=[schema.Items,detailDesc,details];
            else
                schema.Items=[schema.Items,spacer,spacer2];
            end

            if bAllowRemove
                schema.StandaloneButtonSet={''};
                if~isempty(obj.mConflictsList)
                    question.RowSpan=[4,4];
                    buttons.RowSpan=[5,5];
                    buttons.ColSpan=[4,5];
                else
                    question.RowSpan=[2,2];
                    buttons.RowSpan=[3,3];
                    buttons.ColSpan=[4,5];
                end
                schema.Items=[schema.Items,question,buttons];
            else
                spacer.RowSpan=[2,2];
                schema.Items=[schema.Items,spacer,spacer2];
                schema.StandaloneButtonSet={'OK'};
            end

            schema.CloseArgs={'%dialog','%closeaction'};
            schema.CloseCallback='Simulink.dd.DictionaryPostImport.closeCB';

            schema.DialogTag='DictPostImport';
            schema.Sticky=true;
            schema.LayoutGrid=[4,6];
            schema.DisplayIcon=fullfile('toolbox','shared','dastudio','resources','DictionaryIcon.png');

        end

        function clearImported(obj)
            if~isempty(obj.mImportedList)
                for i=1:numel(obj.mImportedList)
                    evalin('base',sprintf('clearvars %s',obj.mImportedList{i}));
                end
            end
        end

    end

    methods(Static)

        function buttonCB(dialogH,btnTag)
            dlgsrc=dialogH.getDialogSource;
            if isequal(btnTag,'Simulink:editor:DialogYes')
                dlgsrc.clearImported();
            end

            delete(dialogH);
        end

        function closeCB(dialogH,closeAction)
            dlgsrc=dialogH.getDialogSource;

            enumMigrationDlg=[];

            if isempty(dlgsrc.mImportedList)
                enumTypesOfImportedItems={};
            else
                enumTypesOfImportedItems=...
                dlgsrc.mDDConn.getEnumeratedTypeDependencies(dlgsrc.mImportedList);
            end


            enumTypeExists=false(1,length(dlgsrc.mModelEnumTypesList));
            for i=1:numel(dlgsrc.mModelEnumTypesList)
                enumTypeExists(i)=dlgsrc.mDDConn.entryExists(...
                ['Global.',dlgsrc.mModelEnumTypesList{i}],false);
            end
            enumTypesOfModels=dlgsrc.mModelEnumTypesList(~enumTypeExists);

            enumTypes=union(enumTypesOfImportedItems,enumTypesOfModels);
            if~isempty(enumTypes)


                if isempty(dlgsrc.mModelEnumTypesList)
                    enumTypesSource=DAStudio.message(...
                    'SLDD:sldd:EnumTypeMigrationSourceImportedItems');
                else
                    enumTypesSource=DAStudio.message(...
                    'SLDD:sldd:EnumTypeMigrationSourceMigratedModels');
                end

                [~,n,e]=fileparts(dlgsrc.mDDConn.filespec);
                ddName=[n,e];

                enumMigrationDlg=Simulink.dd.DictionaryEnumTypeMigration(...
                enumTypes,enumTypesSource,ddName);
            end

            if~isempty(enumMigrationDlg)
                DAStudio.Dialog(enumMigrationDlg,'','DLG_STANDALONE');
            end
        end

    end

end


