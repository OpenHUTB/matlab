














classdef SaveCameraDialog<lidar.internal.lidarViewer.view.dialog.helper.Dialog
    properties

Message


SavedViews


CamViewName


        IsSuccess=false
    end

    properties(Access=private)
        MessageLabel matlab.ui.control.Label
        EditBox matlab.ui.control.EditField
        OkButton matlab.ui.control.Button
        CancelButton matlab.ui.control.Button
    end

    properties(Access=private)
        MessageLabelPos(1,4)int32
        EditBoxPos(1,4)int32
        OkButtonPos(1,4)int32
        CancelButtonPos(1,4)int32
    end

    methods



        function this=SaveCameraDialog(title,message,savedViews)
            this=this@lidar.internal.lidarViewer.view.dialog.helper.Dialog(title,[400,200]);

            this.Message=message;
            this.SavedViews=savedViews;


            this.calculatePosition();
            this.createUI();
        end
    end




    methods(Access=private)

        function calculatePosition(this)
            mainFigDim=this.Size;


            leftMar=mainFigDim(1)/20;
            btnWidth=80;
            btnHeight=30;


            messageWidth=mainFigDim(1)-2*leftMar;
            messageHeight=mainFigDim(2)*0.125;
            this.MessageLabelPos=[leftMar,mainFigDim(2)*.75,messageWidth,messageHeight];


            this.EditBoxPos=[leftMar,mainFigDim(2)*.45,mainFigDim(1)-2*leftMar,mainFigDim(2)*.2];


            this.OkButtonPos=[(mainFigDim(1)/2-btnWidth-0.5*leftMar),mainFigDim(2)*.1,btnWidth,btnHeight];
            this.CancelButtonPos=[(mainFigDim(1)/2+0.5*leftMar),mainFigDim(2)*.1,btnWidth,btnHeight];
        end


        function createUI(this)


            this.createMessageLabel();
            this.createEditBox();
            this.createOkButton();
            this.createCancelButton();
        end


        function createMessageLabel(this)
            this.MessageLabel=uilabel('Parent',this.MainFigure,...
            'Position',this.MessageLabelPos,...
            'FontSize',14,...
            'Text',this.Message);
        end


        function createEditBox(this)
            this.EditBox=uieditfield('Parent',this.MainFigure,...
            'Position',this.EditBoxPos,...
            'Tag','saveCameraViewDlgEB');
        end


        function createOkButton(this)
            this.OkButton=uibutton('Parent',this.MainFigure,...
            'Position',this.OkButtonPos,...
            'Text',getString(message('MATLAB:uistring:popupdialogs:OK')),...
            'Tag','saveCameraViewDlgOKBtn',...
            'ButtonPushedFcn',@(~,~)this.okPressed());
        end


        function createCancelButton(this)
            this.CancelButton=uibutton('Parent',this.MainFigure,...
            'Position',this.CancelButtonPos,...
            'Text',getString(message('MATLAB:uistring:popupdialogs:Cancel')),...
            'Tag','saveCameraViewDlgCancelBtn',...
            'ButtonPushedFcn',@(~,~)this.requestToCancel());
        end
    end




    methods(Access=private)
        function okPressed(this)
            camViewName=this.EditBox.Value;
            isValid=this.isValidName(camViewName);

            if~isValid
                this.EditBox.Value='';
                return;
            end
            this.IsSuccess=true;
            this.close();
        end

        function requestToCancel(this)
            this.close();
        end
    end




    methods(Access=private)

        function TF=isValidName(this,name)
            if~isvarname(name)
                TF=false;
                uialert(this.MainFigure,...
                getString(message('lidar:lidarViewer:InvalidViewNameMessage',name)),...
                getString(message('lidar:lidarViewer:InvalidViewNameTitle')));
                return;
            end

            index=find(strcmp(this.SavedViews,name),1);
            if isempty(index)
                this.CamViewName=name;
                TF=true;
            else
                uialert(this.MainFigure,...
                getString(message('lidar:lidarViewer:CameraViewNameExitsMessage',name)),...
                getString(message('lidar:lidarViewer:CameraViewNameExitsTitle')));
                TF=false;
            end
        end
    end
end