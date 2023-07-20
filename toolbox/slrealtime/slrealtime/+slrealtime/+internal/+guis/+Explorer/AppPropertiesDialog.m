classdef AppPropertiesDialog<matlab.apps.AppBase





    properties(Access=public)
        UIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        TableGridLayout matlab.ui.container.GridLayout
        UITable matlab.ui.control.Table
        ButtonGridLayout matlab.ui.container.GridLayout
        CloseButton matlab.ui.control.Button
        RefreshButton matlab.ui.control.Button

CallingApp
AppName
    end


    methods(Access=private)


        function CloseButtonPushed(app)

            app.UIFigureCloseRequest();
        end


        function RefreshButtonPushed(app)

            targetName=app.CallingApp.TargetManager.getSelectedTargetName();
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);

            app.updateUITable(tg);
        end


        function UIFigureCloseRequest(app)

            window=app.CallingApp.App;


            slrealtime.internal.guis.Explorer.AppPropertiesDialogWrapper.dialogClosed(app.AppName);


            delete(app)


            window.bringToFront();
        end
    end


    methods(Access=private)


        function createComponents(app)

            window=app.CallingApp.App.WindowBounds;

            width=390;
            height=390;

            center=window(1)+window(3)/2;
            left=center-width/2;
            center=window(2)+window(4)/2;
            up=center-height/2;


            app.UIFigure=uifigure('Visible','off');
            app.UIFigure.Position=[left,up,width,height];
            app.UIFigure.Name=[app.AppName,' ',...
            message('slrealtime:explorer:properties').getString];
            app.UIFigure.CloseRequestFcn=createCallbackFcn(app,@UIFigureCloseRequest);


            app.GridLayout=uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth={'1x'};
            app.GridLayout.RowHeight={'1x',25};


            app.TableGridLayout=uigridlayout(app.GridLayout);
            app.TableGridLayout.ColumnWidth={'1x'};
            app.TableGridLayout.RowHeight={'1x'};
            app.TableGridLayout.ColumnSpacing=1;
            app.TableGridLayout.RowSpacing=1;
            app.TableGridLayout.Padding=[1,1,1,1];
            app.TableGridLayout.Layout.Row=1;
            app.TableGridLayout.Layout.Column=1;


            app.UITable=uitable(app.TableGridLayout);
            app.UITable.ColumnName={...
            message('slrealtime:explorer:propertyName').getString;...
            message('slrealtime:explorer:value').getString};
            app.UITable.ColumnWidth={160,'auto'};
            app.UITable.RowName={};
            app.UITable.ColumnSortable=[true,false];
            app.UITable.Layout.Row=1;
            app.UITable.Layout.Column=1;


            app.ButtonGridLayout=uigridlayout(app.GridLayout);
            app.ButtonGridLayout.ColumnWidth={'1x',100,100};
            app.ButtonGridLayout.RowHeight={'1x'};
            app.ButtonGridLayout.RowSpacing=1;
            app.ButtonGridLayout.Padding=[1,1,1,1];
            app.ButtonGridLayout.Layout.Row=2;
            app.ButtonGridLayout.Layout.Column=1;


            app.CloseButton=uibutton(app.ButtonGridLayout,'push');
            app.CloseButton.ButtonPushedFcn=createCallbackFcn(app,@CloseButtonPushed);
            app.CloseButton.Layout.Row=1;
            app.CloseButton.Layout.Column=3;
            app.CloseButton.Text=message('slrealtime:explorer:close').getString;


            app.RefreshButton=uibutton(app.ButtonGridLayout,'push');
            app.RefreshButton.ButtonPushedFcn=createCallbackFcn(app,@RefreshButtonPushed);
            app.RefreshButton.Layout.Row=1;
            app.RefreshButton.Layout.Column=2;
            app.RefreshButton.Text=message('slrealtime:explorer:refresh').getString;


            app.UIFigure.Visible='on';
        end
    end


    methods(Access=public)


        function app=AppPropertiesDialog(hCallingApp,appName,tg)

            app.CallingApp=hCallingApp;
            app.AppName=appName;


            createComponents(app)

            app.updateUITable(tg);




            if nargout==0
                clear app
            end
        end


        function delete(app)

            app.CallingApp=[];
            app.AppName='';


            delete(app.UIFigure)
        end
    end


    methods(Access=private)

        function updateUITable(app,tg)
            mldatx=tg.getAppFile(app.AppName);
            appObj=slrealtime.Application(mldatx);
            appInfo=appObj.getInformation;
            nFields=length(fieldnames(appInfo));




            assert((nFields==11),...
            'The info displayed in Properties Dialog should be updated to be consistent with the return value of appObj.getInformation().')

            app.UITable.Data={...
            message('slrealtime:explorer:applicationName').getString,appInfo.ApplicationName;...
            message('slrealtime:explorer:modelName').getString,appInfo.ModelName;...
            message('slrealtime:explorer:applicationCreation').getString,appInfo.ApplicationCreationDate;...
            message('slrealtime:explorer:applicationLastModified').getString,appInfo.ApplicationLastModifiedDate;...
            message('slrealtime:explorer:modelCreation').getString,appInfo.ModelCreationDate;...
            message('slrealtime:explorer:modelLastModified').getString,appInfo.ModelLastModifiedDate;...
            message('slrealtime:explorer:modelVersion').getString,appInfo.ModelVersion;...
            message('slrealtime:explorer:modelLastModifiedBy').getString,appInfo.ModelLastModifiedBy;...
            message('slrealtime:explorer:modelSolverType').getString,appInfo.ModelSolverType;...
            message('slrealtime:explorer:modelSolverName').getString,appInfo.ModelSolverName;...
            message('slrealtime:explorer:MATLABVersion').getString,appInfo.MatlabVersion};


            s=uistyle;
            s.FontWeight='bold';
            addStyle(app.UITable,s,'cell',[(1:nFields)',ones(nFields,1)]);
        end
    end
end
