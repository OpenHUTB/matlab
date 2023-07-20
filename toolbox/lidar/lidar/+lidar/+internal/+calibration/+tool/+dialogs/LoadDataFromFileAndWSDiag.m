classdef LoadDataFromFileAndWSDiag<controllib.ui.internal.dialog.AbstractDialog




    properties(Access='private')

        WorkspaceVariableClassFilter;

        SelectFromWorkspaceRadioBtn;
SelectFromFileRadioBtn

        WSVariablesDropDown;
        SelectedFileEditField;

        BrowseBtn;
        OkayBtn;
        CancelBtn;

        WorkspaceOrFileSelectedFlag=true;

        DropdownListItems={};
        IsOkayClicked=false;

        SelectedValue=[];
        WsOrFilename=[];

        FigureTag="loadDataFromFileAndWSDiag";

        FigBusy=false;
        ParentFig=[];
        RadioButtonGroup=[];
    end

    methods

        function this=LoadDataFromFileAndWSDiag(title,workspaceVariableClassFilter)
            this.Title=title;
            this.WorkspaceVariableClassFilter=workspaceVariableClassFilter;
            this.DropdownListItems=getWorkspaceVariables(this,workspaceVariableClassFilter);
            this.CloseMode='destroy';
        end

        function[isWorkspace,value,wsOrFilename]=showDiag(this,parent)
            this.ParentFig=parent;
            show(this,parent);
            this.UIFigure.CloseRequestFcn=@(es,ed)cbCancelBtn(this);
            uiwait(this.UIFigure);
            isWorkspace=[];
            value=[];
            wsOrFilename=[];
            if(this.IsOkayClicked)
                isWorkspace=this.WorkspaceOrFileSelectedFlag;
                value=this.SelectedValue;
                wsOrFilename=this.WsOrFilename;
            end

        end
    end

    methods(Access='protected')
        function buildUI(this)

            figSize=[350,200];
            this.UIFigure.WindowStyle='modal';
            this.UIFigure.Position=[this.UIFigure.Position(1),this.UIFigure.Position(2),figSize(1),figSize(2)];

            this.UIFigure.Resize='off';
            this.UIFigure.Tag=this.FigureTag;
            this.RadioButtonGroup=uibuttongroup(this.UIFigure,'visible','on','Position',[10,10,330,180]);
            this.SelectFromWorkspaceRadioBtn=uiradiobutton(this.RadioButtonGroup,...
            'Text',string(message('lidar:lidarCameraCalibrator:fromWorkspaceLabelText')),...
            'Position',[10,150,150,30],'Tag','fromWS');

            this.SelectFromWorkspaceRadioBtn.Value=1;
            this.WSVariablesDropDown=uidropdown(this.UIFigure,'Position',[38,130,230,30]);

            this.SelectFromFileRadioBtn=uiradiobutton(this.RadioButtonGroup,...
            'Text',string(message('lidar:lidarCameraCalibrator:fromFileLabelText')),...
            'Position',[10,80,100,30],'Tag','fromFile');

            this.SelectedFileEditField=uieditfield('Value','','Editable',true,'Parent',this.UIFigure);
            this.SelectedFileEditField.Position=[40-3,60,230,30];
            this.SelectedFileEditField.Enable=false;
            this.BrowseBtn=uibutton('Parent',this.UIFigure,...
            "Text",string(message('lidar:lidarCameraCalibrator:browseBtn')));

            this.BrowseBtn.Position=[280-5,60,55,30];
            this.BrowseBtn.Enable=false;

            this.OkayBtn=uibutton('Parent',this.UIFigure,...
            "Text",string(message('lidar:lidarCameraCalibrator:okBtn')),...
            'Position',[figSize(1)/2-100,20,80,30]);
            this.CancelBtn=uibutton('Parent',this.UIFigure,...
            "Text",string(message('lidar:lidarCameraCalibrator:cancelBtn')),...
            'Position',[figSize(1)/2+5,20,80,30]);

            this.OkayBtn.Enable=false;

            if(isempty(this.DropdownListItems))
                this.DropdownListItems=string(message('lidar:lidarCameraCalibrator:noValidVariables'));
                this.SelectFromWorkspaceRadioBtn.Enable=false;
                this.WSVariablesDropDown.Enable=false;

                this.SelectFromFileRadioBtn.Value=1;
                this.BrowseBtn.Enable=true;
                this.SelectedFileEditField.Enable=true;

                this.WorkspaceOrFileSelectedFlag=false;
            else

                this.OkayBtn.Enable=true;
            end
            this.WSVariablesDropDown.Items=this.DropdownListItems;

        end

        function connectUI(this)

            addlistener(this.BrowseBtn,'ButtonPushed',@(es,ed)cbBrowseBtn(this));
            addlistener(this.OkayBtn,'ButtonPushed',@(es,ed)cbOkayBtn(this));
            addlistener(this.CancelBtn,'ButtonPushed',@(es,ed)cbCancelBtn(this));
            addlistener(this.SelectedFileEditField,'ValueChanged',@(es,ed)cbEnableOkBtn(this));

            this.SelectFromWorkspaceRadioBtn.Parent.SelectionChangedFcn=@(es,ed)cbRadioButtonSelectionChange(this,es);
        end
    end

    methods(Access='private')
        function listOfVariables=getWorkspaceVariables(~,workspaceVariableClassFilter)
            allVars=evalin('base','whos');
            listOfVariables=[];
            for i=1:numel(allVars)
                if(isempty(workspaceVariableClassFilter))
                    listOfVariables=[listOfVariables,string(allVars(i).name)];
                else

                    for j=1:numel(workspaceVariableClassFilter)
                        if(strcmp(allVars(i).class,workspaceVariableClassFilter(j))...
                            &&allVars(i).bytes>0...
                            &&sum(allVars(i).size)==2)
                            listOfVariables=[listOfVariables,string(allVars(i).name)];
                            break;
                        end
                    end
                end
            end
        end

        function setFocus(this)
            if(~isempty(this.ParentFig))
                if(isa(this.ParentFig,'matlab.ui.container.internal.AppContainer'))
                    bringToFront(this.ParentFig);
                end
            end
            figure(this.UIFigure);
        end

        function setBusy(this,flag)
            persistent mousePointer;
            if(flag)

                this.FigBusy=true;
                mousePointer=this.UIFigure.Pointer;
                this.UIFigure.Pointer="watch";
                this.RadioButtonGroup.Enable='off';
            else
                if(isempty(mousePointer))
                    mousePointer=this.UIFigure.Pointer;
                end

                this.FigBusy=false;
                this.UIFigure.Pointer=mousePointer;
                this.RadioButtonGroup.Enable='on';
            end
        end

        function cbBrowseBtn(this)
            persistent currentlyBrowsing;
            if(isempty(currentlyBrowsing))
                currentlyBrowsing=true;
                setBusy(this,true);

                [filename,pathname]=uigetfile('*.mat');
                if(filename~=0)
                    file=fullfile(pathname,filename);
                    this.SelectedFileEditField.Value=file;
                    cbEnableOkBtn(this);
                end
                currentlyBrowsing=[];
                setBusy(this,false);
                setFocus(this);
            end
        end

        function cbOkayBtn(this)
            errorFlag=false;

            if(this.WorkspaceOrFileSelectedFlag)
                this.SelectedValue=evalin('base',this.WSVariablesDropDown.Value);
                this.WsOrFilename=this.WSVariablesDropDown.Value;
            else
                [this.SelectedValue,fnLoad]=loadVarFromFile(this,this.SelectedFileEditField.Value);
                if(isempty(this.SelectedValue))
                    errorFlag=true;
                else
                    this.WsOrFilename=fnLoad;
                end
            end

            if(~errorFlag)
                this.IsOkayClicked=true;
                this.close();
            end
        end

        function[value,fnLoad]=loadVarFromFile(this,filename)

            fnLoad=[];
            value=[];

            try
                temp=load(filename);
            catch

                uialert(this.UIFigure,...
                string(message('lidar:lidarCameraCalibrator:matFileLoadError',filename)),...
                this.Title);
                return;
            end

            fields=fieldnames(temp);

            for i=1:numel(fields)
                for j=1:numel(this.WorkspaceVariableClassFilter)
                    if(isa(getfield(temp,fields{i}),this.WorkspaceVariableClassFilter(j)))
                        value=getfield(temp,fields{i});

                        fnLoad=sprintf("load('%s').%s",filename,fields{i});
                        break;
                    end
                end
                if(~isempty(value))
                    break;
                end
            end
            if(isempty(value))

                uialert(this.UIFigure,...
                string(message('lidar:lidarCameraCalibrator:noValidVariablesInFile')),...
                this.Title);
            end

        end

        function cbCancelBtn(this)
            if(this.FigBusy)
                return;
            end
            this.close();
        end

        function cbEnableOkBtn(this)

            if(this.WSVariablesDropDown.Enable)
                if(length(this.DropdownListItems)==1&&...
                    this.DropdownListItems(1)==string(message('lidar:lidarCameraCalibrator:noValidVariables')))
                    this.OkayBtn.Enable=false;
                else
                    this.OkayBtn.Enable=true;
                end
            else
                if(isempty(this.SelectedFileEditField.Value)||...
                    (~isempty(this.SelectedFileEditField.Value)&&~isfile(this.SelectedFileEditField.Value)))
                    this.OkayBtn.Enable=false;
                else
                    [~,~,fileExt]=fileparts(this.SelectedFileEditField.Value);
                    if(~strcmpi(fileExt,'.mat'))
                        this.OkayBtn.Enable=false;
                    else
                        this.OkayBtn.Enable=true;
                    end
                end
            end
        end

        function cbRadioButtonSelectionChange(this,one)

            switch(one.SelectedObject.Tag)
            case 'fromWS'


                this.WSVariablesDropDown.Enable=true;

                this.SelectedFileEditField.Enable=false;
                this.BrowseBtn.Enable=false;

                this.WorkspaceOrFileSelectedFlag=true;
            case 'fromFile'


                this.WSVariablesDropDown.Enable=false;

                this.SelectedFileEditField.Enable=true;
                this.BrowseBtn.Enable=true;

                this.WorkspaceOrFileSelectedFlag=false;
            end
            cbEnableOkBtn(this);
        end
    end

end
