classdef MapDataManager<handle



    properties(SetObservable)

OccMap
    end

    properties



ActiveObjSelector




NetworkEdits




Network


NodesSelected


BaseAgent
    end

    properties(Access=private)

LoadingStations
UnloadingStations
ChargingStations


Obstacles


HandleOccMap
    end


    properties(Access=private)

MapWidth
MapHeight
MapGridSpacing
MapUnits
    end

    methods
        function obj=MapDataManager()


            obj.LoadingStations=manager.data.LoadingStations;
            obj.UnloadingStations=manager.data.UnloadingStations;
            obj.ChargingStations=manager.data.ChargingStations;
            obj.Obstacles=manager.data.ObstacleData;
            obj.ActiveObjSelector=obj.LoadingStations;

            obj.BaseAgent.Width=2;
            obj.BaseAgent.Height=1;
            obj.BaseAgent.X=10;
            obj.BaseAgent.Y=5;
            obj.BaseAgent.Padding=1.5;
            obj.BaseAgent.Reservation=2;
            obj.BaseAgent.Preview=true;

            obj.NetworkEdits.Map=[];
            obj.NetworkEdits.EditedGrids=[];

            obj.NodesSelected=[];

            obj.MapWidth=60;
            obj.MapHeight=60;
            obj.MapGridSpacing=1;
            obj.MapUnits='meters';

        end

        function createMap(obj)



            obj.OccMap=binaryOccupancyMap(obj.MapWidth,obj.MapHeight,1/obj.MapGridSpacing);
            msg='Add objects to map and set base agent properties';
            eventData=manager.eventdata.PrintMessageEventData(msg,'black');
            notify(obj,'PrintMessage',eventData);
        end

        function clearMap(obj)

            obj.OccMap=[];
            obj.LoadingStations.clearData;
            obj.UnloadingStations.clearData;
            obj.ChargingStations.clearData;
            obj.Obstacles.clearData;

            obj.NetworkEdits.Map=[];
            obj.NetworkEdits.EditedGrids=[];

            obj.NodesSelected=[];


            notify(obj,'MapObjectsAdded');

            notify(obj,'MapCleared');
        end

        function tabChangedCallback(obj,src,event)




            currentTabTag=src.SelectedTab.Tag;
            if isempty(obj.OccMap)
                src.SelectedTab=event.OldValue;
                msg='Create a map before configuring the nodes';
                eventData=manager.eventdata.PrintMessageEventData(msg,'red');
                notify(obj,'PrintMessage',eventData);
            else




                if strcmp(currentTabTag,'ConfigNodesTab')
                    obj.HandleOccMap.ButtonDownFcn=@(ax,src)obj.networkClicked(ax,src);
                    notify(obj,'UpdateNetworkPlot');
                elseif strcmp(currentTabTag,'CreateMapTab')
                    obj.HandleOccMap.ButtonDownFcn=@(ax,src)obj.mapClicked(ax,src);
                    notify(obj,'ClearNetworkPlot');
                end
            end
        end
    end

    methods
        function objSelectorChanged(obj,btn)


            switch(btn.SelectedObject.Text)
            case 'Loading Station'
                obj.ActiveObjSelector=obj.LoadingStations;
                objectName='Loading Station';
            case 'Unloading Station'
                obj.ActiveObjSelector=obj.UnloadingStations;
                objectName='Unloading Station';
            case 'Charging Station'
                obj.ActiveObjSelector=obj.ChargingStations;
                objectName='Charging Station';
            case 'Obstacle'
                obj.ActiveObjSelector=obj.Obstacles;
                objectName='Obstacle';
            end

            notify(obj,'MapObjectsAdded');

            msg=['Left click the map to add ',objectName,' or Right click a ',objectName,' to remove it'];
            eventData=manager.eventdata.PrintMessageEventData(msg,'black');
            notify(obj,'PrintMessage',eventData);
        end
    end

    methods
        function mapClicked(obj,ax,src)






            if isa(obj.ActiveObjSelector,'manager.data.ObstacleData')
                disableDefaultInteractivity(ax.Parent)
                posStart=ax.Parent.CurrentPoint;
                uiwait(ax.Parent.Parent.Parent);
                posEnd=ax.Parent.CurrentPoint;
                clickedGrid=[ceil(posStart(1,1:2));ceil(posEnd(1,1:2))];
                enableDefaultInteractivity(ax.Parent);
            else
                clickedGrid=ceil(src.IntersectionPoint(1:2));
            end


            if src.Button==1


                [status,message]=obj.ActiveObjSelector.AddObject(clickedGrid,obj.OccMap);
                if status


                    if isa(obj.ActiveObjSelector,'manager.data.ObstacleData')
                        utility.OccMapData.UpdateOccMap(obj.ActiveObjSelector,obj,obj.ActiveObjSelector.getNumObj);
                        utility.NodeNetwork.createNetwork(obj);
                    end


                    notify(obj,'MapObjectsAdded');
                end

            elseif src.Button==3

                [status,removedData,message]=obj.ActiveObjSelector.RemoveObject(clickedGrid);

                if status

                    if isa(obj.ActiveObjSelector,'manager.data.ObstacleData')
                        utility.OccMapData.UpdateOccMap(obj.ActiveObjSelector,obj,removedData);
                        utility.NodeNetwork.createNetwork(obj);
                    end


                    eventData=manager.eventdata.MapObjectsRemovedEventData(clickedGrid);
                    notify(obj,'MapObjectsRemoved',eventData);
                end
            end


            eventData=manager.eventdata.PrintMessageEventData(message.Message,message.Color);
            notify(obj,'PrintMessage',eventData);
        end

        function networkClicked(obj,ax,~)





            disableDefaultInteractivity(ax.Parent)
            posStart=ax.Parent.CurrentPoint;
            uiwait(ax.Parent.Parent.Parent);
            posEnd=ax.Parent.CurrentPoint;
            clickedGrid=[ceil(posStart(1,1:2));ceil(posEnd(1,1:2))];
            enableDefaultInteractivity(ax.Parent);


            eventData=manager.eventdata.NodesSelectedEventData(clickedGrid);
            notify(obj,'NetworkNodesSelected',eventData);
        end

        function objTableEdited(obj,src,event)


            [status,message]=obj.ActiveObjSelector.EditObject(event.Indices(1),src.Data(event.Indices(1),:).Variables);

            if status

                newVal=src.Data(event.Indices(1),:).Variables;
                oldVal=newVal;



                oldVal(event.Indices(2))=event.PreviousData;



                if isa(obj.ActiveObjSelector,'manager.data.ObstacleData')
                    utility.OccMapData.EditOccMap(obj,oldVal,newVal);
                    utility.NodeNetwork.createNetwork(obj);
                end


                eventData=manager.eventdata.ObjTableEditedEventData(newVal,oldVal);
                notify(obj,'ObjTableEdited',eventData);
            end

            eventData=manager.eventdata.PrintMessageEventData(message.Message,message.Color);
            notify(obj,'PrintMessage',eventData);

        end

        function nodesEdited(obj,src,event)


            newVal=logical(event.NewData);
            rows=event.Indices(1);
            directionIdx=event.Indices(2);
            xyGrid=[src.Data.X(rows),src.Data.Y(rows)];
            colNames=src.Data.Properties.VariableNames;
            nodesEditedEventData=obj.updateAndNotifyEditedNodes(xyGrid,colNames{directionIdx},newVal);

            highlightEventData=manager.eventdata.HighlightedNodesEventData(xyGrid);
            notify(obj,'HighlightNodes',highlightEventData);
            notify(obj,'NodesEdited',nodesEditedEventData);

            msg=['Node X: ',num2str(xyGrid(1)),' Y: ',num2str(xyGrid(2)),' updated'];
            eventData=manager.eventdata.PrintMessageEventData(msg,'black');
            notify(obj,'PrintMessage',eventData);
        end

        function nodesSelected(obj,src,event)


            if~isempty(event.Selection)
                selRows=unique(event.Selection(:,1));
                obj.NodesSelected=selRows;

                gridData=[src.Data.X(selRows),src.Data.Y(selRows)];
                eventData=manager.eventdata.HighlightedNodesEventData(gridData);
            else
                obj.NodesSelected=[];
                eventData=manager.eventdata.HighlightedNodesEventData([]);
            end
            notify(obj,'HighlightNodes',eventData);

            msg=[num2str(length(obj.NodesSelected)),' node(s) selected'];
            eventData=manager.eventdata.PrintMessageEventData(msg,'black');
            notify(obj,'PrintMessage',eventData);
        end

        function nodesColumnEdited(obj,src,event,table)


            newVal=event.Value;
            direction=src.Tag;

            if isempty(obj.NodesSelected)
                rows=1:size(table.Data,1);
            else
                rows=obj.NodesSelected;
            end

            xyGrid=[table.Data.X(rows),table.Data.Y(rows)];


            eventData=obj.updateAndNotifyEditedNodes(xyGrid,direction,newVal);


            notify(obj,'MultipleNodesEdited',eventData);

            msg=[num2str(length(rows)),' node(s) updated'];
            eventData=manager.eventdata.PrintMessageEventData(msg,'black');
            notify(obj,'PrintMessage',eventData);
        end

        function eventData=updateAndNotifyEditedNodes(obj,xyGrid,direction,newVal)



            for i=1:size(xyGrid,1)
                obj.Network.Map(xyGrid(i,1)+1,xyGrid(i,2)+1)=setfield(obj.Network.Map(xyGrid(i,1)+1,xyGrid(i,2)+1),direction,newVal);
                obj.NetworkEdits.Map(xyGrid(i,1)+1,xyGrid(i,2)+1)=obj.Network.Map(xyGrid(i,1)+1,xyGrid(i,2)+1);
                obj.NetworkEdits.EditedGrids(xyGrid(i,1)+1,xyGrid(i,2)+1)=1;
            end

            data=struct('Grids',[xyGrid(:,1)+1,xyGrid(:,2)+1],'Direction',direction,'NewValue',newVal);
            eventData=manager.eventdata.NodesEditedEventData(data);
        end

        function updateBaseAgent(obj)

            notify(obj,'UpdateBaseAgent');
        end

        function resetNetwork(obj,~,~)

            obj.NodesSelected=[];
            obj.NetworkEdits.Map=[];
            obj.NetworkEdits.EditedGrids=[];
            utility.NodeNetwork.createNetwork(obj);
            notify(obj,'UpdateNetworkPlot');
            notify(obj,'ResetTable');

            msg='Node network reset to default';
            eventData=manager.eventdata.PrintMessageEventData(msg,'black');
            notify(obj,'PrintMessage',eventData);
        end

        function exportData(obj)

            logicalMap=occupancyMatrix(obj.OccMap);
            chargingStations=obj.ChargingStations.Positions;
            loadingStations=obj.LoadingStations.Positions;
            unloadingStations=obj.UnloadingStations.Positions;
            obstacles=obj.Obstacles;
            networkChanges=obj.NetworkEdits;
            baseAgent=obj.BaseAgent;
            network=obj.Network;
            uisave(["unloadingStations","loadingStations","chargingStations","logicalMap","baseAgent","network","networkChanges","obstacles"],"customWarehouseMap.mat");

            msg='Data exported successfully!';
            eventData=manager.eventdata.PrintMessageEventData(msg,'black');
            notify(obj,'PrintMessage',eventData);
        end

        function loadData(obj)

            uiopen('load');
            try
                if exist('baseAgent','var')
                    obj.BaseAgent=baseAgent;
                end

                if exist('networkChanges','var')
                    obj.NetworkEdits=networkChanges;
                end

                if exist('network','var')
                    obj.Network=network;
                end

                if exist('obstacles','var')
                    obj.Obstacles=obstacles;
                end

                if exist('logicalMap','var')
                    obj.OccMap=binaryOccupancyMap(logicalMap);
                end

                if exist('chargingStations','var')
                    obj.ChargingStations.loadObjects(chargingStations);
                end

                if exist('loadingStations','var')
                    obj.LoadingStations.loadObjects(loadingStations);
                end

                if exist('unloadingStations','var')
                    obj.UnloadingStations.loadObjects(unloadingStations);
                end

                switch(class(obj.ActiveObjSelector))
                case 'manager.data.LoadingStations'
                    obj.ActiveObjSelector=obj.LoadingStations;
                case 'manager.data.UnloadingStations'
                    obj.ActiveObjSelector=obj.UnloadingStations;
                case 'manager.data.ChargingStations'
                    obj.ActiveObjSelector=obj.ChargingStations;
                case 'manager.data.ObstacleData'
                    obj.ActiveObjSelector=obj.Obstacles;
                end

                loadedData.ChargingStations=obj.ChargingStations;
                loadedData.LoadingStations=obj.LoadingStations;
                loadedData.UnloadingStations=obj.UnloadingStations;

                eventData=manager.eventdata.DataLoadedEventData(loadedData);
                notify(obj,'DataLoaded',eventData);

                msg='Data loaded successfully!';
                color='black';
            catch
                msg='Data load unsuccessful';
                color='red';
            end
            eventData=manager.eventdata.PrintMessageEventData(msg,color);
            notify(obj,'PrintMessage',eventData);
        end
    end

    methods

        function setBaseAgentWidth(obj,width)
            obj.BaseAgent.Width=width;
            obj.updateBaseAgent();
            utility.NodeNetwork.createNetwork(obj);
        end

        function setBaseAgentHeight(obj,height)
            obj.BaseAgent.Height=height;
            obj.updateBaseAgent();
            utility.NodeNetwork.createNetwork(obj);
        end

        function w=getBaseAgentWidth(obj)
            w=obj.BaseAgent.Width;
        end

        function h=getBaseAgentHeight(obj)
            h=obj.BaseAgent.Height;
        end

        function setBaseAgentX(obj,x)
            obj.BaseAgent.X=x;
            obj.updateBaseAgent();
        end

        function setBaseAgentY(obj,y)
            obj.BaseAgent.Y=y;
            obj.updateBaseAgent();
        end

        function x=getBaseAgentX(obj)
            x=obj.BaseAgent.X;
        end

        function y=getBaseAgentY(obj)
            y=obj.BaseAgent.Y;
        end

        function setBaseAgentReservation(obj,res)
            obj.BaseAgent.Reservation=res;
            obj.updateBaseAgent();
        end

        function res=getBaseAgentReservation(obj)
            res=obj.BaseAgent.Reservation;
        end

        function setBaseAgentPadding(obj,padding)
            obj.BaseAgent.Padding=padding;
            obj.updateBaseAgent();
            utility.NodeNetwork.createNetwork(obj);
        end

        function padding=getBaseAgentPadding(obj)
            padding=obj.BaseAgent.Padding;
        end

        function setBaseAgentPreview(obj,event)
            if isempty(event)
                preview=true;
            else
                switch(event.NewValue.Tag)
                case 'On'
                    preview=true;
                case 'Off'
                    preview=false;
                end
            end
            obj.BaseAgent.Preview=preview;
            obj.updateBaseAgent();
        end

        function preview=getBaseAgentPreview(obj)
            preview=obj.BaseAgent.Preview;
        end

        function setHandleOccMap(obj,h)
            obj.HandleOccMap=h;
        end
    end


    methods
        function obj=setWidth(obj,width)
            obj.MapWidth=width;
        end

        function obj=setHeight(obj,height)
            obj.MapHeight=height;
        end

        function obj=setGridSpacing(obj,gridSpacing)
            obj.MapGridSpacing=gridSpacing;
        end

        function obj=setUnits(obj,units)
            obj.MapUnits=units;
        end
    end

    events
MapCleared
MapObjectsAdded
MapObjectsRemoved
ObjTableEdited

UpdateNetworkPlot
ClearNetworkPlot

NetworkNodesSelected
NodesEdited
MultipleNodesEdited

HighlightNodes
ResetTable

UpdateBaseAgent

DataLoaded

PrintMessage

SetColumnSelectors
    end
end

