




classdef SaveCamViewDlg<vision.internal.uitools.OkCancelDlg

    properties(Access=protected)
EditBox
SavedNames
CamViewName
    end

    properties
ContainerObj
    end

    methods
        function this=SaveCamViewDlg(tool,savedNames)
            dlgTitle=vision.getMessage('lidar:labeler:lidarCamViewSave');

            this=this@vision.internal.uitools.OkCancelDlg(tool,dlgTitle);
            this.DlgSize=[350,175];

            createDialog(this);

            this.ContainerObj=tool;

            if~useAppContainer
                uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','normalized',...
                'Position',[0.1,0.55,0.9,0.35],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('lidar:labeler:SaveCamViewDlgText'));

                this.EditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'String','',...
                'Units','normalized',...
                'Position',[0.1,0.40,0.8,0.25],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','saveCamViewEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');

                this.EditBox.KeyPressFcn=@this.onKeyPress;
            else
                uilabel('Parent',this.Dlg,...
                'Position',[35,96.25,315,61.25],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('lidar:labeler:SaveCamViewDlgText'));

                this.EditBox=uieditfield('Parent',this.Dlg,...
                'Value','',...
                'Position',[35,70,280,43.75],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','saveCamViewEditBox',...
                'FontAngle','normal',...
                'Enable','on');

                this.EditBox.ValueChangingFcn=@this.onKeyPress;
            end
            this.SavedNames=savedNames;
        end

        function name=getSavedName(this)
            name=this.CamViewName;
        end
    end

    methods(Access=protected)
        function onOK(this,~,~)

            if~useAppContainer
                camViewName=get(this.EditBox,'String');
            else
                camViewName=get(this.EditBox,'Value');
            end

            if isvarname(camViewName)
                index=find(strcmp(this.SavedNames,camViewName));
                if isempty(index)
                    this.CamViewName=camViewName;
                    this.IsCanceled=false;
                    close(this);
                else
                    errorMessage=vision.getMessage('lidar:labeler:CameraViewExists',camViewName);
                    dialogName=getString(message('lidar:labeler:CameraViewExistsTitle'));
                    vision.internal.labeler.handleAlert(this.Dlg,'errorWithWaitDlg',errorMessage,dialogName,this.ContainerObj);
                end
            else
                errorMessage=vision.getMessage('lidar:labeler:InvalidViewName',camViewName);
                dialogName=getString(message('lidar:labeler:InvalidViewNameTitle'));
                vision.internal.labeler.handleAlert(this.Dlg,'errorWithWaitDlg',errorMessage,dialogName,this.ContainerObj);
            end
        end

        function onKeyPress(this,~,evd)


        end
    end
end
function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end