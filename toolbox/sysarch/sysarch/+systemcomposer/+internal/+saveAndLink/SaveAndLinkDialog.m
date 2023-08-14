classdef SaveAndLinkDialog<systemcomposer.internal.mixin.ModelClose&...
    systemcomposer.internal.mixin.BlockDelete&...
    systemcomposer.internal.mixin.CenterDialog





    properties(Constant)
        SAVE_AS_ARCHITECTURE=1;
        CREATE_SIMULINK_BEHAVIOR=2;
        LINK_MODEL=3;
        INLINE_MODEL=4;
        INLINE_CHART=5;
        CREATE_SOFTWARE_ARCHITECTURE=6;
    end

    properties(Access=private)
        blockHandles;
        isImplComponent;
        dialogType;
        convertedBlockHandles;
        DialogInstance=[];
        templateInfos;
        isTemplatesEnabled;
        isDDEnabled;
        physicalPortExists=false;
        behaviorTypeEntries=[];
    end

    methods(Access=private)
        function this=SaveAndLinkDialog()

        end
    end

    methods(Static)
        function obj=instance()


            persistent instance
            if isempty(instance)||~isvalid(instance)
                instance=systemcomposer.internal.saveAndLink.SaveAndLinkDialog;
            end
            obj=instance;
        end

        function launch(blockHandles,dialogType)


            instance=systemcomposer.internal.saveAndLink.SaveAndLinkDialog.instance();
            instance.blockHandles=blockHandles;


            instance.registerCloseListener(get_param(bdroot(blockHandles{1}),'Handle'));


            instance.registerDeleteListener(blockHandles);



            instance.isImplComponent=false;
            for bH=blockHandles
                comp=systemcomposer.utils.getArchitecturePeer(bH{1});
                if comp.isImplComponent

                    instance.isImplComponent=true;
                    break;
                end
            end

            instance.dialogType=dialogType;

            if isempty(instance.DialogInstance)||~ishandle(instance.DialogInstance)
                instance.DialogInstance=DAStudio.Dialog(instance);
            else
                instance.DialogInstance.setWidgetValue('editFileName','');
            end


            instance.DialogInstance.show();
            instance.DialogInstance.refresh();
        end

        function tf=isConversionActive()
            instance=systemcomposer.internal.saveAndLink.SaveAndLinkDialog.instance();
            tf=instance.getIsBlockConverting();
        end
    end

    methods

        function schema=getDialogSchema(this)



            fileSchema=this.getSaveAndLinkSchema();
            fileSchema.RowSpan=[1,1];
            fileSchema.ColSpan=[1,2];

            panel.Type='panel';
            panel.Tag='main_panel';
            panel.Items={fileSchema};
            panel.LayoutGrid=[4,2];
            panel.RowStretch=[0,0,1,0];
            panel.ColStretch=[1,0];

            switch this.dialogType
            case this.SAVE_AS_ARCHITECTURE
                schema.DialogTitle=message('SystemArchitecture:SaveAndLink:SaveAsArchitectureName').string;
            case this.CREATE_SIMULINK_BEHAVIOR
                schema.DialogTitle=message('SystemArchitecture:SaveAndLink:CreateSimulinkBehaviorName').string;
            case this.LINK_MODEL
                schema.DialogTitle=message('SystemArchitecture:SaveAndLink:LinkToModelName').string;
            case this.INLINE_MODEL
                schema.DialogTitle=message('SystemArchitecture:SaveAndLink:InlineModelName').string;
            case this.CREATE_SOFTWARE_ARCHITECTURE
                schema.DialogTitle=message('SystemArchitecture:SaveAndLink:CreateSoftwareArchitectureName').string;
            case this.INLINE_CHART
                schema.DialogTitle=message('SystemArchitecture:SaveAndLink:InlineChartName').string;
            end
            schema.Items={panel};
            schema.DialogTag='system_composer_export_dialog';
            schema.Source=this;
            schema.SmartApply=true;
            schema.OpenCallback=@(dlg)this.handleOpenDialog(dlg);
            schema.PreApplyCallback='handlePreApply';
            schema.PreApplyArgs={this,'%dialog'};
            schema.CloseCallback='handleClose';
            schema.CloseArgs={this,'%dialog'};
            schema.HelpMethod='handleClickHelp';
            schema.HelpArgs={};
            schema.HelpArgsDT={};
            schema.StandaloneButtonSet={'Ok','Cancel','Help'};
            schema.MinMaxButtons=true;
            schema.ShowGrid=1;
            schema.DisableDialog=false;
            schema.AlwaysOnTop=true;
            schema.ExplicitShow=true;
        end

        function[isValid,msg]=handleClose(this,~)

            isValid=true;
            msg='';





            for i=1:numel(this.convertedBlockHandles)
                lhStruct=get_param(this.convertedBlockHandles(i),'LineHandles');
                lh=struct2array(lhStruct);
                lh=unique(lh);


                lh=lh(lh~=-1);
                if~isempty(lh)
                    childrenLines=[];
                    for line=lh
                        childrenLine=get_param(line,'LineChildren');
                        if~isempty(childrenLine)
                            childrenLines=[childrenLines;childrenLine];%#ok<AGROW>
                        end
                    end
                    if(~isempty(childrenLines))
                        lh=[lh,childrenLines'];%#ok<AGROW>
                    end
                    Simulink.BlockDiagram.routeLine(lh);
                end
            end
        end

        function[isValid,msg]=handlePreApply(this,dlg)

            isValid=true;
            msg='';
            this.convertedBlockHandles=[];







            this.blockHandles=this.validBlkHdls;

            if(this.dialogType~=this.INLINE_MODEL&&this.dialogType~=this.INLINE_CHART)
                if~(this.dialogType==this.CREATE_SIMULINK_BEHAVIOR&&this.isSelectedBehaviorType(dlg,'InlinedSubsystem'))

                    file=dlg.getWidgetValue('editFileName');

                    [filepath,nameNoExt,ext,isValid]=this.getFileParts(file);
                    if~isValid
                        msg=message('Simulink:LoadSave:InvalidBlockDiagramName',nameNoExt).string;
                        return
                    end
                end


                if(this.dialogType==this.LINK_MODEL)
                    fullpathfile=fullfile(filepath,[nameNoExt,ext]);
                    if exist(file,'file')==0&&...
                        exist(fullpathfile,'file')==0

                        isValid=false;
                        msg=message('Simulink:LoadSave:FileNotFound',fullfile(filepath,[nameNoExt,ext])).string;
                        return;

                    elseif(strcmp(get_param(this.blockHandles{1},'BlockType'),'ModelReference'))

                        oldModelName=get_param(this.blockHandles{1},'ModelName');
                        isSpecifiedName=isvarname(oldModelName);
                        if(strcmp(oldModelName,nameNoExt))

                            compName=get_param(this.blockHandles{1},'Name');
                            answer=this.showQuestDlg(dlg,...
                            message('SystemArchitecture:SaveAndLink:WarningModelAlreadyLinked',compName,oldModelName).string,...
                            message('SystemArchitecture:SaveAndLink:Warning').string,...
                            message('SystemArchitecture:SaveAndLink:Yes').string,...
                            message('SystemArchitecture:SaveAndLink:No').string,...
                            message('SystemArchitecture:SaveAndLink:No').string);

                            if answer~=message('SystemArchitecture:SaveAndLink:Yes').string
                                isValid=false;
                                return;
                            end
                        end



                        if isSpecifiedName
                            answer=this.showQuestDlg(dlg,...
                            message('SystemArchitecture:SaveAndLink:WarningBreakLink').string,...
                            message('SystemArchitecture:SaveAndLink:Warning').string,...
                            message('SystemArchitecture:SaveAndLink:Yes').string,...
                            message('SystemArchitecture:SaveAndLink:No').string,...
                            message('SystemArchitecture:SaveAndLink:No').string);

                            if answer~=message('SystemArchitecture:SaveAndLink:Yes').string
                                isValid=false;
                                return;
                            end
                            modelInfo=Simulink.MDLInfo(fullpathfile);
                            diagramType=modelInfo.BlockDiagramType;
                        end
                    else


                        modelInfo=Simulink.MDLInfo(fullpathfile);
                        diagramType=modelInfo.BlockDiagramType;

                        if~(strcmp(diagramType,'Model')||...
                            (strcmp(diagramType,'Subsystem')&&slfeature('ZCSubsystemReference')>0)||...
                            (strcmpi(ext,'.fmu')&&slfeature('ZCFMUComponent')>0)||...
                            strcmpi(ext,'.slxp'))
                            isValid=false;
                            msg=message('SystemArchitecture:SaveAndLink:OnlyModelsAllowedForLinking').string;
                            return;
                        end





                        for idx=1:numel(this.blockHandles)
                            bH=this.blockHandles{idx};
                            compName=get_param(bH,'Name');




                            objects=find_system(this.blockHandles{idx},'LookUnderMasks','on',...
                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
                            if numel(objects)>1




                                answer=this.showQuestDlg(dlg,...
                                message('SystemArchitecture:SaveAndLink:WarningContentLoss',compName).string,...
                                message('SystemArchitecture:SaveAndLink:Warning').string,...
                                message('SystemArchitecture:SaveAndLink:Yes').string,...
                                message('SystemArchitecture:SaveAndLink:No').string,...
                                message('SystemArchitecture:SaveAndLink:No').string);


                                if answer~=message('SystemArchitecture:SaveAndLink:Yes').string
                                    isValid=false;
                                    return;
                                end
                            end

                            comp=systemcomposer.utils.getArchitecturePeer(bH);
                            compArch=comp.getArchitecture();



                            prototypes=compArch.getResolvedPrototypes;
                            if~isempty(prototypes)



                                answer=this.showQuestDlg(dlg,...
                                message('SystemArchitecture:SaveAndLink:WarningStereotypeLoss',compName).string,...
                                message('SystemArchitecture:SaveAndLink:Warning').string,...
                                message('SystemArchitecture:SaveAndLink:Yes').string,...
                                message('SystemArchitecture:SaveAndLink:No').string,...
                                message('SystemArchitecture:SaveAndLink:No').string);


                                if answer~=message('SystemArchitecture:SaveAndLink:Yes').string
                                    isValid=false;
                                    return;
                                end
                            end

                            if~this.confirmDeleteSoftwareData(dlg,compArch)
                                isValid=false;
                                return;
                            end
                        end
                    end
                end


                if this.dialogType==this.SAVE_AS_ARCHITECTURE||...
                    (this.dialogType==this.CREATE_SIMULINK_BEHAVIOR&&~this.isSelectedBehaviorType(dlg,'InlinedSubsystem'))||...
                    this.dialogType==this.CREATE_SOFTWARE_ARCHITECTURE


                    topModelH=get_param(bdroot(this.blockHandles{1}),'Handle');
                    topModelDD=get_param(topModelH,'DataDictionary');
                    if isempty(topModelDD)&&systemcomposer.internal.modelHasLocallyScopedInterfaces(topModelH)



                        dictionaryName=dlg.getWidgetValue('editDD');

                        if~isempty(strtrim(dictionaryName))
                            this.saveInterfacesToNewDD(dictionaryName);
                        else

                            modelName=get_param(bdroot(this.blockHandles{1}),'Name');


                            if this.dialogType==this.SAVE_AS_ARCHITECTURE
                                q=message('SystemArchitecture:SaveAndLink:SaveAsArchLocalInterfacesExist',modelName).string;
                            elseif this.dialogType==this.CREATE_SOFTWARE_ARCHITECTURE
                                q=message('SystemArchitecture:SaveAndLink:CreateSoftwareArchLocalInterfacesExist',modelName).string;
                            else
                                q=message('SystemArchitecture:SaveAndLink:CreateSimBehLocalInterfacesExist',modelName).string;
                            end
                            answer=this.showQuestDlg(dlg,...
                            q,...
                            message('SystemArchitecture:SaveAndLink:LocalInterfacesExistWarning').string,...
                            message('SystemArchitecture:SaveAndLink:Yes').string,...
                            message('SystemArchitecture:SaveAndLink:No').string,...
                            message('SystemArchitecture:SaveAndLink:No').string);


                            if answer~=message('SystemArchitecture:SaveAndLink:Yes').string
                                isValid=false;
                                msg='';
                                return;
                            else

                                this.saveInterfacesToNewDD();



                                topModelDD=get_param(topModelH,'DataDictionary');
                                if isempty(topModelDD)&&systemcomposer.internal.modelHasLocallyScopedInterfaces(get_param(topModelH,'Handle'))
                                    isValid=false;
                                    msg='';
                                    return;
                                end
                            end
                        end
                    end


                    conversionValidator=systemcomposer.internal.TargetModelValidator(nameNoExt,filepath);
                    conversionValidator.popupDialog();
                    if~conversionValidator.canConvert()
                        isValid=false;
                        msg=conversionValidator.getErrorMessage();
                        dlg.show;
                        return;
                    end
                end


                pb=systemcomposer.internal.ProgressBar(...
                DAStudio.message('SystemArchitecture:studio:PleaseWait'),dlg);%#ok<NASGU>


                dlg.hide;

                try
                    switch this.dialogType
                    case this.SAVE_AS_ARCHITECTURE

                        this.setIsBlockConverting(true);
                        c=onCleanup(@()this.setIsBlockConverting(false));
                        if this.isSelectedBehaviorType(dlg,'SubsystemReference')

                            compToRefConverter=systemcomposer.internal.arch.internal.ComponentToArchitectureSubsystemReferenceConverter(...
                            this.blockHandles{1},...
                            nameNoExt,...
                            filepath);
                            this.convertedBlockHandles=compToRefConverter.convert();
                        else
                            templateVal=dlg.getWidgetValue('templateCombo');
                            if templateVal==0

                                compToRefConverter=systemcomposer.internal.arch.internal.ComponentToReferenceConverter(...
                                this.blockHandles{1},...
                                nameNoExt,...
                                filepath);
                            else

                                compToRefConverter=systemcomposer.internal.arch.internal.ComponentToReferenceConverter(...
                                this.blockHandles{1},...
                                nameNoExt,...
                                filepath,...
                                this.templateInfos{templateVal}.FileName);
                            end
                            this.convertedBlockHandles=compToRefConverter.convertComponentToReference();
                        end
                        delete(c);


                        if isempty(this.convertedBlockHandles)
                            isValid=false;
                            msg=message('SystemArchitecture:SaveAndLink:SaveAsArchitectureFailed').string;
                            dlg.show;
                            return;
                        end
                    case this.CREATE_SOFTWARE_ARCHITECTURE
                        templateVal=dlg.getWidgetValue('templateCombo');
                        if templateVal==0

                            compToRefConverter=systemcomposer.internal.arch.internal.ComponentToSoftwareArchitectureConverter(...
                            this.blockHandles{1},...
                            nameNoExt,...
                            systemcomposer.internal.GraphicalErrorReporter(),...
                            filepath);
                        else

                            compToRefConverter=systemcomposer.internal.arch.internal.ComponentToSoftwareArchitectureConverter(...
                            this.blockHandles{1},...
                            nameNoExt,...
                            systemcomposer.internal.GraphicalErrorReporter(),...
                            filepath,...
                            this.templateInfos{templateVal}.FileName);
                        end
                        this.setIsBlockConverting(true);
                        c=onCleanup(@()this.setIsBlockConverting(false));
                        this.convertedBlockHandles=compToRefConverter.convertComponentToReference();
                        delete(c);
                    case this.CREATE_SIMULINK_BEHAVIOR
                        templateVal=dlg.getWidgetValue('templateCombo');
                        if this.isSelectedBehaviorType(dlg,'InlinedSubsystem')

                        elseif this.isSelectedBehaviorType(dlg,'SubsystemReference')
                            compToImplConverter=systemcomposer.internal.arch.internal.ComponentToSubsystemReferenceConverter(this.blockHandles{1},...
                            nameNoExt,...
                            filepath);
                        else
                            template=[];
                            if templateVal~=0
                                template=this.templateInfos{templateVal}.FileName;
                            end

                            compToImplConverter=this.createImplConverterForArchitecture(...
                            this.blockHandles{1},nameNoExt,filepath,template);

                        end
                        this.setIsBlockConverting(true);
                        c=onCleanup(@()this.setIsBlockConverting(false));
                        if this.isSelectedBehaviorType(dlg,'InlinedSubsystem')
                            for idx=1:numel(this.blockHandles)
                                compToSSConverter=systemcomposer.internal.arch.internal.ComponentToImplSubsystemConverter(this.blockHandles{idx});
                                this.convertedBlockHandles(idx)=compToSSConverter.convert();
                            end
                        else
                            this.convertedBlockHandles=compToImplConverter.convertComponentToImpl();
                        end
                        delete(c);


                        if isempty(this.convertedBlockHandles)
                            isValid=false;
                            msg=message('SystemArchitecture:SaveAndLink:CreateSimulinkBehaviorFailed').string;
                            dlg.show;
                            return;
                        end
                    case this.LINK_MODEL
                        modelInfo=Simulink.MDLInfo(fullpathfile);
                        diagramType=modelInfo.BlockDiagramType;
                        if strcmpi(ext,'.slxp')
                            this.setIsBlockConverting(true);
                            c=onCleanup(@()this.setIsBlockConverting(false));
                            for idx=1:numel(this.blockHandles)
                                compToModelLinker=systemcomposer.internal.arch.internal.ComponentToModelLinker(this.blockHandles{idx},nameNoExt);
                                this.convertedBlockHandles=[this.convertedBlockHandles,...
                                compToModelLinker.linkComponentToModel()];
                            end
                            delete(c);
                        elseif slfeature('ZCFMUComponent')>0&&strcmpi(ext,'.fmu')

                            this.setIsBlockConverting(true);
                            c=onCleanup(@()this.setIsBlockConverting(false));
                            for idx=1:numel(this.blockHandles)
                                compToModelLinker=systemcomposer.internal.arch.internal.ComponentToFMULinker(this.blockHandles{idx},nameNoExt);
                                this.convertedBlockHandles=[this.convertedBlockHandles,...
                                compToModelLinker.linkComponentToFMU()];
                            end
                            delete(c);
                        elseif slfeature('ZCSubsystemReference')>0&&strcmp(diagramType,'Subsystem')
                            load_system(file);
                            this.setIsBlockConverting(true);
                            c=onCleanup(@()this.setIsBlockConverting(false));
                            for idx=1:numel(this.blockHandles)
                                compToSubsystemReferenceLinker=...
                                systemcomposer.internal.arch.internal.ComponentToSubsystemReferenceLinker(this.blockHandles{idx},nameNoExt);
                                this.convertedBlockHandles=[this.convertedBlockHandles,...
                                compToSubsystemReferenceLinker.linkComponentToSubsystemReference()];
                            end
                            delete(c);
                        else

                            load_system(file);

                            this.setIsBlockConverting(true);
                            c=onCleanup(@()this.setIsBlockConverting(false));
                            for idx=1:numel(this.blockHandles)
                                compToModelLinker=systemcomposer.internal.arch.internal.ComponentToModelLinker(this.blockHandles{idx},nameNoExt);
                                this.convertedBlockHandles=[this.convertedBlockHandles,...
                                compToModelLinker.linkComponentToModel()];
                            end
                            delete(c);
                        end
                    end
                catch me
                    isValid=false;
                    msg=me.message;
                    dlg.show;
                    return;
                end
                pb.setStatus(DAStudio.message('SystemArchitecture:studio:Complete'));%#ok<NASGU>
            else


                pb=systemcomposer.internal.ProgressBar(...
                DAStudio.message('SystemArchitecture:studio:PleaseWait'),dlg);


                dlg.hide;

                inlineInterfaceOnly=dlg.getWidgetValue('inlineTypeRadioButton');
                try
                    this.setIsBlockConverting(true);
                    c=onCleanup(@()this.setIsBlockConverting(false));
                    systemcomposer.internal.arch.internal.inlineComponent(cell2mat(this.blockHandles),~inlineInterfaceOnly);
                    delete(c)
                catch me
                    isValid=false;
                    msg=me.message;
                    dlg.show;
                    return;
                end

                pb.setStatus(DAStudio.message('SystemArchitecture:studio:Complete'));%#ok<NASGU>
            end
        end

        function handleClickBrowseButton(this,dlg)



            dlg.hide;

            switch this.dialogType
            case this.SAVE_AS_ARCHITECTURE
                newFileName=this.getUniqueSaveName(this.blockHandles{1});
                [file,cPath]=uiputfile({'*.slx;*.mdl'},...
                message('SystemArchitecture:SaveAndLink:SaveAsArchitectureName').string,...
                newFileName);
            case this.CREATE_SIMULINK_BEHAVIOR
                newFileName=this.getUniqueSaveName(this.blockHandles{1});
                [file,cPath]=uiputfile({'*.slx;*.mdl'},...
                message('SystemArchitecture:SaveAndLink:CreateSimulinkBehaviorName').string,...
                newFileName);
            case this.LINK_MODEL
                fileName=this.getUniqueLinkName();
                [file,cPath]=uigetfile({'*.slx;*.slxp;*.mdl'},...
                message('SystemArchitecture:SaveAndLink:LinkToModelName').string,...
                fileName);
            case this.CREATE_SOFTWARE_ARCHITECTURE
                newFileName=this.getUniqueSaveName(this.blockHandles{1});
                [file,cPath]=uiputfile({'*.slx;*.mdl'},...
                message('SystemArchitecture:SaveAndLink:CreateSoftwareArchitectureName').string,...
                newFileName);
            end


            dlg.show;

            if~isequal(file,0)&&~isequal(cPath,0)
                dlg.setWidgetValue('editFileName',fullfile(cPath,file));
            end
        end

        function handleClickBehaviorTypeButton(this,dlg)


            isEnabled=~this.isSelectedBehaviorType(dlg,'InlinedSubsystem');
            dlg.setEnabled('browseButton',isEnabled);
            dlg.setEnabled('editFileName',isEnabled);

            if this.isTemplatesEnabled
                dlg.setEnabled('templateCombo',isEnabled);
            end
            if this.isDDEnabled
                dlg.setEnabled('editDD',isEnabled);
            end
        end

        function handleClickHelp(this)


            switch this.dialogType
            case this.SAVE_AS_ARCHITECTURE
                helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'saveasarch');
            case this.CREATE_SIMULINK_BEHAVIOR
                helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'createsimulinkbehavior');
            case this.LINK_MODEL
                helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'linktomodel');
            case this.INLINE_MODEL
                helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'inlinemodel');
            case this.CREATE_SOFTWARE_ARCHITECTURE
                helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'createsoftwarearch');
            case this.INLINE_CHART
                helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'inlinechartbehavior');
            end
        end

        function handleOpenDialog(this,dlg)

            this.positionDialog(dlg,bdroot(this.blockHandles{1}));
        end
    end

    methods(Access=private)

        function saveInterfacesToNewDD(this,ddName)


            if nargin==1

                ddName=[];
            else

                [~,~,ext]=fileparts(ddName);
                if isempty(ext)
                    ddName=[ddName,'.sldd'];
                end
            end

            topModelH=get_param(bdroot(this.blockHandles{1}),'Handle');

            [bdOrDDName,interfaceCatalogStorageContext]=...
            systemcomposer.internal.getModelOrDDName(topModelH);




            if isempty(ddName)
                systemcomposer.InterfaceEditor.saveInterfacesToNewDD(...
                bdOrDDName,...
                interfaceCatalogStorageContext);
            else
                systemcomposer.InterfaceEditor.saveInterfacesToNewDD(...
                bdOrDDName,...
                interfaceCatalogStorageContext,...
                bdOrDDName,...
                ddName);
            end
        end

        function newFileName=getUniqueSaveName(~,blkHdl)




            startName=strrep(get_param(blkHdl,'Name'),' ','');
            newFileName=startName;
            count=1;
            while exist([newFileName,'.slx'],'file')
                newFileName=strcat(startName,'_',num2str(count));
                count=count+1;
            end
        end

        function newFileName=getUniqueDictionaryName(this)


            mdlName=get_param(bdroot(this.blockHandles{1}),'Name');
            startName=[strrep(get_param(mdlName,'Name'),' ',''),'DD'];
            newFileName=startName;
            count=1;
            while exist([newFileName,'.sldd'],'file')
                newFileName=strcat(startName,'_',num2str(count));
                count=count+1;
            end
        end

        function fileName=getUniqueLinkName(this)


            blockName=get_param(this.blockHandles{1},'Name');



            allSLXFiles=dir([blockName,'.slx']);
            if isempty(allSLXFiles)


                mdlName=get_param(bdroot(this.blockHandles{1}),'Name');

                allSLXFiles=dir('*.slx');

                allSLXFiles=allSLXFiles(~ismember({allSLXFiles.name},{[mdlName,'.slx']}));
            end

            if(isempty(allSLXFiles))

                fileName=strcat('<',message('SystemArchitecture:SaveAndLink:EnterLinkName').string,'>');
            else


                [~,nameNoExt,~]=fileparts(allSLXFiles(1).name);
                fileName=nameNoExt;
            end
        end

        function names=getAutoCompleteNames(this)


            ext='.slx';
            files=dir(['*',ext]);
            names={files.name};


            names=cellfun(@(x)erase(x,ext),names,...
            'UniformOutput',false);

            names=[names';find_system('type','block_diagram')];
            names=unique(names,'sorted');

            mdlName=get_param(bdroot(this.blockHandles{1}),'Name');
            names=names(~ismember(names,mdlName));
        end

        function schema=getSaveAndLinkSchema(this)



            isSave=false;



            hasLocallyDefinedInterfaces=false;

            row=1;
            col=1;

            topModelH=get_param(bdroot(this.blockHandles{1}),'Handle');
            topModelDD=get_param(topModelH,'DataDictionary');
            if isempty(topModelDD)&&systemcomposer.internal.modelHasLocallyScopedInterfaces(topModelH)
                hasLocallyDefinedInterfaces=true;
            end


            desc.Type='text';
            desc.Tag='txtDesc';
            desc.RowSpan=[row,row];
            desc.ColSpan=[col,col];
            switch this.dialogType
            case this.SAVE_AS_ARCHITECTURE
                desc.Name=message('SystemArchitecture:SaveAndLink:ArchitectureSaveDescription').string;
                isSave=true;
            case this.CREATE_SIMULINK_BEHAVIOR
                desc.Name=message('SystemArchitecture:SaveAndLink:CreateBehaviorDescription').string;
                isSave=true;
            case this.LINK_MODEL
                desc.Name=message('SystemArchitecture:SaveAndLink:LinkDescription').string;
            case this.INLINE_MODEL
                desc.Name=message('SystemArchitecture:SaveAndLink:InlineDescription').string;
            case this.CREATE_SOFTWARE_ARCHITECTURE
                desc.Name=message('SystemArchitecture:SaveAndLink:CreateSoftwareArchitectureDescription').string;
                isSave=true;
            case this.INLINE_CHART
                desc.Name=message('SystemArchitecture:SaveAndLink:WarningChartContentLoss').string;
            end

            row=row+1;


            if this.dialogType~=this.INLINE_MODEL&&this.dialogType~=this.INLINE_CHART
                inlinedSubsystemChosen=false;
                if this.dialogType==this.CREATE_SIMULINK_BEHAVIOR||(this.dialogType==this.SAVE_AS_ARCHITECTURE&&slfeature('ZCArchitectureSubsystem')>0)

                    behaviorTypeButton.Name="Type";
                    behaviorTypeButton.Type='combobox';
                    behaviorTypeButton.OrientHorizontal=false;
                    behaviorTypeButton.RowSpan=[row,row];
                    behaviorTypeButton.ColSpan=[col,col];
                    behaviorTypeButton.Tag='behaviorTypeButton';

                    blkHandle=this.blockHandles{1};
                    this.physicalPortExists=~isempty(find_system(blkHandle,'LookUnderMasks','on','SearchDepth',1,'BlockType','PMIOPort'));
                    [behaviorTypeButton,inlinedSubsystemChosen]=this.populateBehaviorTypeEntries(behaviorTypeButton);

                    behaviorTypeButton.ObjectMethod='handleClickBehaviorTypeButton';
                    behaviorTypeButton.MethodArgs={'%dialog'};
                    behaviorTypeButton.ArgDataTypes={'handle'};
                    row=row+1;
                end


                name.Type='edit';
                name.Tag='editFileName';
                if this.dialogType==this.LINK_MODEL
                    name.Name=message('SystemArchitecture:SaveAndLink:LinkName').string;
                else

                    name.Name=message('SystemArchitecture:SaveAndLink:SaveName').string;
                end
                name.NameLocation=1;
                name.Source=this;
                name.Graphical=true;
                name.Mode=true;
                name.RowSpan=[row,row];
                name.ColSpan=[col,col];
                name.ToolTip='';
                if isSave

                    name.Value=this.getUniqueSaveName(this.blockHandles{1});
                else

                    if(strcmp(get_param(this.blockHandles{1},'BlockType'),'ModelReference'))


                        name.Value=get_param(this.blockHandles{1},'ModelName');
                    else

                        name.Value=this.getUniqueLinkName();
                    end
                    name.AutoCompleteType='Custom';
                    name.AutoCompleteViewColumn={'Model name'};
                    name.AutoCompleteMatchOption='contains';
                    name.AutoCompleteViewData=this.getAutoCompleteNames();
                end


                col=col+1;
                browseButton.Type='pushbutton';
                browseButton.Tag='browseButton';
                browseButton.Source=this;
                browseButton.ObjectMethod='handleClickBrowseButton';
                browseButton.MethodArgs={'%dialog'};
                browseButton.ArgDataTypes={'handle'};
                browseButton.RowSpan=[row,row];
                browseButton.ColSpan=[col,col];
                browseButton.Enabled=true;
                browseButton.ToolTip='';
                browseButton.FilePath='';
                browseButton.Name=message('SystemArchitecture:SaveAndLink:Browse').string;



                if inlinedSubsystemChosen
                    name.Enabled=false;
                    browseButton.Enabled=false;
                end

                if isSave


                    row=row+1;
                    col=col-1;

                    this.templateInfos=[];

                    templateCombo.Type='combobox';
                    templateCombo.Tag='templateCombo';
                    if this.dialogType==this.SAVE_AS_ARCHITECTURE||this.dialogType==this.CREATE_SOFTWARE_ARCHITECTURE
                        templateCombo.Name=message('SystemArchitecture:SaveAndLink:FromArchTemplate').string;
                        templateCombo.ToolTip=DAStudio.message('SystemArchitecture:SaveAndLink:TemplateArchitectureTooltip');
                    else
                        templateCombo.Name=message('SystemArchitecture:SaveAndLink:FromSimTemplate').string;
                        templateCombo.ToolTip=DAStudio.message('SystemArchitecture:SaveAndLink:TemplateSimulinkBehaviorTooltip');
                    end
                    templateCombo.NameLocation=2;



                    [names,infos]=Simulink.findTemplates('*','Type','Model','Group','My Templates');
                    if~isempty(infos)
                        if this.dialogType==this.SAVE_AS_ARCHITECTURE||this.dialogType==this.CREATE_SOFTWARE_ARCHITECTURE

                            idxs=cell2mat(cellfun(@(x)isequal(x.Keywords,{'Architecture'}),infos,'UniformOutput',false));
                        else

                            idxs=cell2mat(cellfun(@(x)~isequal(x.Keywords,{'Architecture'}),infos,'UniformOutput',false));
                        end
                        this.templateInfos=infos(idxs);
                        fileNames=names(idxs);
                        [~,templateNames,~]=cellfun(@fileparts,fileNames,'UniformOutput',false);



                        templateCombo.Values=0:numel(templateNames);
                        templateCombo.Entries=[{message('SystemArchitecture:SaveAndLink:TemplateDefault').string},templateNames];
                        templateCombo.Enabled=true;
                    else

                        templateCombo.Values=0;
                        templateCombo.Entries={message('SystemArchitecture:SaveAndLink:TemplateDefault').string};
                        templateCombo.Enabled=false;
                    end

                    templateCombo.Value=message('SystemArchitecture:SaveAndLink:TemplateDefault').string;
                    templateCombo.Source=this;
                    templateCombo.Graphical=true;
                    templateCombo.RowSpan=[row,row];
                    templateCombo.ColSpan=[col,col];



                    row=row+1;
                    nameDD.Enabled=hasLocallyDefinedInterfaces;
                    nameDD.Type='edit';
                    nameDD.Tag='editDD';
                    nameDD.Name=DAStudio.message('SystemArchitecture:SaveAndLink:DictionaryName');
                    nameDD.NameLocation=2;
                    nameDD.Source=this;
                    nameDD.Graphical=true;
                    nameDD.Mode=true;
                    nameDD.RowSpan=[row,row];
                    nameDD.ColSpan=[col,col];
                    nameDD.ToolTip=DAStudio.message('SystemArchitecture:SaveAndLink:DictionaryNameTooltip');
                    if hasLocallyDefinedInterfaces


                        nameDD.Value=this.getUniqueDictionaryName();
                    else



                        nameDD.Value=topModelDD;
                    end
                end
            else

                row=row+1;
                inlineTypeRadioButton.Name=message('SystemArchitecture:SaveAndLink:Inline').string;
                inlineTypeRadioButton.Type='radiobutton';
                inlineTypeRadioButton.OrientHorizontal=false;
                inlineTypeRadioButton.RowSpan=[row,row];
                inlineTypeRadioButton.ColSpan=[1,1];
                inlineTypeRadioButton.Entries={
                message('SystemArchitecture:SaveAndLink:InlineAll').string,...
                message('SystemArchitecture:SaveAndLink:InlineInterface').string};
                inlineTypeRadioButton.Tag='inlineTypeRadioButton';
                if this.isImplComponent



                    inlineTypeRadioButton.Value=1;
                    inlineTypeRadioButton.Enabled=false;
                elseif this.dialogType==this.INLINE_CHART



                    inlineTypeRadioButton.Value=1;
                    inlineTypeRadioButton.Enabled=false;
                else



                    inlineTypeRadioButton.Value=0;
                    inlineTypeRadioButton.Enabled=true;
                end
            end

            schema.Type='group';
            schema.Name='';
            if this.dialogType==this.INLINE_MODEL||this.dialogType==this.INLINE_CHART
                schema.Items={desc,inlineTypeRadioButton};
            elseif isSave

                if this.dialogType==this.CREATE_SIMULINK_BEHAVIOR||(this.dialogType==this.SAVE_AS_ARCHITECTURE&&slfeature('ZCArchitectureSubsystem')>0)
                    hasBehaviorTypeButton=(slfeature('ZCInlineSubsystem')>0&&...
                    Simulink.internal.isArchitectureModel(topModelH,'Architecture'))||...
                    Simulink.internal.isArchitectureModel(topModelH,'SoftwareArchitecture');

                    if hasBehaviorTypeButton
                        behaviorTypeButton.ColSpan=[1,2];
                        templateCombo.ColSpan=[1,2];
                        nameDD.ColSpan=[1,2];
                        schema.Items={desc,behaviorTypeButton,name,browseButton,templateCombo,nameDD};
                    else
                        schema.Items={desc,name,browseButton,templateCombo,nameDD};
                    end
                else

                    schema.Items={desc,name,browseButton,templateCombo,nameDD};
                end
            else
                schema.Items={desc,name,browseButton};
            end
            schema.LayoutGrid=[1,col+1];
        end

        function answer=showQuestDlg(~,dlg,arg1,arg2,arg3,arg4,arg5)







            dlg.hide;
            answer=questdlg(arg1,arg2,arg3,arg4,arg5);
            dlg.show;
        end
        function deleteSoftwareData=confirmDeleteSoftwareData(this,dlg,compArch)








            deleteSoftwareData=true;
            trait=compArch.getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);
            if~isempty(trait)&&~isempty(trait.functions.toArray)




                answer=this.showQuestDlg(dlg,...
                message('SystemArchitecture:SaveAndLink:WarningFunctionLoss',compArch.getName()).string,...
                message('SystemArchitecture:SaveAndLink:Warning').string,...
                message('SystemArchitecture:SaveAndLink:Yes').string,...
                message('SystemArchitecture:SaveAndLink:No').string,...
                message('SystemArchitecture:SaveAndLink:No').string);


                if answer~=message('SystemArchitecture:SaveAndLink:Yes').string
                    deleteSoftwareData=false;
                end
            end
        end
        function tf=isSelectedBehaviorType(this,dlg,behaviorTypeString)
            tf=false;
            behaviorTypeIndex=dlg.getWidgetValue('behaviorTypeButton');
            if~isempty(behaviorTypeIndex)
                behaviorTypeIndex=behaviorTypeIndex+1;
                tf=this.behaviorTypeEntries{behaviorTypeIndex}==...
                message(['SystemArchitecture:SaveAndLink:',behaviorTypeString]).string;
            end
        end
        function[filepath,nameNoExt,ext,isValid]=getFileParts(~,file)

            [filepath,nameNoExt,ext]=fileparts(file);
            if(isempty(ext))
                if exist([file,'.slxp'],'file')
                    ext='.slxp';
                else
                    ext='.slx';
                end
            end


            if exist(file,'file')==0

                if(isempty(filepath))
                    filepath=fullfile(pwd);
                end
            end


            isValid=true;
            if~isvarname(nameNoExt)

                isValid=false;
            end
        end

        function[behaviorTypeButton,inlinedSubsystemChosen]=populateBehaviorTypeEntries(this,behaviorTypeButton)
            import systemcomposer.internal.arch.internal.*;

            behaviorTypeButton.Value=0;

            modelRefOpts={message('SystemArchitecture:SaveAndLink:ModelReference').string};
            if this.physicalPortExists
                modelRefOpts={};
            elseif Simulink.internal.isArchitectureModel(bdroot(this.blockHandles{1}),'SoftwareArchitecture')
                exportFunction=message('SystemArchitecture:SaveAndLink:ExportFunctionModel').string;
                rateBased=message('SystemArchitecture:SaveAndLink:RateBasedModel').string;
                modelRefOpts={exportFunction,rateBased};

                implType=getDefaultSoftwareComponentImplementation(this.blockHandles{1});
                assert(implType==ComponentImplementation.RateBased||...
                implType==ComponentImplementation.ExportFunction,...
                'Unexpected ComponentImplementation option');

                if implType==ComponentImplementation.RateBased
                    behaviorTypeButton.Value=1;
                end
            end

            inlinedSubsysString=message('SystemArchitecture:SaveAndLink:InlinedSubsystem').string;
            inlinedSubsysOpts={inlinedSubsysString};
            if~Simulink.internal.isArchitectureModel(bdroot(this.blockHandles{1}),'Architecture')
                inlinedSubsysOpts={};
            end

            subsysRefOpts={};
            if slfeature('ZCSubsystemReference')>0...
                &&Simulink.internal.isArchitectureModel(bdroot(this.blockHandles{1}),'Architecture')
                subsysRefOpts={message('SystemArchitecture:SaveAndLink:SubsystemReference').string};
            end

            if this.dialogType==this.SAVE_AS_ARCHITECTURE
                behaviorTypeButton.Entries=[...
                modelRefOpts,subsysRefOpts];
            else
                behaviorTypeButton.Entries=[...
                modelRefOpts,subsysRefOpts,inlinedSubsysOpts];
            end
            inlinedSubsystemChosen=strcmpi(behaviorTypeButton.Entries{1},inlinedSubsysString);

            this.behaviorTypeEntries=behaviorTypeButton.Entries;
        end

        function converter=createImplConverterForArchitecture(this,varargin)
            import systemcomposer.internal.arch.internal.ComponentImplementation;

            if Simulink.internal.isArchitectureModel(bdroot(this.blockHandles{1}),'SoftwareArchitecture')
                converter=systemcomposer.internal.arch.internal.SoftwareComponentToImplConverter(varargin{:});
                converter.setErrorReporter(systemcomposer.internal.GraphicalErrorReporter);

                if this.isSelectedBehaviorType(this.DialogInstance,'ExportFunctionModel')
                    converter.ImplementComponentAs=ComponentImplementation.ExportFunction;
                else
                    assert(this.isSelectedBehaviorType(this.DialogInstance,'RateBasedModel'));
                    converter.ImplementComponentAs=ComponentImplementation.RateBased;
                end
            else
                converter=systemcomposer.internal.arch.internal.ComponentToImplConverter(varargin{:});
            end
        end
    end
end
