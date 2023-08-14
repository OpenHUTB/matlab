classdef MetadataUI_exported<matlab.apps.AppBase


    properties(Access=public)
        UIFigure matlab.ui.Figure
        AppGrid matlab.ui.container.GridLayout
        MetadataGrid matlab.ui.container.GridLayout
        DocLinkLabel matlab.ui.control.Label
        DocLink matlab.ui.control.EditField
        Description matlab.ui.control.EditField
        FilePath matlab.ui.control.Label
        TaskClassDefinitionFileLabel matlab.ui.control.Label
        Keywords matlab.ui.control.EditField
        KeywordsLabel matlab.ui.control.Label
        DescriptionLabel matlab.ui.control.Label
        BrowseIconButton matlab.ui.control.Button
        Icon matlab.ui.control.Image
        Name matlab.ui.control.EditField
        IconLabel matlab.ui.control.Label
        NameLabel matlab.ui.control.Label
        TaskDetailsLabel matlab.ui.control.Label
        ActionButtonGrid matlab.ui.container.GridLayout
        HelpButton matlab.ui.control.Button
        OkButton matlab.ui.control.Button
        CancelButton matlab.ui.control.Button
    end

    properties(Access=private)
ViewModel
Metadata
ProgressDialog
        PathDialogShown=false
    end

    methods(Access=public)

        function localize(app)




            import matlab.internal.task.metadata.Constants
            childComponents=[app.UIFigure;app.MetadataGrid.Children;app.ActionButtonGrid.Children];
            for taskIndex=1:length(childComponents)
                childComponent=childComponents(taskIndex);
                if~isempty(childComponent.Tag)
                    tagParts=strsplit(childComponent.Tag,':');
                    childComponent.(tagParts{2})=string(message([Constants.MessageCatalogPrefix,tagParts{1}]));
                end
                if isprop(childComponent,'Tooltip')&&~isempty(childComponent.Tooltip)&&...
                    (~iscell(childComponent.Tooltip)||~isempty(childComponent.Tooltip{1}))
                    if iscell(childComponent.Tooltip)
                        childComponent.Tooltip=childComponent.Tooltip{1};
                    end
                    childComponent.Tooltip=string(message([Constants.MessageCatalogPrefix,childComponent.Tooltip]));
                end
            end
        end

        function formattedFilePathTooltip=formatFilePathTooltip(app,filePathTooltip)



            import matlab.internal.task.metadata.Constants
            formattedFilePathTooltip=filePathTooltip;
            lineLength=Constants.MaxFilePathLength/2;
            if length(filePathTooltip)>lineLength
                formattedFilePathTooltip='';
                index=1;
                while index<length(filePathTooltip)
                    if index+lineLength>length(filePathTooltip)
                        formattedFilePathTooltip=[formattedFilePathTooltip,' ',filePathTooltip(index:end)];
                        break;
                    end
                    filePathPart=filePathTooltip(index:index+lineLength);
                    formattedFilePathTooltip=[formattedFilePathTooltip,' ',filePathPart];
                    index=index+lineLength+1;
                end
            end
        end

        function showRegistrationError(app,~,eventData)



            import matlab.internal.task.metadata.Constants
            delete(app.ProgressDialog);
            selectionDialogHeader=string(message([Constants.MessageCatalogPrefix,'TaskRegistrationHeader']));
            selectionDialogMsg=string(message([Constants.MessageCatalogPrefix,'RegistrationErrorMsg'],eventData.ErrorMessage));
            uialert(app.UIFigure,selectionDialogMsg,selectionDialogHeader,...
            'Icon','error');
        end

        function closeMetadataUI(app,~,~)



            import matlab.internal.task.metadata.Constants

            delete(app.ProgressDialog);


            selectionDialogHeader=string(message([Constants.MessageCatalogPrefix,'TaskRegistrationHeader']));
            directory=app.ViewModel.getDirectory();
            onPath=app.checkIfFolderOnPath(directory);
            if strcmp(app.ViewModel.getStatus(),Constants.NotRegistered)
                if onPath
                    selectionDialogMsg=string(message([Constants.MessageCatalogPrefix,'RegistrationSuccessMsgOnPath']));
                else
                    selectionDialogMsg=string(message([Constants.MessageCatalogPrefix,'RegistrationSuccessMsg']));
                end
            else
                if onPath
                    selectionDialogMsg=string(message([Constants.MessageCatalogPrefix,'UpdateSuccessMsgOnPath']));
                else
                    selectionDialogMsg=string(message([Constants.MessageCatalogPrefix,'UpdateSuccessMsg']));
                end
            end

            uialert(app.UIFigure,selectionDialogMsg,selectionDialogHeader,...
            'Icon','success','CloseFcn',@app.cleanUpApp);
        end

        function handleInvalidModel(app)




            import matlab.internal.task.metadata.Constants
            selectionDialogHeader=string(message([Constants.MessageCatalogPrefix,'RegistrationErrorMsg']));
            selectionDialogMsg=string(message([Constants.MessageCatalogPrefix,'InvalidModelWarningMsg']));

            uialert(app.UIFigure,selectionDialogMsg,selectionDialogHeader,...
            'Icon','warning');
        end

        function resetName(app,~,~)


            app.Name.Value=app.Metadata.name;
        end

        function cleanUpApp(app,~,~)


            app.ViewModel.cleanUpApp();
            delete(app);
        end
    end

    methods(Access=private)
        function onPath=checkIfFolderOnPath(app,directory)
            pathCell=regexp(path,pathsep,'split');
            if ispc
                onPath=any(strcmpi(directory,pathCell));
            else
                onPath=any(strcmp(directory,pathCell));
            end
        end
    end


    methods(Access=private)


        function startupFcn(app,viewModel)
            import matlab.internal.task.metadata.Constants

            viewModel.alignFigure(app.UIFigure);

            app.localize();


            [app.FilePath.Text,filePathTooltip]=viewModel.getFilePath();
            app.FilePath.Tooltip=app.formatFilePathTooltip(filePathTooltip);
            metadata=viewModel.getMetadata();
            app.Name.Value=metadata.name;

            dirPath=strjoin(Constants.UserTaskPackagePath,filesep);

            if strcmp(viewModel.getStatus(),Constants.NotRegistered)
                app.Icon.ImageSource=metadata.icon;
            elseif~isfield(metadata,"icon")
                app.Icon.ImageSource=fullfile(matlabroot,dirPath,Constants.DefaultTaskIcon);
            elseif isfile(fullfile(viewModel.getDirectory(),'resources',metadata.icon))
                app.Icon.ImageSource=viewModel.resizeIconImage(fullfile(viewModel.getDirectory(),'resources',metadata.icon));
            else
                app.Icon.ImageSource=fullfile(matlabroot,dirPath,Constants.DefaultTaskIcon);
            end

            app.BrowseIconButton.Icon=fullfile(matlabroot,dirPath,Constants.FolderIcon);

            app.Description.Value=metadata.description;
            app.Keywords.Value=metadata.keywords;
            app.DocLink.Value=metadata.docLink;


            addlistener(viewModel,Constants.RegistrationErrorEvent,@app.showRegistrationError);
            addlistener(viewModel,Constants.RegistrationSuccessEvent,@app.closeMetadataUI);



            if~viewModel.getModelValidity()
                app.handleInvalidModel();
            end

            app.ViewModel=viewModel;
            app.Metadata=metadata;
        end


        function OkButtonPushed(app,event)
            import matlab.internal.task.metadata.Constants


            isValidMetadata=app.ViewModel.validateName(app.Name.Value);

            if~isValidMetadata
                return;
            end


            progressDialogHeader=string(message([Constants.MessageCatalogPrefix,'TaskRegistrationHeader']));
            progressDialogMsg=string(message([Constants.MessageCatalogPrefix,'RegistrationInProgressMsg']));
            app.ProgressDialog=uiprogressdlg(app.UIFigure,'Indeterminate','on',...
            'Message',progressDialogMsg,...
            'Title',progressDialogHeader);


            viewModel=app.ViewModel;
            metadata=app.Metadata;

            metadata.name=app.Name.Value;
            metadata.description=string(app.Description.Value);

            metadata.icon=app.ViewModel.copyIcon();
            metadata.keywords=app.Keywords.Value;
            metadata.docLink=app.DocLink.Value;
            metadata.taskClassName=metadata.taskClassName;


            viewModel.registerTask(metadata);
        end


        function BrowseIconButtonPushed(app,event)
            import matlab.internal.task.metadata.Constants
            [fileName,filePath]=uigetfile(...
            {'*.gif;*.jpeg;*.jpg;*.png;','All Image Files (*.gif,*.jpeg,*.jpg,*.png)';
            '*.*','All Files (*.*)'},'Choose a File');
            figure(app.UIFigure);

            if fileName~=0
                [~,~,imageFormat]=fileparts(fileName);
                if contains(['.gif','.jpeg','.jpg','.png'],lower(imageFormat))
                    iconPath=fullfile(filePath,fileName);
                    app.Icon.ImageSource=app.ViewModel.resizeIconImage(iconPath);
                else
                    selectionDialogHeader=string(message([Constants.MessageCatalogPrefix,'TaskRegistrationHeader']));
                    selectionDialogMsg=string(message([Constants.MessageCatalogPrefix,'IconFileErrorMsg']));
                    uialert(app.UIFigure,selectionDialogMsg,selectionDialogHeader,...
                    'Icon','error');
                end
            end
        end


        function CancelButtonPushed(app,event)
            app.ViewModel.cleanUpApp();
            delete(app);
        end


        function NameValueChanged(app,event)
            import matlab.internal.task.metadata.Constants


            if app.ViewModel.validateName(event.Value)
                app.Metadata.name=event.Value;
                return;
            end


            selectionDialogHeader=string(message([Constants.MessageCatalogPrefix,'TaskRegistrationHeader']));
            selectionDialogMsg=string(message([Constants.MessageCatalogPrefix,'TaskNameEmptyErrorMsg']));
            uialert(app.UIFigure,selectionDialogMsg,selectionDialogHeader,...
            'Icon','error','CloseFcn',@app.resetName);
        end


        function HelpButtonPushed(app,event)
            helpview(fullfile(docroot,'matlab','helptargets.map'),'livetasks_configure_task');
        end


        function KeywordsValueChanged(app,event)
            keywords=app.Keywords.Value;
            app.Metadata.keywords=app.ViewModel.validateAndUpdateKeywords(keywords);
        end
    end


    methods(Access=private)


        function createComponents(app)


            app.UIFigure=uifigure('Visible','off');
            app.UIFigure.AutoResizeChildren='off';
            app.UIFigure.Position=[100,100,567,328];
            app.UIFigure.Name='App Designer Custom UI Component Metadata';
            app.UIFigure.Tag='MetadataUITitle:Name';


            app.AppGrid=uigridlayout(app.UIFigure);
            app.AppGrid.ColumnWidth={'1x'};
            app.AppGrid.RowHeight={'100x',40};


            app.ActionButtonGrid=uigridlayout(app.AppGrid);
            app.ActionButtonGrid.ColumnWidth={89,'1x',89,89};
            app.ActionButtonGrid.RowHeight={22};
            app.ActionButtonGrid.Layout.Row=2;
            app.ActionButtonGrid.Layout.Column=1;


            app.CancelButton=uibutton(app.ActionButtonGrid,'push');
            app.CancelButton.ButtonPushedFcn=createCallbackFcn(app,@CancelButtonPushed,true);
            app.CancelButton.Tag='CancelLabel:Text';
            app.CancelButton.Layout.Row=1;
            app.CancelButton.Layout.Column=4;
            app.CancelButton.Text='Cancel';


            app.OkButton=uibutton(app.ActionButtonGrid,'push');
            app.OkButton.ButtonPushedFcn=createCallbackFcn(app,@OkButtonPushed,true);
            app.OkButton.Tag='OkLabel:Text';
            app.OkButton.Layout.Row=1;
            app.OkButton.Layout.Column=3;
            app.OkButton.Text='Ok';


            app.HelpButton=uibutton(app.ActionButtonGrid,'push');
            app.HelpButton.ButtonPushedFcn=createCallbackFcn(app,@HelpButtonPushed,true);
            app.HelpButton.Tag='HelpLabel:Text';
            app.HelpButton.Layout.Row=1;
            app.HelpButton.Layout.Column=1;
            app.HelpButton.Text='Help';


            app.MetadataGrid=uigridlayout(app.AppGrid);
            app.MetadataGrid.ColumnWidth={220,39,89,43,71,17};
            app.MetadataGrid.RowHeight={'fit',22,22,22,22,22,22,22};
            app.MetadataGrid.Padding=[10,10,10,0];
            app.MetadataGrid.Layout.Row=1;
            app.MetadataGrid.Layout.Column=1;


            app.TaskDetailsLabel=uilabel(app.MetadataGrid);
            app.TaskDetailsLabel.Tag='TaskDetailsLabel:Text';
            app.TaskDetailsLabel.FontWeight='bold';
            app.TaskDetailsLabel.Layout.Row=3;
            app.TaskDetailsLabel.Layout.Column=1;
            app.TaskDetailsLabel.Text='Task Details';


            app.NameLabel=uilabel(app.MetadataGrid);
            app.NameLabel.Tag='NameLabel:Text';
            app.NameLabel.Tooltip={'NameTooltip'};
            app.NameLabel.Layout.Row=4;
            app.NameLabel.Layout.Column=1;
            app.NameLabel.Text='Name *';


            app.IconLabel=uilabel(app.MetadataGrid);
            app.IconLabel.Tag='IconLabel:Text';
            app.IconLabel.Tooltip={'IconTooltip'};
            app.IconLabel.Layout.Row=6;
            app.IconLabel.Layout.Column=1;
            app.IconLabel.Text='Icon';


            app.Name=uieditfield(app.MetadataGrid,'text');
            app.Name.ValueChangedFcn=createCallbackFcn(app,@NameValueChanged,true);
            app.Name.Tooltip={'NameTooltip'};
            app.Name.Layout.Row=4;
            app.Name.Layout.Column=[2,6];


            app.Icon=uiimage(app.MetadataGrid);
            app.Icon.ScaleMethod='scaledown';
            app.Icon.Tooltip={'IconTooltip'};
            app.Icon.Layout.Row=6;
            app.Icon.Layout.Column=2;
            app.Icon.HorizontalAlignment='left';


            app.BrowseIconButton=uibutton(app.MetadataGrid,'push');
            app.BrowseIconButton.ButtonPushedFcn=createCallbackFcn(app,@BrowseIconButtonPushed,true);
            app.BrowseIconButton.Tag='BrowseLabel:Text';
            app.BrowseIconButton.Layout.Row=6;
            app.BrowseIconButton.Layout.Column=3;
            app.BrowseIconButton.Text='Browse';


            app.DescriptionLabel=uilabel(app.MetadataGrid);
            app.DescriptionLabel.Tag='DescriptionLabel:Text';
            app.DescriptionLabel.VerticalAlignment='top';
            app.DescriptionLabel.WordWrap='on';
            app.DescriptionLabel.Tooltip={'DescriptionTooltip'};
            app.DescriptionLabel.Layout.Row=5;
            app.DescriptionLabel.Layout.Column=1;
            app.DescriptionLabel.Text='Description';


            app.KeywordsLabel=uilabel(app.MetadataGrid);
            app.KeywordsLabel.Tag='KeywordsLabel:Text';
            app.KeywordsLabel.Tooltip={'KeywordsTooltip'};
            app.KeywordsLabel.Layout.Row=7;
            app.KeywordsLabel.Layout.Column=1;
            app.KeywordsLabel.Text='Keywords';


            app.Keywords=uieditfield(app.MetadataGrid,'text');
            app.Keywords.ValueChangedFcn=createCallbackFcn(app,@KeywordsValueChanged,true);
            app.Keywords.Tooltip={'KeywordsTooltip'};
            app.Keywords.Layout.Row=7;
            app.Keywords.Layout.Column=[2,6];


            app.TaskClassDefinitionFileLabel=uilabel(app.MetadataGrid);
            app.TaskClassDefinitionFileLabel.Tag='TaskFileLabel:Text';
            app.TaskClassDefinitionFileLabel.FontWeight='bold';
            app.TaskClassDefinitionFileLabel.Layout.Row=1;
            app.TaskClassDefinitionFileLabel.Layout.Column=[1,6];
            app.TaskClassDefinitionFileLabel.Text='Task Class Definition File';


            app.FilePath=uilabel(app.MetadataGrid);
            app.FilePath.Layout.Row=2;
            app.FilePath.Layout.Column=[1,5];
            app.FilePath.Text='';


            app.Description=uieditfield(app.MetadataGrid,'text');
            app.Description.Tooltip={'DescriptionTooltip'};
            app.Description.Layout.Row=5;
            app.Description.Layout.Column=[2,6];


            app.DocLink=uieditfield(app.MetadataGrid,'text');
            app.DocLink.Tooltip={'DocLinkTooltip'};
            app.DocLink.Layout.Row=8;
            app.DocLink.Layout.Column=[2,6];


            app.DocLinkLabel=uilabel(app.MetadataGrid);
            app.DocLinkLabel.Tag='DocLinkLabel:Text';
            app.DocLinkLabel.VerticalAlignment='top';
            app.DocLinkLabel.WordWrap='on';
            app.DocLinkLabel.Tooltip={'DocLinkTooltip'};
            app.DocLinkLabel.Layout.Row=8;
            app.DocLinkLabel.Layout.Column=1;
            app.DocLinkLabel.Text='Documentation Link';


            app.UIFigure.Visible='on';
        end
    end


    methods(Access=public)


        function app=MetadataUI_exported(varargin)

            runningApp=getRunningApp(app);


            if isempty(runningApp)


                createComponents(app)


                registerApp(app,app.UIFigure)


                runStartupFcn(app,@(app)startupFcn(app,varargin{:}))
            else


                figure(runningApp.UIFigure)

                app=runningApp;
            end

            if nargout==0
                clear app
            end
        end


        function delete(app)


            delete(app.UIFigure)
        end
    end
end