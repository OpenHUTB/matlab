classdef SystemLogViewerExported<matlab.apps.AppBase





    properties(Access=public)
        SystemLogViewerUIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        LeftPanel matlab.ui.container.Panel
        MessageEditFieldLabel matlab.ui.control.Label
        MessageEditField matlab.ui.control.EditField
        SeverityDropDownLabel matlab.ui.control.Label
        SeverityDropDown matlab.ui.control.DropDown
        RightPanel matlab.ui.container.Panel
        RightGridLayout matlab.ui.container.GridLayout
        UITable matlab.ui.control.Table
    end


    properties(Access=private)
        onePanelWidth=576;
    end


    properties(Access=private)
TargetName


    end

    properties(Access=public)
App
    end

    methods(Access=private)

        function systemLogUpdated(app,property,event,targetName)
            assert(strcmp(property.Name,'SystemLog'));

            target=app.App.TargetManager.getTargetFromMap(targetName);
            target.systemLogViewer.systemLog.append(event.AffectedObject.SystemLog.Message);
            app.App.TargetManager.targetMap(targetName)=target;

            if strcmp(app.App.TargetManager.getSelectedTargetName(),targetName)


                app.UITable.Data=target.systemLogViewer.systemLog.messages;
            end
        end
    end

    methods(Access=public)

        function tgConnected(app,targetName)
            app.TargetName=targetName;
            target=app.App.TargetManager.getTargetFromMap(targetName);


            if isempty(target.systemLogViewer)
                systemLogViewer=struct(...
                'systemLog',[],...
                'systemLogListener',[]...
                );

                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                systemLogViewer.systemLog=slrealtime.SystemLog(tg);
                systemLogViewer.systemLogListener=listener(tg.get('tc'),'SystemLog','PostSet',@(src,evnt)app.systemLogUpdated(src,evnt,targetName));

                target.systemLogViewer=systemLogViewer;
                app.App.TargetManager.targetMap(targetName)=target;
            end

            app.MessageEditField.Value=target.systemLogViewer.systemLog.messageFilter;
            if(target.systemLogViewer.systemLog.severityFilter=="")
                app.SeverityDropDown.Value='all';
            else
                app.SeverityDropDown.Value=target.systemLogViewer.systemLog.severityFilter;
            end
            app.UITable.Data=target.systemLogViewer.systemLog.messages;

            app.UITable.Enable='on';
            app.MessageEditField.Enable='on';
            app.SeverityDropDown.Enable='on';
        end

        function clearSystemLogViewerCachedProperties(app,targetName)








            target=app.App.TargetManager.getTargetFromMap(targetName);
            if~isempty(target.systemLogViewer)

                delete(target.systemLogViewer.systemLogListener);
                target.systemLogViewer.systemLogListener=[];
                target.systemLogViewer.systemLog=[];
                target.systemLogViewer=[];

                app.App.TargetManager.targetMap(targetName)=target;
            end
        end

        function tgDisconnected(app)
            app.MessageEditField.Value='';
            app.SeverityDropDown.Value='all';
            app.UITable.Data=[];

            app.UITable.Enable='off';
            app.MessageEditField.Enable='off';
            app.SeverityDropDown.Enable='off';
        end
    end



    methods(Access=private)


        function startupFcn(app)
        end


        function MessageEditFieldValueChanged(app,event)
            value=app.MessageEditField.Value;
            target=app.App.TargetManager.getTargetFromMap(app.TargetName);
            target.systemLogViewer.systemLog.messageFilter=value;
            app.UITable.Data=target.systemLogViewer.systemLog.messages;
            app.App.TargetManager.targetMap(app.TargetName)=target;
        end


        function SeverityDropDownValueChanged(app,event)
            value=app.SeverityDropDown.Value;
            target=app.App.TargetManager.getTargetFromMap(app.TargetName);
            target.systemLogViewer.systemLog.severityFilter=value;
            app.UITable.Data=target.systemLogViewer.systemLog.messages;
            app.App.TargetManager.targetMap(app.TargetName)=target;
        end


        function updateAppLayout(app,event)
            currentFigureWidth=app.SystemLogViewerUIFigure.Position(3);
            if(currentFigureWidth<=app.onePanelWidth)

                app.GridLayout.RowHeight={453,453};
                app.GridLayout.ColumnWidth={'1x'};
                app.RightPanel.Layout.Row=2;
                app.RightPanel.Layout.Column=1;
            else

                app.GridLayout.RowHeight={'1x'};
                app.GridLayout.ColumnWidth={181,'1x'};
                app.RightPanel.Layout.Row=1;
                app.RightPanel.Layout.Column=2;
            end
        end
    end


    methods(Access=private)


        function createComponents(app)









            app.GridLayout=uigridlayout(app.SystemLogViewerUIFigure);
            app.GridLayout.ColumnWidth={181,'1x'};
            app.GridLayout.RowHeight={'1x'};
            app.GridLayout.ColumnSpacing=0;
            app.GridLayout.RowSpacing=0;
            app.GridLayout.Padding=[0,0,0,0];
            app.GridLayout.Scrollable='on';


            app.LeftPanel=uipanel(app.GridLayout);
            app.LeftPanel.Title=getString(message(app.App.Messages.systemLogViewerPanelTitleMsgId));
            app.LeftPanel.Layout.Row=1;
            app.LeftPanel.Layout.Column=1;


            app.MessageEditFieldLabel=uilabel(app.LeftPanel);
            app.MessageEditFieldLabel.HorizontalAlignment='right';
            app.MessageEditFieldLabel.Position=[7,401,54,22];
            app.MessageEditFieldLabel.Text={getString(message(app.App.Messages.systemLogViewerMessageMsgId));''};


            app.MessageEditField=uieditfield(app.LeftPanel,'text');
            app.MessageEditField.ValueChangedFcn=createCallbackFcn(app,@MessageEditFieldValueChanged,true);
            app.MessageEditField.Position=[70,401,106,22];


            app.SeverityDropDownLabel=uilabel(app.LeftPanel);
            app.SeverityDropDownLabel.HorizontalAlignment='right';
            app.SeverityDropDownLabel.Position=[7,368,54,22];
            app.SeverityDropDownLabel.Text=getString(message(app.App.Messages.systemLogViewerSeverityMsgId));


            app.SeverityDropDown=uidropdown(app.LeftPanel);
            app.SeverityDropDown.Items={'all','trace','debug','info','warning','error','fatal'};
            app.SeverityDropDown.ValueChangedFcn=createCallbackFcn(app,@SeverityDropDownValueChanged,true);
            app.SeverityDropDown.Position=[70,368,106,22];
            app.SeverityDropDown.Value='all';


            app.RightPanel=uipanel(app.GridLayout);
            app.RightPanel.Layout.Row=1;
            app.RightPanel.Layout.Column=2;



            app.RightGridLayout=uigridlayout(app.RightPanel);
            app.RightGridLayout.ColumnWidth={'1x'};
            app.RightGridLayout.RowHeight={'1x'};









            app.UITable=uitable(app.RightGridLayout);
            app.UITable.Layout.Row=1;
            app.UITable.Layout.Column=1;
            app.UITable.ColumnName={getString(message(app.App.Messages.systemLogViewerUITableTimestampColumnNameMsgId));...
            getString(message(app.App.Messages.systemLogViewerMessageMsgId));...
            getString(message(app.App.Messages.systemLogViewerSeverityMsgId));...
            getString(message(app.App.Messages.systemLogViewerUITableCategoryColumnNameMsgId))};
            app.UITable.ColumnWidth={130,'auto',55,75};
            app.UITable.RowName={};
            app.UITable.ColumnSortable=true;
            app.UITable.RowStriping='off';



            app.SystemLogViewerUIFigure.Visible='on';
        end
    end


    methods(Access=public)


        function app=SystemLogViewerExported(hApp,huifigure)
            app.App=hApp;

            app.SystemLogViewerUIFigure=huifigure;
            app.SystemLogViewerUIFigure.Visible='off';


            app.createComponents()







            if nargout==0
                clear app
            end
        end


        function delete(app)
            app.App=[];
            app.TargetName='';
        end
    end
end
