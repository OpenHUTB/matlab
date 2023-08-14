classdef ImportFileLogDialog<matlab.apps.AppBase





    properties(Access=public)
        ImportFileLogUIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        ImportFileLogPanel matlab.ui.container.Panel
        PanelGridLayout matlab.ui.container.GridLayout
        TableGridLayout matlab.ui.container.GridLayout
        FileLogTable matlab.ui.control.Table
        ButtonGridLayout matlab.ui.container.GridLayout
        ImportButton matlab.ui.control.Button
        CancelButton matlab.ui.control.Button
        DeleteButton matlab.ui.control.Button

Icons
CallingApp
    end


    methods(Access=private)


        function ImportButtonPushed(app)
            sels=app.FileLogTable.Selection;
            if isempty(sels)
                return;
            end

            if isempty(app.CallingApp.TargetManager.progressDlg)
                msg1=message('slrealtime:explorer:importing');
                msg2=message('slrealtime:explorer:importingFileLog');
                app.CallingApp.TargetManager.progressDlg=uiprogressdlg(...
                app.ImportFileLogUIFigure,...
                'Indeterminate','on',...
                'Message',msg1.getString(),...
                'Title',msg2.getString());
            end

            try
                targetName=app.CallingApp.TargetManager.getSelectedTargetName();
                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                tg.FileLog.import(sels);
                Simulink.sdi.view;

                app.FileLogTable.Selection=[];
                app.ImportButton.Enable='off';
                app.DeleteButton.Enable='off';
            catch ME
                if~isempty(app.CallingApp.TargetManager.progressDlg)
                    drawnow;
                    delete(app.CallingApp.TargetManager.progressDlg);
                    app.CallingApp.TargetManager.progressDlg=[];
                end
                uialert(app.ImportFileLogUIFigure,ME.message,message('slrealtime:explorer:error').getString());
                return;
            end

            if~isempty(app.CallingApp.TargetManager.progressDlg)
                drawnow;
                delete(app.CallingApp.TargetManager.progressDlg);
                app.CallingApp.TargetManager.progressDlg=[];
            end


            app.ImportFileLogUIFigureCloseRequest();
        end


        function CancelButtonPushed(app)

            app.ImportFileLogUIFigureCloseRequest();
        end


        function DeleteButtonPushed(app)
            sels=app.FileLogTable.Selection;
            if isempty(sels)
                return;
            end

            if isempty(app.CallingApp.TargetManager.progressDlg)
                msg1=message('slrealtime:explorer:deleting');
                msg2=message('slrealtime:explorer:deletingFileLog');
                app.CallingApp.TargetManager.progressDlg=uiprogressdlg(...
                app.ImportFileLogUIFigure,...
                'Indeterminate','on',...
                'Message',msg1.getString(),...
                'Title',msg2.getString());
            end

            try
                targetName=app.CallingApp.TargetManager.getSelectedTargetName();
                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                tg.FileLog.discard(sels);
                app.updateFileLogTable();

                app.FileLogTable.Selection=[];
                app.ImportButton.Enable='off';
                app.DeleteButton.Enable='off';
            catch ME
                uialert(app.ImportFileLogUIFigure,ME.message,message('slrealtime:explorer:error').getString());
            end

            if~isempty(app.CallingApp.TargetManager.progressDlg)
                drawnow;
                delete(app.CallingApp.TargetManager.progressDlg);
                app.CallingApp.TargetManager.progressDlg=[];
            end



        end


        function ImportFileLogUIFigureCloseRequest(app)

            window=app.CallingApp.App;


            app.CallingApp.TargetManager.ImportUIFigure=[];


            delete(app)


            window.bringToFront();
        end


        function FileLogTableCellSelection(app,event)
            sels=event.Source.Selection;
            if isempty(sels)
                app.ImportButton.Enable='off';

                app.DeleteButton.Enable='off';
            else
                app.ImportButton.Enable='on';

                app.DeleteButton.Enable='on';
            end
        end

    end


    methods(Access=private)


        function createComponents(app)

            window=app.CallingApp.App.WindowBounds;

            width=640;
            height=400;

            center=window(1)+window(3)/2;
            left=center-width/2;
            center=window(2)+window(4)/2;
            up=center-height/2;


            app.ImportFileLogUIFigure=uifigure('Visible','off');
            app.ImportFileLogUIFigure.Position=[left,up,width,height];
            app.ImportFileLogUIFigure.Name=getString(message(app.CallingApp.Messages.ImportFileLogUIFigureNameMsgId));
            app.ImportFileLogUIFigure.CloseRequestFcn=createCallbackFcn(app,@ImportFileLogUIFigureCloseRequest);
            app.ImportFileLogUIFigure.WindowStyle='modal';


            app.GridLayout=uigridlayout(app.ImportFileLogUIFigure);
            app.GridLayout.ColumnWidth={'1x'};
            app.GridLayout.RowHeight={'1x'};


            app.ImportFileLogPanel=uipanel(app.GridLayout);
            app.ImportFileLogPanel.Title=getString(message(app.CallingApp.Messages.ImportFileLogPanelTitleMsgId));
            app.ImportFileLogPanel.Layout.Row=1;
            app.ImportFileLogPanel.Layout.Column=1;
            app.ImportFileLogPanel.FontSize=16;


            app.PanelGridLayout=uigridlayout(app.ImportFileLogPanel);
            app.PanelGridLayout.ColumnWidth={'1x'};
            app.PanelGridLayout.RowHeight={'1x',25};
            app.PanelGridLayout.ColumnSpacing=1;
            app.PanelGridLayout.RowSpacing=3;


            app.TableGridLayout=uigridlayout(app.PanelGridLayout);
            app.TableGridLayout.ColumnWidth={'1x'};
            app.TableGridLayout.RowHeight={'1x'};
            app.TableGridLayout.ColumnSpacing=1;
            app.TableGridLayout.RowSpacing=1;
            app.TableGridLayout.Padding=[1,1,1,1];
            app.TableGridLayout.Layout.Row=1;
            app.TableGridLayout.Layout.Column=1;


            app.FileLogTable=uitable(app.TableGridLayout);


            app.FileLogTable.ColumnName={getString(message(app.CallingApp.Messages.importFileLogTableColumnApplicationsMsgId));
            getString(message(app.CallingApp.Messages.importFileLogTableColumnStartDateMsgId));
            getString(message(app.CallingApp.Messages.importFileLogTableColumnSizeMsgId))};
            app.FileLogTable.ColumnWidth={'1x','1x','1x'};
            app.FileLogTable.RowName={};
            app.FileLogTable.Layout.Row=1;
            app.FileLogTable.Layout.Column=1;
            app.FileLogTable.CellSelectionCallback=createCallbackFcn(app,@FileLogTableCellSelection,true);
            app.FileLogTable.SelectionType='row';


            app.ButtonGridLayout=uigridlayout(app.PanelGridLayout);
            app.ButtonGridLayout.ColumnWidth={'1x',100,100,100};
            app.ButtonGridLayout.RowHeight={'1x'};
            app.ButtonGridLayout.RowSpacing=1;
            app.ButtonGridLayout.Padding=[1,1,1,1];
            app.ButtonGridLayout.Layout.Row=2;
            app.ButtonGridLayout.Layout.Column=1;


            app.ImportButton=uibutton(app.ButtonGridLayout,'push');
            app.ImportButton.ButtonPushedFcn=createCallbackFcn(app,@ImportButtonPushed);
            app.ImportButton.Layout.Row=1;
            app.ImportButton.Layout.Column=2;
            app.ImportButton.Text=getString(message(app.CallingApp.Messages.importFileLogImportButtonMsgId));


            app.DeleteButton=uibutton(app.ButtonGridLayout,'push');
            app.DeleteButton.ButtonPushedFcn=createCallbackFcn(app,@DeleteButtonPushed);
            app.DeleteButton.Layout.Row=1;
            app.DeleteButton.Layout.Column=3;
            app.DeleteButton.Text=getString(message(app.CallingApp.Messages.deleteMsgId));


            app.CancelButton=uibutton(app.ButtonGridLayout,'push');
            app.CancelButton.ButtonPushedFcn=createCallbackFcn(app,@CancelButtonPushed);
            app.CancelButton.Layout.Row=1;
            app.CancelButton.Layout.Column=4;
            app.CancelButton.Text=getString(message(app.CallingApp.Messages.importFileLogCancelButtonMsgId));


            app.ImportFileLogUIFigure.Visible='on';
        end
    end


    methods(Access=public)


        function app=ImportFileLogDialog(hCallingApp)

            app.CallingApp=hCallingApp;
            app.Icons=slrealtime.internal.guis.Explorer.Icons;


            createComponents(app)

            app.updateFileLogTable();




            if nargout==0
                clear app
            end
        end


        function delete(app)

            app.CallingApp=[];


            delete(app.ImportFileLogUIFigure);
        end
    end


    methods(Access=private)

        function updateFileLogTable(app)
            targetName=app.CallingApp.TargetManager.getSelectedTargetName();

            if slrealtime.internal.guis.Explorer.StaticUtils.isSLRTTargetConnected(targetName)

                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                runTable=tg.FileLog.list();
                app.FileLogTable.Data=runTable;
                app.FileLogTable.Enable='on';

                if isempty(app.FileLogTable.Selection)
                    app.ImportButton.Enable='off';
                    app.DeleteButton.Enable='off';
                else
                    app.ImportButton.Enable='on';
                    app.DeleteButton.Enable='on';
                end
            else


                app.FileLogTable.Data=[];

                app.FileLogTable.Enable='off';

                app.ImportButton.Enable='off';
                app.DeleteButton.Enable='off';
            end
        end

    end

end
