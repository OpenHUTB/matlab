classdef SelectedNodesTableView



    properties

HandleTable
    end

    methods
        function obj=SelectedNodesTableView(hTable)

            obj.HandleTable=hTable;
        end

        function displaySelectedNodes(obj,src,event)

            mapMngr=src;

            bbGrids=event.ClickedGrid;

            resolution=mapMngr.OccMap.Resolution;
            gridSize=mapMngr.OccMap.GridSize;

            topLeftXGrid=min(bbGrids(:,1))*resolution;
            topLeftYGrid=max(bbGrids(:,2))*resolution;

            bottomRightXGrid=max(bbGrids(:,1))*resolution;
            bottomRightYGrid=min(bbGrids(:,2))*resolution;

            mapData=mapMngr.Network.Map;

            selection=mapData(topLeftXGrid:bottomRightXGrid,bottomRightYGrid:topLeftYGrid);

            IJ=[selection(:).Name];

            X=(IJ(1,:)/resolution)';
            Y=(IJ(2,:)/resolution)';

            North=[selection(:).North]';
            South=[selection(:).South]';
            West=[selection(:).West]';
            East=[selection(:).East]';

            tbl=table(X,Y,North,East,South,West,'VariableNames',{'X','Y','North','East','South','West'});
            obj.HandleTable.Data=tbl;
            obj.HandleTable.ColumnEditable=[false,false,true,true,true,true];
            obj.HandleTable.CellEditCallback=@(src,event)mapMngr.nodesEdited(src,event);
            obj.HandleTable.SelectionChangedFcn=@(src,event)mapMngr.nodesSelected(src,event);


            mapMngr.NodesSelected=[];


            xyGrid=[X,Y];
            highlightEventData=manager.eventdata.HighlightedNodesEventData(xyGrid);
            notify(mapMngr,'HighlightNodes',highlightEventData);



            colSelectorStateEventData=manager.eventdata.ColSelectorEventData(all(North),all(East),all(South),all(West));
            notify(mapMngr,'SetColumnSelectors',colSelectorStateEventData);
        end

        function multipleNodesEdit(obj,src,event)


            tbl=obj.HandleTable.Data;
            mapMngr=src;
            rows=mapMngr.NodesSelected;
            if isempty(rows)
                rows=(1:size(tbl.X,1))';
            end

            direction=event.NodesEditedData.Direction;
            newVal=event.NodesEditedData.NewValue;

            dirIdx=strcmp(tbl.Properties.VariableNames,direction);
            tbl(rows,dirIdx)=table(newVal&true(size(rows)));

            obj.HandleTable.Data=tbl;
        end

        function clearTable(obj)

            tbl=table([],[],[],[],[],[],'VariableNames',{'X','Y','North','East','South','West'});
            obj.HandleTable.Data=tbl;
        end
    end
end

