







classdef AlgorithmSection<vision.internal.uitools.NewToolStripSection

    properties
SelectAlgorithmLabel
SelectAlgorithmDropDown
ConfigureButton
ConfigureTearOff
AutomateButton

AlgorithmPopupList
RefreshPopupList
NewAlgorithm
ImportAlgorithm

        DefaultSelectionTextID='vision:labeler:SelectAlgorithmDropDownTitle';

AppName
Tool
    end

    properties(Dependent)
NumAlgorithms
    end

    properties(Access=protected)

GroupName
    end

    methods(Access=protected)
        function tip=getConfigureAlgorithmToolTip(~)


            tip='vision:labeler:ConfigureAlgorithmTooltip';
        end
    end

    methods
        function this=AlgorithmSection(tool)

            this.Tool=tool;

            this.AppName=getInstanceName(tool);

            this.createSection();
            this.layoutSection(tool);

        end

        function tf=isAlgorithmSelected(this)
            tf=not(strcmp(vision.getMessage(this.DefaultSelectionTextID),...
            this.SelectAlgorithmDropDown.Text));
        end

        function refreshAlgorithmList(this)
            import matlab.ui.internal.toolstrip.*;

            repo=getAlgorithmRepository(this);
            repo.refresh();

            this.AlgorithmPopupList={};
            names=cell(1,repo.Count);
            for i=1:repo.Count




                names{i}=repo.getAlgorithmNameByIndex(i);

                desc=repo.getAlgorithmDescription(i);

                this.AlgorithmPopupList{i}=ListItem(names{i});
                this.AlgorithmPopupList{i}.Description=desc;
                this.AlgorithmPopupList{i}.Tag=names{i};
            end



            if~isdeployed()
                text=vision.getMessage('vision:labeler:AddAlgorithm');
                icon=matlab.ui.internal.toolstrip.Icon.ADD_16;

                this.AlgorithmPopupList{end+1}=ListItemWithPopup(text,icon);
                this.AlgorithmPopupList{end}.ShowDescription=false;
                this.AlgorithmPopupList{end}.Tag='addAlgorithm';

                source=fullfile(toolboxdir('shared'),'controllib','general','resources','Edit_16.png');
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




        function n=get.NumAlgorithms(this)
            n=numel(this.AlgorithmPopupList);


            n=n-2;
        end
    end

    methods(Access=protected)
        function createSection(this)

            algorithmSectionTitle=getString(message('vision:labeler:AlgorithmSectionTitle'));
            algorithmSectionTag='sectionAlg';

            this.Section=matlab.ui.internal.toolstrip.Section(algorithmSectionTitle);
            this.Section.Tag=algorithmSectionTag;
        end

        function layoutSection(this,tool)

            this.addSelectAlgorithmLabel();
            this.addSelectAlgorithmDropDown();


            if~isImageLabeler(this)
                this.addConfigureButton();
                this.addConfigureTearOff(tool);
            end
            this.addRunAlgorithmButton();

            algChoiceCol=this.addColumn();
            algChoiceCol.add(this.SelectAlgorithmLabel);
            algChoiceCol.add(this.SelectAlgorithmDropDown);

            if~isImageLabeler(this)
                algChoiceCol.add(this.ConfigureButton);
            else
                algChoiceCol.addEmptyControl();
            end

            algRunCol=this.addColumn();
            algRunCol.add(this.AutomateButton);
        end

        function addSelectAlgorithmLabel(this)

            this.SelectAlgorithmLabel=this.createLabel('vision:labeler:SelectAlgorithmLabel');
        end

        function addSelectAlgorithmDropDown(this)

            icon=matlab.ui.internal.toolstrip.Icon.OPEN_16;
            tag='btnSelectAlgorithm';
            this.SelectAlgorithmDropDown=this.createDropDownButton(...
            icon,this.DefaultSelectionTextID,tag);
            this.refreshAlgorithmList();
            this.RefreshPopupList=true;
            toolTipID='vision:labeler:SelectAlgorithmDropDownToolTip';
            this.setToolTipText(this.SelectAlgorithmDropDown,toolTipID);
        end

        function addConfigureButton(this)
            icon=matlab.ui.internal.toolstrip.Icon.SETTINGS_16;
            titleID='vision:labeler:ConfigureAlgorithm';
            tag='btnConfigureAlgorithm';
            if useAppContainer()
                this.ConfigureButton=this.createDropDownButton(icon,titleID,tag);
            else
                this.ConfigureButton=this.createButton(icon,titleID,tag);
            end
            toolTipID=this.getConfigureAlgorithmToolTip();
            this.setToolTipText(this.ConfigureButton,toolTipID);
        end

        function addConfigureTearOff(this,tool)
            this.ConfigureTearOff=...
            vision.internal.labeler.tool.ConfigurationTearOff(tool,this.ConfigureButton);
            addlistener(this.ConfigureTearOff,'StartTimeChanged',@(es,ed)updateDefaultConfiguration(this));
        end

        function updateDefaultConfiguration(this)


            this.ConfigureTearOff.ImportROIs=this.ConfigureTearOff.StartAtCurrentTime;
        end

        function addRunAlgorithmButton(this)


            source=fullfile(toolboxdir('vision'),'vision',...
            '+vision','+internal','+labeler','+tool','+icons',...
            'Automate_24px.png');
            icon=matlab.ui.internal.toolstrip.Icon(source);
            titleID='vision:labeler:RunAlgorithmButtonTitle';
            tag='btnRunAlgorithm';
            this.AutomateButton=this.createButton(icon,titleID,tag);
            toolTipID='vision:labeler:RunAlgorithmButtonToolTip';
            this.setToolTipText(this.AutomateButton,toolTipID);
        end





        function createNewAlgorithm(this)

            if isImageLabeler(this)
                vision.labeler.AutomationAlgorithm.openTemplateInEditor('nontemporal');
            elseif isVideoLabeler(this)
                vision.labeler.AutomationAlgorithm.openTemplateInEditor('temporal');
            else
                vision.labeler.AutomationAlgorithm.openTemplateInEditor('multisignal');
            end
        end

        function importAlgorithmFromFile(this)

            selectFileTitle=vision.getMessage('vision:uitools:SelectFileTitle');
            [fileName,pathName,filterIndex]=uigetfile('*.m',selectFileTitle);
            hFig=getDefaultFig(this.Tool.Container);
            container=this.Tool;

            if~useAppContainer()
                container=container.Tool;
            end
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

                title=vision.getMessage('vision:labeler:notOnPathTitle');

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

        function refreshAlgorithmPupup(this)
            this.refreshAlgorithmList();
            this.RefreshPopupList=true;
        end

        function repo=getAlgorithmRepository(this)

            if isImageLabeler(this)
                repo=vision.internal.imageLabeler.ImageLabelerAlgorithmRepository.getInstance();
            elseif isVideoLabeler(this)
                repo=vision.internal.labeler.VideoLabelerAlgorithmRepository.getInstance();
            elseif isLidarLabeler(this)
                repo=lidar.internal.lidarLabeler.LidarLabelerAlgorithmRepository.getInstance();
            else
                repo=vision.internal.videoLabeler.MultiSignalLabelerAlgorithmRepository.getInstance();
            end
        end

        function tf=isImageLabeler(this)
            tf=strcmpi(this.AppName,'imageLabeler');
        end

        function tf=isVideoLabeler(this)
            tf=strcmpi(this.AppName,'videoLabeler');
        end

        function tf=isLidarLabeler(this)
            tf=strcmpi(this.AppName,'lidarLabeler');
        end

        function grpName=getGroupName(this)
            grpName=this.GroupName;
        end
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end
