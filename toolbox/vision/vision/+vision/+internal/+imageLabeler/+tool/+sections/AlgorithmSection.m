





classdef AlgorithmSection<vision.internal.labeler.tool.sections.AlgorithmSection

    properties
        IsBlockedImageLabelingMode(1,1)logical=false
    end

    methods
        function this=AlgorithmSection(tool)
            this=this@vision.internal.labeler.tool.sections.AlgorithmSection(tool);
            this.Tool=tool;
        end
    end

    methods


        function refreshAlgorithmList(this)
            import matlab.ui.internal.toolstrip.*;

            repo=getAlgorithmRepository(this);
            repo.refresh();


            names=cell(1,repo.Count);
            desc=cell(1,repo.Count);
            for idx=1:repo.Count
                names{idx}=repo.getAlgorithmNameByIndex(idx);
                desc{idx}=repo.getAlgorithmDescription(idx);
            end

            this.AlgorithmPopupList={};

            if~this.IsBlockedImageLabelingMode

                this.AlgorithmPopupList{1}=PopupListHeader(vision.getMessage('vision:imageLabeler:WholeImageAutomationHeader'));

                for idx=1:repo.Count




                    if~repo.isBlockedAutomationAlgorithm(idx)
                        this.AlgorithmPopupList{end+1}=ListItem(names{idx});
                        this.AlgorithmPopupList{end}.Description=desc{idx};
                        this.AlgorithmPopupList{end}.Tag=names{idx};
                    end
                end


                if~isdeployed()
                    text=vision.getMessage('vision:imageLabeler:AddWholeImageAlgorithm');
                    icon=matlab.ui.internal.toolstrip.Icon.ADD_16;

                    this.AlgorithmPopupList{end+1}=ListItemWithPopup(text,icon);
                    this.AlgorithmPopupList{end}.ShowDescription=false;
                    this.AlgorithmPopupList{end}.Tag='addWholeImageAlgorithm';


                    rootFolder=toolboxdir('shared');

                    source=fullfile(rootFolder,'controllib','general','resources','Edit_16.png');
                    icon=matlab.ui.internal.toolstrip.Icon(source);

                    this.NewAlgorithm=ListItem(...
                    vision.getMessage('vision:labeler:CreateNewAlgorithm'),...
                    icon);

                    this.NewAlgorithm.ShowDescription=false;
                    this.NewAlgorithm.Tag='createNewAlgorithm';
                    this.NewAlgorithm.ItemPushedFcn=@(es,ed)createNewAlgorithm(this);

                    this.ImportAlgorithm=ListItem(...
                    vision.getMessage('vision:labeler:ImportAlgorithm'),...
                    matlab.ui.internal.toolstrip.Icon.IMPORT_16);
                    this.ImportAlgorithm.ShowDescription=false;
                    this.ImportAlgorithm.Tag='importAlgorithm';
                    this.ImportAlgorithm.ItemPushedFcn=@(es,ed)importAlgorithmFromFile(this);

                    defsPopup=PopupList();
                    defsPopup.add(this.NewAlgorithm);
                    defsPopup.add(this.ImportAlgorithm);
                    this.AlgorithmPopupList{end}.Popup=defsPopup;
                end
            end



            this.AlgorithmPopupList{end+1}=PopupListHeader(vision.getMessage('vision:imageLabeler:BlockedImageAutomationHeader'));

            hasBlockedAlg=false;

            for idx=1:repo.Count




                if repo.isBlockedAutomationAlgorithm(idx)
                    this.AlgorithmPopupList{end+1}=ListItem(names{idx});
                    this.AlgorithmPopupList{end}.Description=desc{idx};
                    this.AlgorithmPopupList{end}.Tag=names{idx};

                    hasBlockedAlg=true;
                end
            end

            if isdeployed()
                if~hasBlockedAlg
                    this.AlgorithmPopupList(end)=[];
                end
            else

                text=vision.getMessage('vision:imageLabeler:AddBlockedImageAlgorithm');
                icon=matlab.ui.internal.toolstrip.Icon.ADD_16;

                this.AlgorithmPopupList{end+1}=ListItemWithPopup(text,icon);
                this.AlgorithmPopupList{end}.ShowDescription=false;
                this.AlgorithmPopupList{end}.Tag='addBlockedImageAlgorithm';

                source=fullfile(toolboxdir('shared'),'controllib','general','resources','Edit_16.png');
                icon=matlab.ui.internal.toolstrip.Icon(source);

                this.NewAlgorithm=ListItem(...
                vision.getMessage('vision:imageLabeler:CreateNewBlockedImageAlgorithm'),...
                icon);

                this.NewAlgorithm.ShowDescription=false;
                this.NewAlgorithm.Tag='createNewBlockedImageAlgorithm';
                this.NewAlgorithm.ItemPushedFcn=@(es,ed)createNewBlockedAlgorithm(this);

                this.ImportAlgorithm=ListItem(...
                vision.getMessage('vision:imageLabeler:ImportBlockedImageAlgorithm'),...
                matlab.ui.internal.toolstrip.Icon.IMPORT_16);
                this.ImportAlgorithm.ShowDescription=false;
                this.ImportAlgorithm.Tag='importBlockedImageAlgorithm';
                this.ImportAlgorithm.ItemPushedFcn=@(es,ed)importBlockedAlgorithmFromFile(this);

                defsPopup=PopupList();
                defsPopup.add(this.NewAlgorithm);
                defsPopup.add(this.ImportAlgorithm);
                this.AlgorithmPopupList{end}.Popup=defsPopup;



                this.AlgorithmPopupList{end+1}=PopupListHeader(vision.getMessage('vision:imageLabeler:RefreshAutomationHeader'));


                this.AlgorithmPopupList{end+1}=ListItem(...
                vision.getMessage('vision:labeler:refreshAlgList'),...
                matlab.ui.internal.toolstrip.Icon.REFRESH_16);
                this.AlgorithmPopupList{end}.ShowDescription=false;
                this.AlgorithmPopupList{end}.Tag='refreshAlgList';
                this.AlgorithmPopupList{end}.ItemPushedFcn=@(es,ed)refreshAlgorithmPupup(this);
            end



            hasNoAlgorithms=numel(this.AlgorithmPopupList)==2;
            doesNotHavePreviousSelection=~ismember(this.SelectAlgorithmDropDown.Text,names);

            if hasNoAlgorithms||doesNotHavePreviousSelection

                titleID='vision:labeler:SelectAlgorithmDropDownTitle';
                this.SelectAlgorithmDropDown.Text=vision.getMessage(titleID);
            end

        end

    end

    methods(Access=protected)

        function createNewBlockedAlgorithm(this)
            vision.labeler.AutomationAlgorithm.openTemplateInEditor('blockedImageAutomation');
        end

        function importBlockedAlgorithmFromFile(this)

            selectFileTitle=vision.getMessage('vision:uitools:SelectFileTitle');
            [fileName,pathName,filterIndex]=uigetfile('*.m',selectFileTitle);
            hFig=getDefaultFig(this.Tool.Container);
            container=this.Tool.Tool;
            userCanceled=(filterIndex==0);
            if userCanceled
                return;
            end

            packageStrings=regexp(pathName,'+\w+','match');

            if~isempty(packageStrings)
                index=regexp(pathName,'+\w+');
                removeStr=pathName(index(1):end);
                pathName=strrep(pathName,removeStr,'');
            else

                index=regexp(pathName,'@\w+');
                if~isempty(index)
                    removeStr=pathName(index(1):end);
                    pathName=strrep(pathName,removeStr,'');
                end
            end

            for i=1:numel(packageStrings)
                packageStrings{i}=strrep(packageStrings{i},'+','');
            end

            fileString=strsplit(fileName,'.');
            clasStrings=[packageStrings,fileString{1}];
            className=strjoin(clasStrings,'.');

            try
                metaClass=meta.class.fromName(className);
            catch ME
                errorMessage=vision.getMessage('vision:labeler:NotAnAutomationAlgorithmMsg',className,ME.message);
                dialogName=getString(message('vision:labeler:NotAnAutomationAlgorithmDlg'));
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,container);
                return;
            end

            if isempty(metaClass)

                cancelButton=vision.getMessage('vision:uitools:Cancel');
                addToPathButton=vision.getMessage('vision:labeler:addToPath');
                cdButton=vision.getMessage('vision:labeler:cdFolder');

                msg=vision.getMessage(...
                'vision:labeler:notOnPathQuestionAlgImport',className,pathName);
                title=getString(message('vision:labeler:notOnPathTitle'));

                buttonName=vision.internal.labeler.handleAlert(hFig,'question',msg,title,...
                cdButton,addToPathButton,cancelButton,cdButton);

                switch buttonName
                case cdButton
                    cd(pathName);
                case addToPathButton
                    addpath(pathName);
                otherwise
                    return;
                end
                metaClass=meta.class.fromName(className);
            end

            if isempty(metaClass)
                errorMessage=vision.getMessage('vision:labeler:NotAnAutomationAlgorithm',className);
                dialogName=getString(message('vision:labeler:NotAnAutomationAlgorithmDlg'));
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,container);
                return;
            end


            metaSuperclass=metaClass.SuperclassList;
            superclasses={metaSuperclass.Name};
            expectedClass='vision.labeler.mixin.BlockedImageAutomation';
            blockedImageAutomationFlag=ismember(expectedClass,superclasses);
            if~blockedImageAutomationFlag
                errorMessage=vision.getMessage('vision:imageLabeler:NotBlockedImageAutomationAlgorithm',className);
                dialogName=getString(message('vision:labeler:NotAnAutomationAlgorithmDlg'));
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,container);
                return;
            end

            repo=getAlgorithmRepository(this);



            if~any(ismember(repo.AlgorithmList,className))







                if~strcmp(strjoin(packageStrings,'.'),repo.PackageRoot)
                    repo.appendImportedAlgorithm(className,pathName);
                end
            else
                errorMessage=vision.getMessage('vision:labeler:AlgorithmExistsMessage',className);
                dialogName=getString(message('vision:labeler:AlgorithmExistsTitle'));
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,container);
                return;
            end

            this.refreshAlgorithmList();


            this.SelectAlgorithmDropDown.Text=repo.getAlgorithmName(className);
            selectAlgorithm(this.Tool,className);

            this.RefreshPopupList=true;
        end

        function tip=getConfigureAlgorithmToolTip(~)


            tip='vision:labeler:ConfigureAlgorithmTooltip';
        end

    end
end
