classdef NodeNetworkView


    properties

HandleMap


MapDataMngr
    end

    methods
        function obj=NodeNetworkView(mapAxis,mapDataMngr)


            obj.HandleMap=mapAxis;
            obj.MapDataMngr=mapDataMngr;
        end

        function plotNetwork(obj)

            hQuiver=findobj(obj.HandleMap.Children,'type','Quiver');
            if~isempty(hQuiver)
                delete(hQuiver);
            end
            trafficNetwork=obj.MapDataMngr.Network;
            hold(obj.HandleMap,'on');
            countNorth=0;
            northNodes=zeros(size(trafficNetwork.Map,1)*size(trafficNetwork.Map,2),2);
            countEast=0;
            eastNodes=zeros(size(trafficNetwork.Map,1)*size(trafficNetwork.Map,2),2);
            countSouth=0;
            southNodes=zeros(size(trafficNetwork.Map,1)*size(trafficNetwork.Map,2),2);
            countWest=0;
            westNodes=zeros(size(trafficNetwork.Map,1)*size(trafficNetwork.Map,2),2);
            for ii=1:size(trafficNetwork.Map,1)
                for jj=1:size(trafficNetwork.Map,2)
                    free=true;





                    if free
                        if trafficNetwork.Map(ii,jj).North
                            countNorth=countNorth+1;
                            northNodes(countNorth,:)=trafficNetwork.Map(ii,jj).Name;
                        end
                        if trafficNetwork.Map(ii,jj).East
                            countEast=countEast+1;
                            eastNodes(countEast,:)=trafficNetwork.Map(ii,jj).Name;
                        end
                        if trafficNetwork.Map(ii,jj).South
                            countSouth=countSouth+1;
                            southNodes(countSouth,:)=trafficNetwork.Map(ii,jj).Name;
                        end
                        if trafficNetwork.Map(ii,jj).West
                            countWest=countWest+1;
                            westNodes(countWest,:)=trafficNetwork.Map(ii,jj).Name;
                        end
                    end
                end
            end
            northNodes=northNodes(1:countNorth,:);
            eastNodes=eastNodes(1:countEast,:);
            southNodes=southNodes(1:countSouth,:);
            westNodes=westNodes(1:countWest,:);
            quiver(obj.HandleMap,northNodes(:,1),northNodes(:,2),zeros(countNorth,1),ones(countNorth,1),0.25,'b',...
            'ButtonDownFcn',@(src,event)obj.MapDataMngr.networkClicked(src,event),'Tag','North');
            quiver(obj.HandleMap,eastNodes(:,1),eastNodes(:,2),ones(countEast,1),zeros(countEast,1),0.25,'b',...
            'ButtonDownFcn',@(src,event)obj.MapDataMngr.networkClicked(src,event),'Tag','East');
            quiver(obj.HandleMap,southNodes(:,1),southNodes(:,2),zeros(countSouth,1),-ones(countSouth,1),0.25,'b',...
            'ButtonDownFcn',@(src,event)obj.MapDataMngr.networkClicked(src,event),'Tag','South');
            quiver(obj.HandleMap,westNodes(:,1),westNodes(:,2),-ones(countWest,1),zeros(countWest,1),0.25,'b',...
            'ButtonDownFcn',@(src,event)obj.MapDataMngr.networkClicked(src,event),'Tag','West');




        end

        function updateEditedNodes(obj,~,event)


            hQuiver=findobj(obj.HandleMap.Children,'type','Quiver','Tag',event.NodesEditedData.Direction);
            hQuiverHighLight=findobj(obj.HandleMap.Children,'type','Quiver','Tag',['Highlight',event.NodesEditedData.Direction]);
            newVal=event.NodesEditedData.NewValue;
            highlights=true;
            if isempty(hQuiverHighLight)
                highlights=false;
            end

            for i=1:size(event.NodesEditedData.Grids,1)
                editIdx=find((hQuiver.XData==event.NodesEditedData.Grids(i,1)-1)&(hQuiver.YData==event.NodesEditedData.Grids(i,2)-1));
                if highlights
                    editIdxHighlight=find((hQuiverHighLight.XData==event.NodesEditedData.Grids(i,1)-1)&(hQuiverHighLight.YData==event.NodesEditedData.Grids(i,2)-1));
                end
                if~isempty(editIdx)&&newVal==false
                    hQuiver.XData(editIdx)=[];
                    hQuiver.YData(editIdx)=[];
                    hQuiver.UData(editIdx)=[];
                    hQuiver.VData(editIdx)=[];
                    if isempty(hQuiver.XData)
                        hQuiver.Visible='off';
                    end

                    if highlights
                        hQuiverHighLight.XData(editIdxHighlight)=[];
                        hQuiverHighLight.YData(editIdxHighlight)=[];
                        hQuiverHighLight.UData(editIdxHighlight)=[];
                        hQuiverHighLight.VData(editIdxHighlight)=[];
                        if isempty(hQuiverHighLight.XData)
                            hQuiverHighLight.Visible='off';
                        end
                    end
                elseif isempty(editIdx)&&newVal==true
                    hQuiver.Visible='on';
                    hQuiver.XData(end+1)=event.NodesEditedData.Grids(i,1)-1;
                    hQuiver.YData(end+1)=event.NodesEditedData.Grids(i,2)-1;
                    switch event.NodesEditedData.Direction
                    case 'North'
                        hQuiver.UData(end+1)=0;
                        hQuiver.VData(end+1)=1;
                    case 'East'
                        hQuiver.UData(end+1)=1;
                        hQuiver.VData(end+1)=0;
                    case 'South'
                        hQuiver.UData(end+1)=0;
                        hQuiver.VData(end+1)=-1;
                    case 'West'
                        hQuiver.UData(end+1)=-1;
                        hQuiver.VData(end+1)=0;
                    end

                    if highlights
                        hQuiverHighLight.Visible='on';
                        hQuiverHighLight.XData(end+1)=event.NodesEditedData.Grids(i,1)-1;
                        hQuiverHighLight.YData(end+1)=event.NodesEditedData.Grids(i,2)-1;
                        switch event.NodesEditedData.Direction
                        case 'North'
                            hQuiverHighLight.UData(end+1)=0;
                            hQuiverHighLight.VData(end+1)=1;
                        case 'East'
                            hQuiverHighLight.UData(end+1)=1;
                            hQuiverHighLight.VData(end+1)=0;
                        case 'South'
                            hQuiverHighLight.UData(end+1)=0;
                            hQuiverHighLight.VData(end+1)=-1;
                        case 'West'
                            hQuiverHighLight.UData(end+1)=-1;
                            hQuiverHighLight.VData(end+1)=0;
                        end
                    end
                end
            end
        end

        function highlightSelectedNodes(obj,src,event)


            hQuiver=findobj(obj.HandleMap.Children,'-regexp','tag','Highlight.');
            if~isempty(hQuiver)
                delete(hQuiver);
            end

            if~isempty(event.GridData)
                gridData=event.GridData;
                nGrids=size(gridData);

                trafficNetwork=obj.MapDataMngr.Network;
                hold(obj.HandleMap,'on');
                countNorth=0;
                northNodes=zeros(nGrids);
                countEast=0;
                eastNodes=zeros(nGrids);
                countSouth=0;
                southNodes=zeros(nGrids);
                countWest=0;
                westNodes=zeros(nGrids);
                for i=1:nGrids(1)
                    free=true;
                    if free
                        if trafficNetwork.Map(gridData(i,1)+1,gridData(i,2)+1).North
                            countNorth=countNorth+1;
                            northNodes(countNorth,:)=trafficNetwork.Map(gridData(i,1)+1,gridData(i,2)+1).Name;
                        end
                        if trafficNetwork.Map(gridData(i,1)+1,gridData(i,2)+1).East
                            countEast=countEast+1;
                            eastNodes(countEast,:)=trafficNetwork.Map(gridData(i,1)+1,gridData(i,2)+1).Name;
                        end
                        if trafficNetwork.Map(gridData(i,1)+1,gridData(i,2)+1).South
                            countSouth=countSouth+1;
                            southNodes(countSouth,:)=trafficNetwork.Map(gridData(i,1)+1,gridData(i,2)+1).Name;
                        end
                        if trafficNetwork.Map(gridData(i,1)+1,gridData(i,2)+1).West
                            countWest=countWest+1;
                            westNodes(countWest,:)=trafficNetwork.Map(gridData(i,1)+1,gridData(i,2)+1).Name;
                        end
                    end
                end
                northNodes=northNodes(1:countNorth,:);
                eastNodes=eastNodes(1:countEast,:);
                southNodes=southNodes(1:countSouth,:);
                westNodes=westNodes(1:countWest,:);
                quiver(obj.HandleMap,northNodes(:,1),northNodes(:,2),zeros(countNorth,1),ones(countNorth,1),0.5,'g',...
                'ButtonDownFcn',@(src,event)obj.MapDataMngr.networkClicked(src,event),'Tag','HighlightNorth');
                quiver(obj.HandleMap,eastNodes(:,1),eastNodes(:,2),ones(countEast,1),zeros(countEast,1),0.5,'g',...
                'ButtonDownFcn',@(src,event)obj.MapDataMngr.networkClicked(src,event),'Tag','HighlightEast');
                quiver(obj.HandleMap,southNodes(:,1),southNodes(:,2),zeros(countSouth,1),-ones(countSouth,1),0.5,'g',...
                'ButtonDownFcn',@(src,event)obj.MapDataMngr.networkClicked(src,event),'Tag','HighlightSouth');
                quiver(obj.HandleMap,westNodes(:,1),westNodes(:,2),-ones(countWest,1),zeros(countWest,1),0.5,'g',...
                'ButtonDownFcn',@(src,event)obj.MapDataMngr.networkClicked(src,event),'Tag','HighlightWest');
            end
        end

        function clearNetworkPlot(obj)

            hQuiver=findobj(obj.HandleMap.Children,'type','Quiver');
            if~isempty(hQuiver)
                delete(hQuiver);
            end
        end


    end
end

