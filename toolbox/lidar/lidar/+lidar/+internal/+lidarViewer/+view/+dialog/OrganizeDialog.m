


































classdef OrganizeDialog<lidar.internal.lidarViewer.view.dialog.helper.Dialog

    properties

NameList


Message
    end

    properties(Access=private)

        DeleteButton matlab.ui.control.Button
        RenameButton matlab.ui.control.Button
        CloseButton matlab.ui.control.Button
        MessageLabel matlab.ui.control.Label
        List matlab.ui.control.ListBox

        EditBox matlab.ui.control.EditField
        OkButton matlab.ui.control.Button
        GoBackButton matlab.ui.control.Button
        RenameMessage matlab.ui.control.Label
    end

    properties(Access=private)
        DeleteButtonPos(1,4)int32
        RenameButtonPos(1,4)int32
        CloseButtonPos(1,4)int32
        MessageLabelPos(1,4)int32
        ListPos(1,4)int32

        EditBoxPos(1,4)int32
        OkButtonPos(1,4)int32
        GoBackButtonPos(1,4)int32
        RenameMessagePos(1,4)int32
    end

    properties(Access=private)
ListItemSelected
UserAction
    end

    methods



        function this=OrganizeDialog(title,message,nameList)
            this=this@lidar.internal.lidarViewer.view.dialog.helper.Dialog(title,[400,200]);


            this.NameList=nameList;
            this.Message=message;

            this.ListItemSelected=this.NameList{1};


            this.calculatePosition();
            this.createUI();
        end




        function userAction=getUserAction(this)
            userAction=this.UserAction;
        end
    end




    methods(Access=private)

        function calculatePosition(this)
            mainFigDim=this.Size;


            leftMar=mainFigDim(1)/20;
            btnWidth=80;
            btnHeight=30;
            btnOffset=(mainFigDim(1)-3*btnWidth)/4;

            this.DeleteButtonPos=[btnOffset,mainFigDim(2)*0.8,btnWidth,btnHeight];
            this.RenameButtonPos=[btnOffset*2+btnWidth,mainFigDim(2)*0.8,btnWidth,btnHeight];
            this.CloseButtonPos=[btnOffset*3+2*btnWidth,mainFigDim(2)*0.8,btnWidth,btnHeight];


            messageWidth=mainFigDim(1)-2*leftMar;
            messageHeight=mainFigDim(2)*0.125;
            this.MessageLabelPos=[leftMar,mainFigDim(2)*0.65,messageWidth,messageHeight];


            listWidth=mainFigDim(1)-2*leftMar;
            listHeight=mainFigDim(2)*0.5;
            this.ListPos=[leftMar,mainFigDim(2)*0.1,listWidth,listHeight];


            this.RenameMessagePos=[leftMar,mainFigDim(2)*.75,messageWidth,messageHeight];


            this.EditBoxPos=[leftMar,mainFigDim(2)*.45,mainFigDim(1)-2*leftMar,mainFigDim(2)*.2];


            this.OkButtonPos=[(mainFigDim(1)/2-btnWidth-0.5*leftMar),mainFigDim(2)*.1,btnWidth,btnHeight];
            this.GoBackButtonPos=[(mainFigDim(1)/2+0.5*leftMar),mainFigDim(2)*.1,btnWidth,btnHeight];
        end


        function createUI(this)


            this.createDeleteButton();
            this.createRenameButton();
            this.createCloseButton();

            this.addMessage();
            this.createList();


            this.createEditBox();
            this.createOkButton();
            this.createGoBackButton();
            this.createRenameMessage();
        end


        function createDeleteButton(this)
            this.DeleteButton=uibutton('Parent',this.MainFigure,...
            'Position',this.DeleteButtonPos,...
            'Text',getString(message('lidar:lidarViewer:Delete')),...
            'Tag','orgCameraViewDlgDeleteBtn',...
            'ButtonPushedFcn',@(~,~)requestToDelete(this));
        end


        function createRenameButton(this)
            this.RenameButton=uibutton('Parent',this.MainFigure,...
            'Position',this.RenameButtonPos,...
            'Text',getString(message('lidar:lidarViewer:Rename')),...
            'Tag','orgCameraViewDlgRenameBtn',...
            'ButtonPushedFcn',@(~,~)requestToRename(this));
        end


        function createCloseButton(this)
            this.CloseButton=uibutton('Parent',this.MainFigure,...
            'Position',this.CloseButtonPos,...
            'Text',getString(message('lidar:lidarViewer:Close')),...
            'Tag','orgCameraViewDlgCloseBtn',...
            'ButtonPushedFcn',@(~,~)requestToClose(this));
        end


        function addMessage(this)
            this.MessageLabel=uilabel('Parent',this.MainFigure,...
            'Position',this.MessageLabelPos,...
            'FontSize',14,...
            'Text',this.Message);
        end


        function createList(this)
            this.List=uilistbox('Parent',this.MainFigure,...
            'Position',this.ListPos,...
            'Items',this.NameList,...
            'Tag','orgCameraViewDlgList',...
            'ValueChangedFcn',@(~,evt)this.userClicked(evt),...
            'FontSize',14);
            this.ListItemSelected=this.List.Value;
        end


        function createEditBox(this)
            this.EditBox=uieditfield('Parent',this.MainFigure,...
            'Position',this.EditBoxPos,...
            'Tag','orgCameraViewDlgEB',...
            'Visible','off');
        end


        function createOkButton(this)
            this.OkButton=uibutton('Parent',this.MainFigure,...
            'Position',this.OkButtonPos,...
            'Text',getString(message('MATLAB:uistring:popupdialogs:OK')),...
            'Tag','orgCameraViewDlgOKBtn',...
            'Visible','off',...
            'ButtonPushedFcn',@(~,~)this.renameOkPressed());
        end


        function createGoBackButton(this)
            this.GoBackButton=uibutton('Parent',this.MainFigure,...
            'Position',this.GoBackButtonPos,...
            'Text',getString(message('lidar:lidarViewer:GoBack')),...
            'Tag','orgCameraViewDlgGoBackBtn',...
            'Visible','off',...
            'ButtonPushedFcn',@(~,~)this.requestToGoBack());
        end


        function createRenameMessage(this)
            this.RenameMessage=uilabel('Parent',this.MainFigure,...
            'Position',this.RenameMessagePos,...
            'FontSize',14,...
            'Visible','off');
        end
    end




    methods(Access=private)

        function requestToDelete(this)



            userAction=uiconfirm(this.MainFigure,...
            getString(message('lidar:lidarViewer:CameraViewDeleteWarning')),...
            getString(message('lidar:lidarViewer:Warning')),...
            'Options',{getString(message('MATLAB:uistring:popupdialogs:Yes')),...
            getString(message('MATLAB:uistring:popupdialogs:No'))});

            if strcmp(userAction,getString(message('lidar:lidarViewer:No')))
                return;
            end

            userInfo=this.createUserInfo('delete',this.ListItemSelected);
            this.UserAction{end+1}=userInfo;
            index=find(strcmp(this.NameList,this.ListItemSelected),1);
            this.NameList(index)=[];
            this.List.Items=this.NameList;
            this.ListItemSelected=this.List.Value;

            if isempty(this.NameList)
                this.DeleteButton.Enable=false;
                this.RenameButton.Enable=false;
            end
        end


        function requestToRename(this)


            this.setIntialDialog(false);
            this.RenameMessage.Text=...
            [getString(message('lidar:lidarViewer:CameraViewRenameMessage',...
            this.ListItemSelected))];
        end


        function requestToClose(this)
            this.close();
        end


        function userClicked(this,evt)
            this.ListItemSelected=evt.Value;
        end


        function renameOkPressed(this)


            newName=this.EditBox.Value;
            isValid=this.isValidName(newName);

            if~isValid
                this.EditBox.Value='';
                return;
            end

            userInfo=this.createUserInfo('rename',this.ListItemSelected,...
            newName);
            this.UserAction{end+1}=userInfo;

            index=find(strcmp(this.NameList,this.ListItemSelected),1);
            this.NameList{index}=newName;

            this.createList();
            this.setIntialDialog(true);
        end


        function requestToGoBack(this)


            this.setIntialDialog(true);

            this.createList();
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

            index=find(strcmp(this.NameList,name),1);
            if isempty(index)
                TF=true;
            else
                uialert(this.MainFigure,...
                getString(message('lidar:lidarViewer:CameraViewNameExitsMessage',name)),...
                getString(message('lidar:lidarViewer:CameraViewNameExitsTitle')));
                TF=false;
            end
        end


        function setIntialDialog(this,TF)


            this.MainFigure.Visible=false;

            this.DeleteButton.Visible=TF;
            this.RenameButton.Visible=TF;
            this.CloseButton.Visible=TF;
            this.MessageLabel.Visible=TF;
            this.List.Visible=TF;


            this.RenameMessage.Visible=~TF;
            this.EditBox.Visible=~TF;
            this.EditBox.Value='';
            this.OkButton.Visible=~TF;
            this.GoBackButton.Visible=~TF;

            this.MainFigure.Visible=true;
        end
    end




    methods(Access=private,Static)

        function userInfo=createUserInfo(op,name,newName)


            userInfo=struct();
            userInfo.Operation=op;
            if strcmp(op,'delete')
                userInfo.Data=name;
            else
                userInfo.Data={name;newName};
            end

        end
    end
end