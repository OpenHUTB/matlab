




classdef NominalValueView<matlab.apps.AppBase

    properties(Access=private)


        UIFigure matlab.ui.Figure



        UIFigureGridLayout matlab.ui.container.GridLayout



        AddRemoveGridLayout matlab.ui.container.GridLayout



        TitleGridLayout matlab.ui.container.GridLayout



        TableGridLayout matlab.ui.container.GridLayout



        PushButtonGridLayout matlab.ui.container.GridLayout


        AddRowImage matlab.ui.control.Image


        DeleteRowImage matlab.ui.control.Image


        Panel matlab.ui.container.Panel



        StatusPanel matlab.ui.container.Panel



        DescriptionLabel matlab.ui.control.Label


        UITable matlab.ui.control.Table



        ContextMenu matlab.ui.container.ContextMenu


        AddRowMenu matlab.ui.container.Menu


        DeleteRowMenu matlab.ui.container.Menu


        OKButton matlab.ui.control.Button


        CancelButton matlab.ui.control.Button


        HelpButton matlab.ui.control.Button


        ApplyButton matlab.ui.control.Button

    end

    properties(Access=private)


SelectedCellIndices


newMdlName
    end

    properties(Access=private)



FigureCloseListener
    end

    events


FigureDeleted




AddRowSelection




DeleteRowSelection



TableCellSelected



TableCellEdited



OkButtonPushed



CancelButtonPushed



HelpButtonPushed



ApplyButtonPushed



ModelNameModified

    end


    methods

        function app=NominalValueView()



        end

        function createGUIComponents(app)

            createComponents(app);


            registerApp(app,app.UIFigure);



            app.UIFigure.Visible="on";
        end

        function closeFigure(app)
            if(lIsAppHandleValid(app.UIFigure))
                close(app.UIFigure);
            end
        end

        function apphandle=getFigureHandle(app)
            apphandle=app.UIFigure;
        end

        function setTitle(app,nominalValueTitle)
            app.UIFigure.Name=lGetString('Title',nominalValueTitle);
        end

        function setData(app,data)
            app.UITable.Data=[{data.Values}',{data.Units}'];
        end

        function setSelectedCellEmpty(app)
            app.SelectedCellIndices=[];
        end

        function selectedCellIndices=getSelectedCellIndices(app)
            selectedCellIndices=app.SelectedCellIndices;
        end

        function[currentNominalValue,currentUnit]=getRowData(app,cellIndex)
            currentNominalValue=app.UITable.Data(cellIndex(1),1);
            currentUnit=app.UITable.Data(cellIndex(1),2);
        end

        function newMdlName=getNewMdlName(app)
            newMdlName=app.newMdlName;
        end

        function setStatusPanelTitle(app,statusPanelTitle)
            app.StatusPanel.Title=statusPanelTitle;
        end

        function updateMdlName(app,newMdlName)
            app.newMdlName=newMdlName;
            notify(app,'ModelNameModified');
        end

        function displayInvalidValueErrorDlg(app,errorMsg,TokenErrorDialogTitle)
            uiconfirm(app.UIFigure,errorMsg,TokenErrorDialogTitle,'Options',...
            {lGetString('ButtonOk')},'DefaultOption',1,"Icon","error");
        end

        function selection=displayInvalidValueWarningDlg(app,cancelDialogText,cancelDialogTitle)
            selection=uiconfirm(app.UIFigure,cancelDialogText,cancelDialogTitle,...
            'Options',{lGetString('ButtonYes'),lGetString('ButtonNo')},...
            'DefaultOption',1,"Icon","warning",'CloseFcn',@(src,event)cancelCallback(app,src,event));
        end

        function setRowStatus(app,rowStatus,rowIdx)
            switch rowStatus
            case 'Edited'
                setEditedRowBackgroundColor(app,rowIdx);
            case 'Deleted'
                setWhiteBackgroundColorinRow(app,rowIdx);
            end
        end

        function setStatusPanelState(app,rowStatus)
            switch rowStatus
            case{'Edited','Deleted','Apply'}
                setStatusPanelColor(app,"black")
            case 'Error'
                setStatusPanelColor(app,"red");
            end
        end

        function enableDeleteRow(app)
            app.DeleteRowImage.Enable="on";
            app.DeleteRowMenu.Enable="on";
        end

        function disableDeleteRow(app)
            app.DeleteRowImage.Enable="off";
            app.DeleteRowMenu.Enable="off";
        end

        function enableApply(app)
            app.ApplyButton.Enable="on";
        end

        function disableApply(app)
            app.ApplyButton.Enable="off";
        end

        function applyButtonStatus=getApplyButtonStatus(app)
            applyButtonStatus=app.ApplyButton.Enable;
        end
    end

    methods(Access=private)

        function createComponents(app)


            createUIFigure(app);


            createGridLayout(app);


            createAddDeleteRowImages(app);


            createTitleStatusPanel(app);


            createDescriptionLabel(app);


            createUITable(app);


            createContextMenu(app);


            createPushButtons(app);

        end

        function createUIFigure(app)

            app.UIFigure=uifigure('Visible','off');
            app.UIFigure.Units='pixels';
            app.UIFigure.Position=[850,450,440,600];

            movegui(app.UIFigure,'center')
            app.UIFigure.Icon=getIconPath('layoutView_16.png');
            app.UIFigure.Scrollable='off';
            app.UIFigure.Tag='NominalValueViewer';
            app.FigureCloseListener=event.listener(app,'ObjectBeingDestroyed',@app.uiFigureCloseCallback);
        end

        function createGridLayout(app)

            app.UIFigureGridLayout=uigridlayout(app.UIFigure);
            app.UIFigureGridLayout.ColumnWidth={'1x'};
            app.UIFigureGridLayout.RowHeight={45,80,'1x',43,23};
            app.UIFigureGridLayout.Padding=[1,1,1,10];


            app.AddRemoveGridLayout=uigridlayout(app.UIFigureGridLayout);
            app.AddRemoveGridLayout.ColumnWidth={30,30};
            app.AddRemoveGridLayout.RowHeight={30};
            app.AddRemoveGridLayout.Layout.Row=1;
            app.AddRemoveGridLayout.Layout.Column=1;


            app.TitleGridLayout=uigridlayout(app.UIFigureGridLayout);
            app.TitleGridLayout.ColumnWidth={'1x'};
            app.TitleGridLayout.RowHeight={'1x'};
            app.TitleGridLayout.Layout.Row=2;
            app.TitleGridLayout.Layout.Column=1;


            app.TableGridLayout=uigridlayout(app.UIFigureGridLayout);
            app.TableGridLayout.ColumnWidth={'1x'};
            app.TableGridLayout.RowHeight={'1x'};
            app.TableGridLayout.Layout.Row=3;
            app.TableGridLayout.Layout.Column=1;


            app.PushButtonGridLayout=uigridlayout(app.UIFigureGridLayout);
            app.PushButtonGridLayout.ColumnWidth={'1x',70,70,70,70};
            app.PushButtonGridLayout.RowHeight={'1x'};
            app.PushButtonGridLayout.ColumnSpacing=12;
            app.PushButtonGridLayout.Layout.Row=4;
            app.PushButtonGridLayout.Layout.Column=1;
        end

        function createAddDeleteRowImages(app)

            app.AddRowImage=uiimage(app.AddRemoveGridLayout);
            app.AddRowImage.ImageClickedFcn=createCallbackFcn(app,@addRowSelection,true);
            app.AddRowImage.Layout.Row=1;
            app.AddRowImage.Layout.Column=1;
            app.AddRowImage.ImageSource=getIconPath('newVariable.svg');
            app.AddRowImage.Tag='NominalValueViewerAddRowIcon';
            app.AddRowImage.Tooltip=lGetString('ToolBarButtonAdd');

            app.DeleteRowImage=uiimage(app.AddRemoveGridLayout);
            app.DeleteRowImage.ImageClickedFcn=createCallbackFcn(app,@deleteRowSelection,true);
            app.DeleteRowImage.Enable='off';
            app.DeleteRowImage.Layout.Row=1;
            app.DeleteRowImage.Layout.Column=2;
            app.DeleteRowImage.ImageSource=getIconPath('variableDelete.svg');
            app.DeleteRowImage.Tag='NominalValueViewerDeleteRowIcon';
            app.DeleteRowImage.Tooltip=lGetString('ToolBarButtonDelete');
        end

        function createTitleStatusPanel(app)

            app.Panel=uipanel(app.TitleGridLayout);
            app.Panel.Title=lGetString('DescriptionTitle');
            app.Panel.Layout.Row=1;
            app.Panel.Layout.Column=1;
            app.Panel.FontWeight='bold';
            app.Panel.FontSize=14;
            app.Panel.Tag='NominalValueViewerStatusPanelTitle';


            app.StatusPanel=uipanel(app.UIFigureGridLayout);
            app.StatusPanel.Layout.Row=5;
            app.StatusPanel.Layout.Column=1;
            app.StatusPanel.Tag='NominalValueViewerStatusPanel';
        end

        function createDescriptionLabel(app)
            app.DescriptionLabel=uilabel(app.Panel);
            app.DescriptionLabel.Position=[3,0,415,36];
            app.DescriptionLabel.Text=lGetString('DescriptionText');
            app.DescriptionLabel.Tag='NominalValueViewerDescription';
        end

        function createUITable(app)
            app.UITable=uitable(app.TableGridLayout);
            app.UITable.ColumnName={lGetString('TableColumnNominalValue')...
            ,lGetString('TableColumnNominalUnit')};
            app.UITable.RowName={};
            app.UITable.ColumnSortable=true;
            app.UITable.ColumnEditable=true;
            app.UITable.CellSelectionCallback=createCallbackFcn(app,@uiTableCellSelected,true);
            app.UITable.CellEditCallback=createCallbackFcn(app,@uiTableCellEdited,true);
            app.UITable.Layout.Row=1;
            app.UITable.Layout.Column=1;
            app.UITable.FontWeight="normal";
            app.UITable.FontAngle="normal";
            app.UITable.Tag='NominalValueViewerTable';

            addTableBackgroundColor(app);
        end

        function createContextMenu(app)

            app.ContextMenu=uicontextmenu(app.UIFigure);


            app.AddRowMenu=uimenu(app.ContextMenu);
            app.AddRowMenu.MenuSelectedFcn=createCallbackFcn(app,@addRowSelection,true);
            app.AddRowMenu.Tag='NominalValueViewerAddRowMenu';
            app.AddRowMenu.Text=lGetString('MenuOptionsAdd');
            app.AddRowMenu.Enable="on";


            app.DeleteRowMenu=uimenu(app.ContextMenu);
            app.DeleteRowMenu.MenuSelectedFcn=createCallbackFcn(app,@deleteRowSelection,true);
            app.DeleteRowMenu.Tag='NominalValueViewerDeleteRowMenu';
            app.DeleteRowMenu.Text=lGetString('MenuOptionsDelete');
            app.DeleteRowMenu.Enable="off";


            app.UITable.ContextMenu=app.ContextMenu;
        end

        function createPushButtons(app)

            app.OKButton=uibutton(app.PushButtonGridLayout,'push');
            app.OKButton.ButtonPushedFcn=createCallbackFcn(app,@okButtonPushed,true);
            app.OKButton.Layout.Row=1;
            app.OKButton.Layout.Column=2;
            app.OKButton.Tag='NominalValueViewerOkButton';
            app.OKButton.Text=lGetString('ButtonOk');
            app.OKButton.Tooltip=lGetString('ButtonOkTooltip');


            app.CancelButton=uibutton(app.PushButtonGridLayout,'push');
            app.CancelButton.ButtonPushedFcn=createCallbackFcn(app,@cancelButtonPushed,true);
            app.CancelButton.Layout.Row=1;
            app.CancelButton.Layout.Column=3;
            app.CancelButton.Tag='NominalValueViewerCancelButton';
            app.CancelButton.Text=lGetString('ButtonCancel');
            app.CancelButton.Tooltip=lGetString('ButtonCancelTooltip');


            app.HelpButton=uibutton(app.PushButtonGridLayout,'push');
            app.HelpButton.ButtonPushedFcn=createCallbackFcn(app,@helpButtonPushed,true);
            app.HelpButton.Layout.Row=1;
            app.HelpButton.Layout.Column=4;
            app.HelpButton.Tag='NominalValueViewerHelpButton';
            app.HelpButton.Text=lGetString('ButtonHelp');
            app.HelpButton.Tooltip=lGetString('ButtonHelpTooltip');


            app.ApplyButton=uibutton(app.PushButtonGridLayout,'push');
            app.ApplyButton.ButtonPushedFcn=createCallbackFcn(app,@applyButtonPushed,true);
            app.ApplyButton.Enable='off';
            app.ApplyButton.Layout.Row=1;
            app.ApplyButton.Layout.Column=5;
            app.ApplyButton.Tag='NominalValueViewerApplyButton';
            app.ApplyButton.Text=lGetString('ButtonApply');
            app.ApplyButton.Tooltip=lGetString('ButtonApplyTooltip');
        end
    end

    methods(Access=private)


        function addTableBackgroundColor(app)
            whiteColorRightAlign=uistyle("BackgroundColor","white","FontWeight",...
            "normal","HorizontalAlignment","right");
            whiteColorLeftAlign=uistyle("BackgroundColor","white","FontWeight",...
            "normal","HorizontalAlignment","left");
            addStyle(app.UITable,whiteColorRightAlign,"column",1);
            addStyle(app.UITable,whiteColorLeftAlign,"column",2);
        end

        function setWhiteBackgroundColorinRow(app,selectedCellIndices)
            whiteColor=uistyle("BackgroundColor","white");
            addStyle(app.UITable,whiteColor,"row",selectedCellIndices(1));
        end

        function setEditedRowBackgroundColor(app,editedCellIndices)
            beigeColor=uistyle("BackgroundColor",[0.90,0.85,0.72]);
            addStyle(app.UITable,beigeColor,"row",editedCellIndices(1));
        end

        function setStatusPanelColor(app,foreGroundColor)
            app.StatusPanel.ForegroundColor=foreGroundColor;
        end

        function cancelCallback(app,~,event)
            selectedOption=event.SelectedOption;
        end

    end

    methods(Access=private)


        function addRowSelection(app,~)
            app.notify('AddRowSelection');
        end

        function deleteRowSelection(app,~)
            app.notify('DeleteRowSelection');
        end

        function uiTableCellSelected(app,event)
            app.SelectedCellIndices=event.Indices;
            app.notify('TableCellSelected');
        end

        function uiTableCellEdited(app,event)
            eventData=simscape.nominal.internal.viewer.CellEditedEventData(...
            event.Indices,event.PreviousData);
            app.notify('TableCellEdited',eventData);
        end

        function okButtonPushed(app,~)
            app.notify('OkButtonPushed');
        end

        function cancelButtonPushed(app,~)
            app.notify('CancelButtonPushed');
        end

        function helpButtonPushed(app,~)
            app.notify('HelpButtonPushed');
        end

        function applyButtonPushed(app,~)
            app.notify('ApplyButtonPushed');
        end

        function uiFigureCloseCallback(app,~,~)
            app.notify('FigureDeleted');
        end
    end
end


function msgString=lGetString(messageID,varargin)

    fullId=strcat('physmod:simscape:simscape:nominal:viewer:',messageID);
    msgString=getString(message(fullId,varargin{:}));
end

function path=getIconPath(filename)


    path=fullfile(matlabroot,'toolbox','physmod','simscape',...
    'simscape','m','resources',filename);
end

function res=lIsAppHandleValid(apphandle)
    res=~isempty(apphandle)&&ishandle(apphandle)&&isvalid(apphandle);
end