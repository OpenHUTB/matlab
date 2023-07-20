classdef View<matlab.ui.container.internal.appcontainer.Panel&...
handle










    properties(Constant)
        Name char=getString(message('evolutions:ui:PropertyInspectorTitle'));
        TagName char='propertyinspector';
        FactoryPath="/js/widgets/InspectorPanelFactory";

        JSETIChannel='/ETIValueChanged';
        JSEIChannel='/EIValueChanged';
        SwitchViewMsgChannel='/AppViewChange';


        FileListMsgChannel='/FileList';


        FileInfoMsgChannel='/FileInfo';


        EdgeInfoMsgChannel='/EdgeInfo';

        WebChannel='/WebTree';
    end

    properties(SetAccess=protected)

ETIListener
EIListener
switchViewListener

FileListListener

EdgeInfoListener
    end

    properties(SetAccess=protected)
AppView
MessageChannel

EvolutionTreeInfoModelVal
EvolutionInfoModelVal


FileUIList


        FileInfo;


FileList
FileEvent
LatestSelectedFiles

ButtonStateUpdate
ProjectPath
Projectname
TreeDigraph
FullFilePathMap
    end

    events




ETIValueChanged
ETIStereotypeChanged
ETIDescriptionChanged

EIValueChanged
EIStereotypeChanged
EIDescriptionChanged

ValueChanged
FileRemoveActive
FileRemoveAll
FileAddActive
FileAddAll
CurrentSelectedFiles
RefreshFiles


ButtonStates

EdgeClicked
CompareButtonClicked

EdgeDescriptionChanged
    end

    methods
        function this=View(parent)
            this@matlab.ui.container.internal.appcontainer.Panel();
            this.AppView=parent.AppView;

            this.MessageChannel=getMsgChannel(this.AppView);
            this.Title=this.Name;
            this.Tag=this.TagName;
            this.Factory=this.AppView.ModuleName+this.FactoryPath;
            addlistener(this,'PropertyChanged',@(src,event)handleRegionChange(this,src,event));
            this.Content=struct(...
            'etiMsgChannel',this.MessageChannel+this.JSETIChannel,...
            'eiMsgChannel',this.MessageChannel+this.JSEIChannel,...
            'switchViewMsgChannel',this.MessageChannel+this.SwitchViewMsgChannel,...
            'fileListMsgChannel',this.MessageChannel+this.FileListMsgChannel,...
            'fileInfoMsgChannel',this.MessageChannel+this.FileInfoMsgChannel,...
            'edgeInfoMsgChannel',this.MessageChannel+this.EdgeInfoMsgChannel);



            this.ETIListener=evolutions.internal.ui.tools.JSSubscription.subscribe...
            (this,this.MessageChannel,@this.ETICallback,this.JSETIChannel);
            this.EIListener=evolutions.internal.ui.tools.JSSubscription.subscribe...
            (this,this.MessageChannel,@this.EICallback,this.JSEIChannel);
            this.FileListListener=evolutions.internal.ui.tools.JSSubscription.subscribe...
            (this,this.MessageChannel,@this.FileListCallback,this.FileListMsgChannel);
            this.EdgeInfoListener=evolutions.internal.ui.tools.JSSubscription.subscribe...
            (this,this.MessageChannel,@this.EdgeInfoCallback,this.EdgeInfoMsgChannel);
        end


        function handleRegionChange(this,~,event)
            if strcmp(event.PropertyName,'Region')||strcmp(event.PropertyName,'Collapsed')||strcmp(event.PropertyName,'Expand')||strcmp(event.PropertyName,'Maximized')
                evolutions.internal.ui.tools.JSSubscription.publish...
                (this.MessageChannel+this.FileListMsgChannel,'RefreshView',struct('RefreshView','PanelMoved'));
            end
        end

        function update(this,model)
            className=class(model);
            switch className
            case 'evolutions.internal.app.model.EvolutionsTreeSummaryManager'
                updateTree(this,model);
            case 'evolutions.internal.app.model.FileListManager'
                updateFileList(this,model);
            case 'evolutions.internal.app.model.FileSummaryManager'
                updateFileInfo(this,model);
            case 'evolutions.internal.app.model.CompareManager'
                updateEdgeInfo(this,model);
            otherwise
                assert(strcmp(className,'evolutions.internal.app.model.EvolutionsSummaryManager'));%#ok<STISA>
                updateEvolution(this,model);
            end
        end

        function setEvolutionTreeInfoView(this)

            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.MessageChannel+this.SwitchViewMsgChannel,'ChangeView','evolutionTreeInfo');
        end

        function setEvolutionInfoView(this)

            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.MessageChannel+this.SwitchViewMsgChannel,'ChangeView','evolutionInfo');


            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.MessageChannel+this.WebChannel,'EvolutionCreated',false);
        end

        function setEdgeInfoView(this)

            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.MessageChannel+this.SwitchViewMsgChannel,'ChangeView','edgeInfo');
            notify(this,'EdgeClicked');
        end

        function delete(this)

            listeners=["EIListener","ETIListener"];
            evolutions.internal.ui.deleteListeners(this,listeners)
        end

    end

    methods(Access=private)
        function updateTree(this,model)
            this.EvolutionTreeInfoModelVal.Name=model.Name;
            this.EvolutionTreeInfoModelVal.Project=model.Project;
            this.EvolutionTreeInfoModelVal.Created=model.CreatedOn;
            this.EvolutionTreeInfoModelVal.Updated=model.UpdatedOn;
            this.EvolutionTreeInfoModelVal.Author=model.UpdatedBy;
            this.EvolutionTreeInfoModelVal.TreeDescription=model.Description;
            this.EvolutionTreeInfoModelVal.Stereotypes=model.Stereotypes;
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.MessageChannel+this.JSETIChannel,'ModelDetails',this.EvolutionTreeInfoModelVal);
        end

        function updateEvolution(this,model)
            this.EvolutionInfoModelVal.IsWorking=model.IsWorking;
            this.EvolutionInfoModelVal.Name=model.Name;
            this.EvolutionInfoModelVal.Parent=model.Parent;
            this.EvolutionInfoModelVal.Created=model.CreatedOn;
            this.EvolutionInfoModelVal.Updated=model.UpdatedOn;
            this.EvolutionInfoModelVal.Author=model.UpdatedBy;
            this.EvolutionInfoModelVal.EvolutionDescription=model.Description;
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.MessageChannel+this.JSEIChannel,'ModelDetails',this.EvolutionInfoModelVal);
        end

        function updateFileList(this,model)
            allFiles=model.AllProjectFiles;
            data=model.getRelativeFilePaths;
            this.TreeDigraph=model.TreeDigraph;
            this.FullFilePathMap=model.FullFilePathMap;
            this.FileUIList.Items=data;
            this.FileUIList.ItemsData=model.FileList;
            this.ProjectPath=model.ProjectPath;
            this.Projectname=model.ProjectName;
            if~isempty(data)
                this.FileUIList.Value=model.CurrentSelected;
                this.FileUIList.Enable=1;
            else
                this.FileUIList.Items={getString(message('evolutions:ui:EmptyFileList'))};
                this.FileUIList.Value={};
                this.FileUIList.Enable=0;
            end

            bundledMessage=struct('Allfiles',{allFiles},...
            'WorkingProject',model.WorkingProjectName);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.MessageChannel+this.FileListMsgChannel,'BundledMessage',bundledMessage);
        end

        function updateFileInfo(this,model)
            this.FileInfo.Name=model.Name;
            this.FileInfo.Path=model.Path;
            this.FileInfo.FullPath=fullfile(model.Path,model.Name);
            fileInfoBundledMessage=struct('FileInfo',this.FileInfo);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.MessageChannel+this.FileInfoMsgChannel,'FileInfoMessage',fileInfoBundledMessage);
        end

        function updateEdgeInfo(this,model)
            differenceStruct=model.DifferencesStruct;
            edgeDescription=model.Description;
            stereotypes=model.Stereotypes;
            fileDifferences={};
            evolutionDifferences={};
            allFilesForEdge=cell.empty;
            currentProjectPath=model.CurrentProjectPath;

            projectPath=this.getProjectValue(this.ProjectPath,'name');
            projectName=this.getProjectValue(this.Projectname,'path');
            for differenceIndex=1:numel(differenceStruct)
                from=differenceStruct{differenceIndex}.from;
                to=differenceStruct{differenceIndex}.to;
                fromEvolution=differenceStruct{differenceIndex}.fromEvolution;
                toEvolution=differenceStruct{differenceIndex}.toEvolution;
                addedFiles=this.fileDifferenceArray(differenceStruct{differenceIndex}.differences.addedFiles);
                changedFiles=this.fileDifferenceArray(differenceStruct{differenceIndex}.differences.changedFiles);
                removedFiles=this.fileDifferenceArray(differenceStruct{differenceIndex}.differences.removedFiles);




                combinedResult=cell.empty;
                addedFilesCell=cell2mat(addedFiles);
                changedFilesCell=cell2mat(changedFiles);
                removedFilesCell=cell2mat(removedFiles);

                combinedResult=this.getFilesArray(addedFilesCell,addedFiles,combinedResult);
                combinedResult=this.getFilesArray(removedFilesCell,removedFiles,combinedResult);
                combinedResult=this.getFilesArray(changedFilesCell,changedFiles,combinedResult);

                if(numel(combinedResult)>0&&isequal(projectPath,currentProjectPath))
                    allFilesForEdge=evolutions.internal.utils.getFilesForTable(this.TreeDigraph,this.FullFilePathMap,combinedResult,projectPath,projectName);
                end



                fileDifferences{differenceIndex}=struct('addedFiles',{addedFiles},...
                'changedFiles',{changedFiles},'removedFiles',{removedFiles});%#ok<AGROW>
                evolutionDifferences{differenceIndex}=struct('from',from,'to',...
                to,'fromEvolution',fromEvolution,'toEvolution',toEvolution,...
                'dStruct',fileDifferences{differenceIndex},'allFilesForEdge',{allFilesForEdge});%#ok<AGROW>
            end

            differencesStruct=struct('Differences',{evolutionDifferences},'allFilesForEdge',{allFilesForEdge},'Description',model.Description);
            evolutions.internal.ui.tools.JSSubscription.publish...
            (this.MessageChannel+this.EdgeInfoMsgChannel,'EdgeInfoMessage',differencesStruct);
        end

        function projectValue=getProjectValue(~,value,type)
            projectValue=value;
            switch type
            case 'name'
                if(isempty(projectValue))
                    projectValue=currentProject().Name;
                end
            case 'path'
                if(isempty(projectValue))
                    projectValue=currentProject().RootFolder;
                end
            end
        end

        function combinedResult=getFilesArray(~,filesCell,files,combinedResult)
            if(~all(filesCell(:)==0))
                for id=1:numel(files)
                    combinedResult{end+1}=files{id};%#ok<AGROW>
                end
            end
        end

        function differenceArray=fileDifferenceArray(~,fileList)
            differenceArray={numel(fileList)};
            if(numel(fileList)>0)
                for fileIndex=1:numel(fileList)
                    differenceArray{fileIndex}=fileList(fileIndex).File;
                end
            end
        end

        function ETICallback(this,data)
            viewField=data.item;
            viewValue=data.value.newValue;
            if(~isempty(data.value))
                switch viewField
                case 'EtiName'
                    notify(this,'ETIValueChanged',...
                    evolutions.internal.ui.GenericEventData(viewValue));
                case 'EtiDescription'
                    notify(this,'ETIDescriptionChanged',...
                    evolutions.internal.ui.GenericEventData(viewValue));
                end
            end
        end

        function EICallback(this,data)
            viewField=data.item;
            viewValue=data.value.newValue;
            if(~isempty(data.value))
                switch viewField
                case 'EiName'
                    notify(this,'EIValueChanged',...
                    evolutions.internal.ui.GenericEventData(viewValue));
                case 'EiDescription'
                    notify(this,'EIDescriptionChanged',...
                    evolutions.internal.ui.GenericEventData(viewValue));
                end
            end
        end

        function EdgeInfoCallback(this,data)

            viewValue=data.value;
            viewField=data.item;

            if(~isempty(data.value))
                switch viewField
                case 'EdgeClicked'
                    notify(this,'EdgeClicked',...
                    evolutions.internal.ui.GenericEventData(viewValue));
                case 'EdgeDescription'
                    notify(this,'EdgeDescriptionChanged',...
                    evolutions.internal.ui.GenericEventData(viewValue.newValue));
                otherwise
                    notify(this,'CompareButtonClicked',...
                    evolutions.internal.ui.GenericEventData(viewValue));
                end
            end
        end

        function FileListCallback(this,data)
            viewField=split(data.item,".");
            viewEventName=viewField{1};
            viewEventType=viewField{2};
            viewValue=data.value;
            if(~isempty(data.value))
                switch viewEventName
                case 'ValueChanged'
                    this.FileUIList.CurrentTreeName=viewValue;
                    notify(this,'ValueChanged');
                    notify(this,'CurrentSelectedFiles');
                case 'CurrentSelectedFiles'
                    this.LatestSelectedFiles=viewValue;
                case 'RemoveFromActive'
                    this.FileList=viewValue;
                    this.FileEvent=viewEventType;
                    this.setRemoveFromActive(viewEventType)
                case 'AddToActive'
                    this.FileList=viewValue;
                    this.FileEvent=viewEventType;
                    notify(this,'FileAddActive');
                case 'AddToActiveAll'
                    this.FileList=viewValue;
                    this.FileEvent=viewEventType;
                    notify(this,'FileAddAll');
                case 'RefreshFiles'
                    notify(this,'RefreshFiles');
                end
            end
        end

        function setRemoveFromActive(this,viewEventType)
            if(strcmp(viewEventType,"Active"))
                notify(this,'FileRemoveActive');
            else
                notify(this,'FileRemoveAll');
            end
        end
    end
end

