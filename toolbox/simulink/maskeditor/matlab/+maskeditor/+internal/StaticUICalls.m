



classdef StaticUICalls

    methods(Static=true,Access='public')
        function onClickTutorial()
            web(fullfile('http://www.mathworks.com/videos/creating-a-mask-parameters-and-dialog-pane-120557.html'),'-browser');
        end

        function onClickHelp(aDocumentTitle,blockHandle)
            aHelpTopicId=[];

            if~isempty(aDocumentTitle)
                switch(aDocumentTitle)
                case message('maskeditor:Toolstrip:ParameterTabTitle').getString()
                    aHelpTopicId='id_table';
                case message('maskeditor:Toolstrip:InitializationTabTitle').getString()
                    aHelpTopicId='id_dvar';
                case message('maskeditor:Toolstrip:IconTabTitle').getString()
                    aHelpTopicId='icon_ports';
                case message('maskeditor:Toolstrip:DocumentationTabTitle').getString()
                    aHelpTopicId='id_masktyp';
                case message('maskeditor:Toolstrip:ConstraintsTabTitle').getString()
                    aHelpTopicId='constraint_manager';
                case 'ParameterPromotion'
                    aHelpTopicId='maskpromoteparamdialog';
                end
            end

            isSystemComposerContext=Simulink.internal.isArchitectureModel(bdroot(blockHandle))&&...
            (isempty(get_param(blockHandle,'Parent'))||~strcmpi(get_param(get_param(blockHandle,'Parent'),'SimulinkSubDomain'),'Simulink'));
            if isSystemComposerContext
                helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'parametereditor');
            else
                if~isempty(aHelpTopicId)
                    helpview([docroot,'/mapfiles/simulink.map'],aHelpTopicId);
                else
                    slprophelp('maskeditor');
                end
            end
        end

        function bSuccess=onSaveClick(aSystemHandle)
            bSuccess=maskeditor('Save',aSystemHandle);
        end

        function onDeleteClick(aSystemHandle)
            maskeditor('Unmask',aSystemHandle);
        end

        function onPreviewClick(aSystemHandle)
            aMaskObj=Simulink.Mask.get(aSystemHandle);
            if aMaskObj.isMaskWithDialog()
                aBlockHandle=maskeditor('GetBlockHandle',aSystemHandle);
                open_system(aBlockHandle,'mask');
            end
        end

        function onEvaluateClick(aSystemHandle)
            aDialog=maskeditor('Get',aSystemHandle);
            if~isempty(aDialog)
                aDialog.evaluateBlock();
            end
        end

        function[aMaskedBlocks]=onSearchMaskedBlock(aSearchString)
            aAllBlocks=slblocksearchdb.search(aSearchString);
            aMaskedBlocks={};
            for i=1:length(aAllBlocks)



                if~strcmp(aAllBlocks(i).BlockClass,aAllBlocks(i).BlockType)
                    aMaskedBlocks{end+1}=struct('BlockName',{aAllBlocks(i).BlockName},'BlockPath',{aAllBlocks(i).BlockPath});%#ok<AGROW> 
                end
            end
        end

        function onImportMaskedBlock(aSystemHandle,aBlockPathToImport)
            aDialog=maskeditor('Get',aSystemHandle);
            if~isempty(aDialog)
                aDialog.importMaskedBlock(aBlockPathToImport);
            end
        end

        function onShowBaseMaskClick(aSystemHandle)
            msgbox([aSystemHandle,': Not yet implemented']);
        end

        function onCreateMaskOnLinkClick(aSystemHandle)
            aDialog=maskeditor('Get',aSystemHandle);
            if~isempty(aDialog)
                if(aDialog.m_Context.isMaskOnSystemObject)
                    blockHandle=aDialog.m_Context.blockHandle;
                    maskeditor('Delete',aSystemHandle);
                    maskeditor('Create',blockHandle,false,true,false);
                    aDialog=maskeditor('GetMaskEditor',blockHandle);
                end
                aDialog.createMaskOnLink();
            end
        end

        function imageFile=onImportIconClick(aSystemHandle)
            imageFile="";
            [fileName,filePath]=uigetfile({'*.png;*jpg;*jpeg;*gif;*.svg'});
            if~isempty(fileName)&&all(fileName~=0)
                imageFile=fullfile(filePath,fileName);
            end
            aDialog=maskeditor('Get',aSystemHandle);
            aDialog.show();
        end

        function aTmpIconPath=getIconTempPath(aSystemHdl)
            aTmpIconPath=maskeditor.internal.iconpreview(aSystemHdl);
            if~isempty(aTmpIconPath)
                aTmpIconPath=matlab.ui.internal.URLUtils.getURLToUserFile(aTmpIconPath);
            else
                aTmpIconPath='';
            end
        end

        function aEnumOptions=getEnumerationOptions(aEnumClassFile)
            aEnumOption=Simulink.Mask.EnumerationTypeOptions;
            aEnumOption.ExternalEnumerationClass=aEnumClassFile;
            aEnumMembers=aEnumOption.EnumerationMembers;
            aEnumOptions=cell(length(aEnumMembers),1);
            for i=1:length(aEnumMembers)
                aEnumOptions{i}.MemberName=aEnumMembers(i).MemberName;
                aEnumOptions{i}.DescriptiveName=aEnumMembers(i).DescriptiveName;
                aEnumOptions{i}.Value=aEnumMembers(i).Value;
            end
        end

        function aValidationStatus=validate(aSystemHandle)
            aDialog=maskeditor('Get',aSystemHandle);
            if~isempty(aDialog)
                aValidationStatus=maskeditor.internal.validate(aDialog,aSystemHandle);
            end
        end

        function aTranslatedMsg=getTranslatedString(aMessageId)
            try
                aTranslatedMsg=message(aMessageId).string;
            catch
                aTranslatedMsg=aMessageId;
            end
        end

        function aEnabledFlags=getToolstripItemsEnability(aSystemHandle)
            aEnabledFlags=[];
            aDialog=maskeditor('Get',aSystemHandle);
            if isempty(aDialog)
                return;
            end

            aEnabledFlags.unmask=~aDialog.m_MEData.context.readOnly;
            aEnabledFlags.create=false;

            [aMaskObj,bCanCreateNewMask]=Simulink.Mask.get(aSystemHandle);
            if isempty(aMaskObj)
                aEnabledFlags.unmask=false;
            elseif bCanCreateNewMask
                aEnabledFlags.create=~aDialog.m_Context.isMaskOnMask;
            end
        end

    end
end


