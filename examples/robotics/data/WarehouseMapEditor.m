classdef WarehouseMapEditor<controllib.ui.internal.dialog.AbstractDialog



    properties(Access=protected)

Widgets


MapDataMngr


OccMapView



ObjTableView


NodeNetworkView


SelectedNodesTableView
    end

    methods
        function obj=WarehouseMapEditor()


            obj=obj@controllib.ui.internal.dialog.AbstractDialog;
            obj.MapDataMngr=manager.MapDataManager;

            obj.show;

            obj.OccMapView=view.OccMapView(obj.Widgets.Map,obj.MapDataMngr);
            obj.ObjTableView=view.ObjTableView(obj.Widgets.OccMapTab.AddObjPanel.ObjTable);
            obj.NodeNetworkView=view.NodeNetworkView(obj.Widgets.Map,obj.MapDataMngr);
            obj.SelectedNodesTableView=view.SelectedNodesTableView(obj.Widgets.NodeConfigTab.NodesTable);
        end

        function delete(obj)
            delete(obj.UIFigure);
        end
    end


    methods(Access=protected)
        function connectUI(obj)


            L1=addlistener(obj.MapDataMngr,'OccMap','PostSet',@(src,evnt)obj.OccMapView.displayEmptyMap());

            L2=addlistener(obj.MapDataMngr,'OccMap','PostSet',@(src,evnt)utility.NodeNetwork.createNetwork(obj.MapDataMngr));

            L2_1=addlistener(obj.MapDataMngr,'OccMap','PostSet',@(src,event)obj.enablePanels());



            L3=addlistener(obj.MapDataMngr,'MapCleared',@(src,evnt)obj.OccMapView.clearMapView());


            L3_1=addlistener(obj.MapDataMngr,'MapCleared',@(src,evnt)obj.disablePanels());



            L4=addlistener(obj.MapDataMngr,'MapObjectsAdded',@(src,evnt)obj.OccMapView.displayMapObjects(src,evnt,obj.MapDataMngr.ActiveObjSelector));

            L5=addlistener(obj.MapDataMngr,'MapObjectsAdded',@(src,evnt)obj.ObjTableView.updateObjTable(obj.MapDataMngr.ActiveObjSelector.getTable()));



            L6=addlistener(obj.MapDataMngr,'MapObjectsRemoved',@(src,evnt)obj.OccMapView.displayMapObjects(src,evnt,obj.MapDataMngr.ActiveObjSelector));

            L7=addlistener(obj.MapDataMngr,'MapObjectsRemoved',@(src,evnt)obj.ObjTableView.updateObjTable(obj.MapDataMngr.ActiveObjSelector.getTable()));


            L8=addlistener(obj.UIFigure,'WindowMouseRelease',@(~,~)uiresume(obj.UIFigure));


            L9=addlistener(obj.MapDataMngr,'UpdateNetworkPlot',@(src,evnt)obj.NodeNetworkView.plotNetwork());


            L10=addlistener(obj.MapDataMngr,'ClearNetworkPlot',@(src,evnt)obj.NodeNetworkView.clearNetworkPlot());


            L11=addlistener(obj.MapDataMngr,'NetworkNodesSelected',@(src,evnt)obj.SelectedNodesTableView.displaySelectedNodes(src,evnt));


            L12=addlistener(obj.MapDataMngr,'NodesEdited',@(src,evnt)obj.NodeNetworkView.updateEditedNodes(src,evnt));


            L13=addlistener(obj.MapDataMngr,'MultipleNodesEdited',@(src,evnt)obj.NodeNetworkView.updateEditedNodes(src,evnt));

            L14=addlistener(obj.MapDataMngr,'MultipleNodesEdited',@(src,evnt)obj.SelectedNodesTableView.multipleNodesEdit(src,evnt));


            L15=addlistener(obj.MapDataMngr,'HighlightNodes',@(src,evnt)obj.NodeNetworkView.highlightSelectedNodes(src,evnt));


            L16=addlistener(obj.MapDataMngr,'ResetTable',@(src,evnt)obj.SelectedNodesTableView.clearTable());

            L17=addlistener(obj.MapDataMngr,'ResetTable',@(src,evnt)obj.setColSelectorCheckBoxes(evnt));



            L18=addlistener(obj.MapDataMngr,'SetColumnSelectors',@(src,evnt)obj.setColSelectorCheckBoxes(evnt));



            L20=addlistener(obj.MapDataMngr,'ObjTableEdited',@(src,evnt)obj.OccMapView.displayMapObjects(src,evnt,obj.MapDataMngr.ActiveObjSelector));


            L21=addlistener(obj.MapDataMngr,'UpdateBaseAgent',@(src,evnt)obj.OccMapView.displayBaseAgent());


            L22=addlistener(obj.MapDataMngr,'DataLoaded',@(src,event)obj.OccMapView.displayLoadedMapObjects(src,event));

            L23=addlistener(obj.MapDataMngr,'DataLoaded',@(src,event)obj.ObjTableView.updateObjTable(obj.MapDataMngr.ActiveObjSelector.getTable()));

            L24=addlistener(obj.MapDataMngr,'DataLoaded',@(src,event)obj.Widgets.OccMapTab.BaseAgentPanel.updateValues(obj.MapDataMngr.BaseAgent));


            L25=addlistener(obj.MapDataMngr,'PrintMessage',@(src,event)obj.printMessage(event));

            L26=addlistener(obj,'CloseEvent',@(src,event)obj.delete());

            registerUIListeners(obj,[L1,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15,L16,L17,L18,L20],...
            {'EmptyOccMapCreated','CreateOccMapNetwork',...
            'ClearMap','DisplayUpdatedMapObjectsOnMap',...
            'UpdateMapObjectsInTable','RemoveMapObjectsFromMap',...
            'RemoveMapObjectsFromTable','MouseRelease',...
            'UpdateNetworkPlot','ClearNetworkPlot',...
            'NetworkNodesSelected','NodesEdited',...
            'MultipleNodesEditedMap','MultipleNodesEditedTable',...
            'HighlightNodes','ClearTable','SetColSelectorCheckBoxes',...
            'ResetChecboxOnNodeSelect','ObjTableEdited'});
        end

        function buildUI(obj)


            padding=5;
            obj.UIFigure.Position=[300,300,1000,1000];
            obj.UIFigure.WindowStyle='normal';

            layout=uigridlayout(obj.UIFigure,[3,2],'Scrollable','on',...
            'Tag','Layout');
            layout.ColumnSpacing=padding;
            layout.RowSpacing=0;
            layout.Padding=padding;
            layout.RowHeight={44,44,'1x'};
            layout.ColumnWidth={420,'1x'};
            obj.Widgets.Layout=layout;


            titleGrid=uilabel(layout);
            titleGrid.HorizontalAlignment='center';
            titleGrid.Text="Grid and Network Generator";
            titleGrid.FontSize=20;
            titleGrid.Layout.Row=1;
            titleGrid.Layout.Column=1;


            ioPanel=uipanel(layout);
            ioPanel.BorderType="none";
            ioPanel.Layout.Row=2;
            ioPanel.Layout.Column=1;
            ioGrid=uigridlayout(ioPanel,[1,2]);

            loadButton=uibutton(ioGrid,'Text','Load Existing Map...');
            loadButton.ButtonPushedFcn=@(src,event)obj.MapDataMngr.loadData();

            exportButton=uibutton(ioGrid,'Text','Export as MAT file...');
            exportButton.ButtonPushedFcn=@(src,event)obj.MapDataMngr.exportData();


            tabbedPanel=uitabgroup(layout,'Tag','TabbedPanel',...
            'SelectionChangedFcn',@(src,event)obj.MapDataMngr.tabChangedCallback(src,event));
            obj.Widgets.TabbedPanel=tabbedPanel;
            tabbedPanel.Layout.Row=3;
            tabbedPanel.Layout.Column=1;


            tabs=getTabPnls(obj);
            obj.Widgets.Tabs=tabs;


            map=plotOccMapAxis(obj);
            obj.Widgets.Map=map;


            msgTextArea=messagingPanel(obj);
            obj.Widgets.MsgTextArea=msgTextArea;
        end

        function cleanupUI(obj)
            a=obj;

        end
    end









    methods(Access=private)
        function Tabs=getTabPnls(obj)

            Tabs(1)=createMapTab(obj);


            Tabs(2)=createNodesTab(obj);
        end

        function nodesTab=createNodesTab(obj)

            nodesTab=uitab(obj.Widgets.TabbedPanel,'Tag','ConfigNodesTab');
            nodesTab.Title="Configure Node Vectors";

            panelGrid=uigridlayout(nodesTab,[1,1]);
            panelGrid.RowHeight={'1x'};
            panelGrid.ColumnWidth={400};

            NodeConfigPanel=uipanel(panelGrid,...
            'Title',"Node Vectors",...
            'FontWeight','bold',...
            'BorderType','none');


            NodeGrid=uigridlayout(NodeConfigPanel,[5,1]);
            NodeGrid.RowHeight={44,44,22,'1x',22};

            selectionLabel=uilabel(NodeGrid,...
            'Text','Click individual nodes or draw a bounding box in the occupancy map to display nodes in the table',...
            'WordWrap','on');
            selectionLabel.Layout.Row=1;

            adjustLabel=uilabel(NodeGrid,...
            'Text','Adjust the vectors at each node to reflect the available directions for each movement',...
            'WordWrap','on');
            adjustLabel.Layout.Row=2;


            tbl=table([],[],[],[],[],[],'VariableNames',{'X','Y','North','East','South','West'});

            nodesTable=uitable(NodeGrid,'Data',tbl,...
            'ColumnWidth',{'1x','1x',50,50,50,50});
            nodesTable.Layout.Row=4;
            obj.Widgets.NodeConfigTab.NodesTable=nodesTable;


            colSelectorGridPanel=uipanel(NodeGrid,'BorderType','none');
            colSelectorGridPanel.Layout.Row=3;

            colSelectorValueChangedFcn=@(src,event)obj.MapDataMngr.nodesColumnEdited(src,event,obj.Widgets.NodeConfigTab.NodesTable);

            colSelectorNorth=uicheckbox(colSelectorGridPanel,"Value",0,...
            "Tag",'North',...
            'Text','','Position',[200,0,50,22],...
            'ValueChangedFcn',colSelectorValueChangedFcn);

            colSelectorEast=uicheckbox(colSelectorGridPanel,"Value",0,...
            "Tag",'East',...
            'Text','','Position',[250,0,50,22],...
            'ValueChangedFcn',colSelectorValueChangedFcn);

            colSelectorSouth=uicheckbox(colSelectorGridPanel,"Value",0,...
            "Tag",'South',...
            'Text','','Position',[300,0,50,22],...
            'ValueChangedFcn',colSelectorValueChangedFcn);

            colSelectorWest=uicheckbox(colSelectorGridPanel,"Value",0,...
            "Tag",'West',...
            'Text','','Position',[350,0,50,22],...
            'ValueChangedFcn',colSelectorValueChangedFcn);

            obj.Widgets.ColSelector.North=colSelectorNorth;
            obj.Widgets.ColSelector.East=colSelectorEast;
            obj.Widgets.ColSelector.South=colSelectorSouth;
            obj.Widgets.ColSelector.West=colSelectorWest;


            ResetNetworkButton=uibutton(NodeGrid,'Text','Reset Network',...
            'ButtonPushedFcn',@(s,e)obj.MapDataMngr.resetNetwork);
            ResetNetworkButton.Layout.Row=5;
        end

        function setColSelectorCheckBoxes(obj,event)


            if isprop(event,'SelectorValues')
                obj.Widgets.ColSelector.North.Value=event.SelectorValues.North;
                obj.Widgets.ColSelector.East.Value=event.SelectorValues.East;
                obj.Widgets.ColSelector.South.Value=event.SelectorValues.South;
                obj.Widgets.ColSelector.West.Value=event.SelectorValues.West;
            else
                obj.Widgets.ColSelector.North.Value=false;
                obj.Widgets.ColSelector.East.Value=false;
                obj.Widgets.ColSelector.South.Value=false;
                obj.Widgets.ColSelector.West.Value=false;
            end
        end

        function occMapTab=createMapTab(obj)



            occMapTab=uitab(obj.Widgets.TabbedPanel,'Tag','CreateMapTab');
            occMapTab.Title="Define Occupancy Map";


            occMapTabGrid=uigridlayout(occMapTab,[3,1]);
            occMapTabGrid.RowHeight={200,'1x',220};
            occMapTabGrid.ColumnWidth={400};
            obj.Widgets.OccMapTab.Grid=occMapTabGrid;


            obj.Widgets.OccMapTab.CreatePnl=panels.MapCreationPnl(obj.MapDataMngr,occMapTabGrid,1,1);


            obj.Widgets.OccMapTab.AddObjPanel=panels.AddObjectPnl(obj.MapDataMngr,occMapTabGrid,2,1);


            obj.Widgets.OccMapTab.BaseAgentPanel=panels.BaseAgentPnl(obj.MapDataMngr,occMapTabGrid,3,1);

        end

        function map=plotOccMapAxis(obj)

            map=uiaxes(obj.Widgets.Layout);
            map.Layout.Row=3;
            map.Layout.Column=2;
        end

        function msgTextArea=messagingPanel(obj)

            msg='Create an empty map';
            msgTextArea=uilabel('Parent',obj.Widgets.Layout,...
            'Text',msg,'WordWrap','on','FontColor','black',...
            'HorizontalAlignment','center');

            msgTextArea.Layout.Row=2;
            msgTextArea.Layout.Column=2;
        end

        function printMessage(obj,event)



            obj.Widgets.MsgTextArea.Text=event.Message;
            obj.Widgets.MsgTextArea.FontColor=event.Color;
        end

        function enablePanels(obj)

            obj.Widgets.OccMapTab.AddObjPanel.AddObjPanel.Enable='on';
            obj.Widgets.OccMapTab.BaseAgentPanel.BaseAgentPanel.Enable='on';
        end

        function disablePanels(obj)

            obj.Widgets.OccMapTab.AddObjPanel.AddObjPanel.Enable='off';
            obj.Widgets.OccMapTab.BaseAgentPanel.BaseAgentPanel.Enable='off';
        end
    end
end

