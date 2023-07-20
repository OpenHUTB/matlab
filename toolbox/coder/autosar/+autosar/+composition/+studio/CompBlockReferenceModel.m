classdef CompBlockReferenceModel<handle




    properties(Access=private)
        CompBlockH;
        ModelBlockH;
    end

    properties(Hidden,Constant)
        LinkToModelDialogTag='AutosarLinkToModelDialogTag';
        ModelFileNameTag='ModelFileName';
        LinkToSimulinkModelTitleID='autosarstandard:editor:LinkToSimulinkModelTitle';
    end

    properties(SetAccess=immutable,GetAccess=private)
        CloseModelListener;
    end

    methods(Static)
        function launchModelLinkingWizard(linkInfo)

            autosar.api.Utils.autosarlicensed(true);


            autosar.ui.app.link.ModelLinkingWizardManager.launchWizard(linkInfo);
        end


        function launchDialog(compBlkH)

            modelCreator=autosar.composition.studio.CompBlockReferenceModel(compBlkH);
            dlg=DAStudio.Dialog(modelCreator);
            dlg.show();
        end

        function[isValid,msgId,msg]=validateModel(modelName,compBlkH)


            msgId='';
            msg='';

            isUIMode=true;
            compToModelLinker=autosar.composition.studio.AUTOSARComponentToModelLinker(compBlkH,modelName,isUIMode);


            try
                isValid=compToModelLinker.validatePreLinking();
            catch me
                isValid=false;
                msg=me.message;
                msgId=me.identifier;
                return;
            end
        end
    end

    methods

        function this=CompBlockReferenceModel(compBlkH)
            this.CompBlockH=get_param(compBlkH,'Handle');

            parentCompositionH=get_param(bdroot(compBlkH),'Handle');
            this.CloseModelListener=Simulink.listener(parentCompositionH,...
            'CloseEvent',@CloseModelCB);
        end


        function schema=getDialogSchema(this)


            autosar.api.Utils.autosarlicensed(true);

            row=1;
            col=1;


            desc.Type='text';
            desc.Tag='txtDesc';
            desc.RowSpan=[row,row];
            desc.ColSpan=[col,col+1];
            desc.Name=message('autosarstandard:editor:LinkToSimulinkModelDescription').getString();

            row=row+1;


            name.Type='edit';
            name.Tag=this.ModelFileNameTag;
            name.Name=message('autosarstandard:editor:ModelNamePrompt').getString();
            name.NameLocation=1;
            name.Source=this;
            name.Graphical=true;
            name.Mode=true;
            name.RowSpan=[row,row];
            name.ColSpan=[col,col];

            name.Value=...
            autosar.composition.studio.CompBlockReferenceModel.getUniqueLinkName(this.CompBlockH);
            name.MinimumSize=[200,25];
            name.ToolTip=message('autosarstandard:editor:AutoCompleteTooltip').getString();
            name.AutoCompleteType='Custom';
            name.AutoCompleteViewColumn={'Model name'};
            name.AutoCompleteMatchOption='contains';
            parentCompositionName=get_param(bdroot(this.CompBlockH),'Name');
            isCompositionBlock=autosar.composition.Utils.isCompositionBlock(this.CompBlockH);
            name.AutoCompleteViewData=...
            autosar.composition.studio.CompBlockReferenceModel.getAutoCompleteData(...
            parentCompositionName,isCompositionBlock);

            col=col+1;
            browseButton.Type='pushbutton';
            browseButton.Tag='browseButton';
            browseButton.Source=this;
            browseButton.ObjectMethod='browseCB';
            browseButton.MethodArgs={'%dialog'};
            browseButton.ArgDataTypes={'handle'};
            browseButton.RowSpan=[row,row];
            browseButton.ColSpan=[col,col];
            browseButton.Enabled=true;
            browseButton.ToolTip='';
            browseButton.FilePath='';
            browseButton.Name=message('autosarstandard:editor:Browse').getString();

            group.Type='group';
            group.Name='';
            group.Items={desc,name,browseButton};
            group.LayoutGrid=[1,col+1];

            group.RowSpan=[1,1];
            group.ColSpan=[1,2];

            panel.Type='panel';
            panel.Tag='main_panel';
            panel.Items={group};
            panel.LayoutGrid=[4,2];
            panel.RowStretch=[0,0,1,0];
            panel.ColStretch=[1,0];

            schema.DialogTitle=message(this.LinkToSimulinkModelTitleID).getString();
            schema.Items={panel};
            schema.DialogTag=this.LinkToModelDialogTag;
            schema.Source=this;
            schema.SmartApply=true;
            schema.PreApplyCallback='preApplyCB';
            schema.PreApplyArgs={this,'%dialog'};
            schema.CloseCallback='closeCB';
            schema.CloseArgs={this,'%dialog'};
            schema.StandaloneButtonSet={'Ok','Cancel'};
            schema.MinMaxButtons=true;
            schema.ShowGrid=1;
            schema.DisableDialog=false;
            schema.Sticky=true;
        end

        function[isValid,msg]=preApplyCB(this,dlg)




            this.ModelBlockH=[];


            modelToLink=dlg.getWidgetValue(this.ModelFileNameTag);

            try

                autosar.api.Utils.autosarlicensed(true);



                [isValid,msg]=this.referenceModel(modelToLink);
            catch me
                isValid=false;
                msg=me.message;
                return;
            end
        end


        function[isValid,msg]=closeCB(this,~)
            isValid=true;
            msg='';


            if~isempty(this.ModelBlockH)&&ishandle(this.ModelBlockH)
                autosar.composition.studio.CompBlockUtils.routeLinesForBlk(this.ModelBlockH);
            end
        end

        function browseCB(this,dlg)
            [modelName,modelPath]=uigetfile(...
            {'*.slx','(*.slx)';...
            '*.mdl','(*.mdl)';...
            '*.*','All files'},...
            message('autosarstandard:editor:LinkToSimulinkModelTitle').getString(),'');

            if~isequal(modelName,0)&&~isequal(modelPath,0)
                dlg.setWidgetValue(this.ModelFileNameTag,fullfile(modelPath,modelName));
            end
        end
    end


    methods(Hidden,Access=public)


        function[success,msg,mdlBlkH]=referenceModel(this,modelToLink)
            import autosar.composition.studio.AUTOSARComponentToModelLinker

            compBlkH=this.CompBlockH;
            mdlBlkH=[];
            msg='';
            success='';

            isUIMode=true;
            compToModelLinker=AUTOSARComponentToModelLinker(compBlkH,modelToLink,isUIMode);


            compToModelLinker.LinkingValidator.validateModelValidForLinking();


            unlinkedModelH=load_system(modelToLink);


            valMsgs=compToModelLinker.LinkingValidator.validateRequirements();


            if~isempty(valMsgs.failures.complianceFail)||~isempty(valMsgs.failures.mappingFail)
                qFlags.quickStart=true;
            else
                qFlags.quickStart=false;
            end





            qFlags.linking=any(~structfun(@isempty,valMsgs.failures))...
            ||any(~structfun(@isempty,valMsgs.warnings));

            if qFlags.quickStart||qFlags.linking

                linkInfo.modelToLink=modelToLink;
                linkInfo.unlinkedModelH=unlinkedModelH;
                linkInfo.valMsgs=valMsgs;
                linkInfo.qFlags=qFlags;
                linkInfo.compBlkH=this.CompBlockH;
                autosar.composition.studio.CompBlockReferenceModel.launchModelLinkingWizard(linkInfo);
            else

                linkModel(this,compToModelLinker);
                success=true;
            end
        end
    end

    methods(Access=private)
        function mdlBlkH=linkModel(this,compToModelLinker)

            pb=Simulink.internal.ScopedProgressBar(...
            DAStudio.message('autosarstandard:editor:ReferencingModelProgressMessage'));%#ok<NASGU>


            guard=systemcomposer.internal.saveAndLink.ComponentSaveLinkViaUIGuard();
            this.ModelBlockH=compToModelLinker.linkComponentToModel();
            delete(guard);

            mdlBlkH=this.ModelBlockH;
        end
    end

    methods(Static,Access=private)



        function fileName=getUniqueLinkName(compBlkH)
            if(strcmp(get_param(compBlkH,'BlockType'),'ModelReference'))

                fileName=get_param(compBlkH,'ModelName');
            else

                fileName=strcat('<',message('autosarstandard:editor:EnterModelName').string,'>');
            end
        end
    end

    methods(Hidden,Static)
        function modelNames=getAutoCompleteData(parentCompositionName,forComposition)
            if nargin<2
                forComposition=false;
            end


            supportedFileExtensions={'.slx','.mdl'};
            rawModelNames=cellfun(@(x)...
            autosar.composition.studio.CompBlockReferenceModel.getModelNamesWithExtension(x),...
            supportedFileExtensions,'UniformOutput',false);
            rawModelNames=cat(2,rawModelNames{:});


            rawModelNames=cellfun(@(x)erase(x,supportedFileExtensions),rawModelNames,...
            'UniformOutput',false);


            rawModelNames=[rawModelNames';find_system('type','block_diagram')];
            rawModelNames=unique(rawModelNames,'sorted');


            rawModelNames=setdiff(rawModelNames,parentCompositionName);
            modelNames={};
            for modelIdx=1:length(rawModelNames)
                curModelName=rawModelNames{modelIdx};

                if isvarname(curModelName)

                    if bdIsLoaded(curModelName)
                        if forComposition
                            if~autosar.composition.Utils.isModelInCompositionDomain(curModelName)
                                continue
                            end
                        else
                            if~autosar.api.Utils.isMappedToComponent(curModelName)

                                continue;
                            end
                        end
                    else



                        modelinfo=Simulink.MDLInfo(curModelName);
                        mdlItf=modelinfo.Interface;
                        fileFormat=Simulink.loadsave.identifyFileFormat(curModelName);
                        if~isempty(mdlItf)&&...
                            strcmpi(mdlItf.SimulinkSubDomainType,'AUTOSARArchitecture')&&...
                            ~forComposition
                            continue;
                        elseif strcmp(fileFormat,'mdl')

                            continue
                        end
                    end

                    modelNames{end+1}=curModelName;%#ok<AGROW>
                else

                end
            end
        end

        function rawModelNames=getModelNamesWithExtension(fileExtension)

            modelFiles=dir(['*',fileExtension]);
            rawModelNames={modelFiles.name};
        end
    end
end


function CloseModelCB(eventSrc,~)
    root=DAStudio.ToolRoot;
    arDialog=root.getOpenDialogs.find('dialogTag',...
    autosar.composition.studio.CompBlockReferenceModel.LinkToModelDialogTag);
    for i=1:length(arDialog)
        dlgSrc=arDialog.getDialogSource();
        modelH=get_param(bdroot(dlgSrc.CompBlockH),'Handle');
        if modelH==eventSrc.Handle
            dlgSrc.delete;
            break;
        end
    end
end



