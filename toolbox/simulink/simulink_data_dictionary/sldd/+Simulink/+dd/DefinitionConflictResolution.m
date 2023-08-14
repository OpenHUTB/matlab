

classdef DefinitionConflictResolution<handle
    properties
        mAction='';
        mEntryName='';
        mFromDD='';
        mFromEntryId=0;
        mToDDs={};
        mToEntryIds=[];
    end

    methods

        function obj=DefinitionConflictResolution(...
            action,entryName,fromDD,fromEntryId,toDDs,toEntryIds)
            obj.mAction=action;
            obj.mEntryName=entryName;
            obj.mFromDD=fromDD;
            obj.mFromEntryId=fromEntryId;
            obj.mToDDs=toDDs;
            obj.mToEntryIds=toEntryIds;

            assert(strcmp(obj.mAction,'copy')||...
            strcmp(obj.mAction,'delete'));
        end

        function schema=getDialogSchema(obj)
            [~,ddName,ddExt]=fileparts(obj.mFromDD);
            if strcmp(ddName,'base workspace')
                ddName=DAStudio.message('SLDD:sldd:BaseWorkspace');
            end

            if strcmp(obj.mAction,'copy')
                introID='SLDD:sldd:DuplicateSymbolResolutionDDGIntro';
                DialogTitleID='SLDD:sldd:DuplicateSymbolResolutionDDGTitle';
            else
                introID='SLDD:sldd:DuplicateSymbolRemoveDDGIntro';
                DialogTitleID='SLDD:sldd:DuplicateSymbolRemoveDDGTitle';
            end

            image.Type='image';
            image.Tag='image';
            image.RowSpan=[1,1];
            image.ColSpan=[1,1];
            image.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','dialog_info_32.png');

            intro.Name=DAStudio.message(introID,obj.mEntryName,[ddName,ddExt]);
            intro.WordWrap=true;
            intro.Type='text';
            intro.Tag='DefConflictRes_intro';
            intro.RowSpan=[1,2];
            intro.ColSpan=[2,5];

            btnOK.Type='pushbutton';
            btnOK.Tag='Simulink:editor:DialogOK';
            btnOK.Name=DAStudio.message('Simulink:editor:DialogOK');
            btnOK.MatlabMethod='Simulink.dd.DefinitionConflictResolution.buttonCB';
            btnOK.MatlabArgs={'%dialog',btnOK.Tag};
            btnOK.RowSpan=[3,3];
            btnOK.ColSpan=[4,4];

            btnCancel.Type='pushbutton';
            btnCancel.Tag='Simulink:editor:DialogCancel';
            btnCancel.Name=DAStudio.message('Simulink:editor:DialogCancel');
            btnCancel.MatlabMethod='Simulink.dd.DefinitionConflictResolution.buttonCB';
            btnCancel.MatlabArgs={'%dialog',btnCancel.Tag};
            btnCancel.RowSpan=[3,3];
            btnCancel.ColSpan=[5,5];


            schema.DialogTitle=DAStudio.message(DialogTitleID);

            schema.Items={image,intro};

            schema.Items=[schema.Items,btnOK,btnCancel];

            schema.StandaloneButtonSet={''};

            schema.DialogTag='DefinitionConflictResolution';
            schema.Sticky=true;
            schema.LayoutGrid=[3,5];
            schema.DisplayIcon=fullfile('toolbox','shared','dastudio','resources','DictionaryIcon.png');

            schema.CloseArgs={'%dialog','%closeaction'};
            schema.CloseCallback='Simulink.dd.DefinitionConflictResolution.closeCB';

        end

    end

    methods(Static)

        function launchDialog(action,entryName,fromDD,fromEntryId,toDDs,toEntryIds)
            conflictResDlg=Simulink.dd.DefinitionConflictResolution(...
            action,entryName,fromDD,fromEntryId,toDDs,toEntryIds);
            DAStudio.Dialog(conflictResDlg,'','DLG_STANDALONE');
        end

        function buttonCB(dialogH,btnTag)
            if strcmp(btnTag,'Simulink:editor:DialogOK')
                dlgsrc=dialogH.getDialogSource;

                if strcmp(dlgsrc.mAction,'copy')
                    Simulink.dd.copyDefinitionToDDs(...
                    dlgsrc.mFromDD,dlgsrc.mFromEntryId,...
                    dlgsrc.mToDDs,dlgsrc.mToEntryIds,...
                    dlgsrc.mEntryName);
                else
                    Simulink.dd.deleteDefinitions(...
                    dlgsrc.mToDDs,dlgsrc.mToEntryIds,...
                    dlgsrc.mEntryName);
                end
            end
            delete(dialogH);
        end

        function closeCB(~,~)
        end

    end

end
