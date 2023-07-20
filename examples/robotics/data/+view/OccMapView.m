classdef OccMapView<handle



    properties

HandleMap


MapDataMngr
    end

    methods
        function obj=OccMapView(mapAxis,mapDataMngr)


            obj.HandleMap=mapAxis;
            obj.MapDataMngr=mapDataMngr;
        end
    end

    methods
        function displayEmptyMap(obj)


            if~isempty(obj.MapDataMngr.OccMap)
                hOccAxis=obj.MapDataMngr.OccMap.show('Parent',obj.HandleMap);
                mapSize=obj.MapDataMngr.OccMap.GridSize/obj.MapDataMngr.OccMap.Resolution;
                xticks(obj.HandleMap,0:5:mapSize(2));
                yticks(obj.HandleMap,0:5:mapSize(1));
                hOccAxis.ButtonDownFcn=@(ax,src)obj.MapDataMngr.mapClicked(ax,src);
                obj.MapDataMngr.setHandleOccMap(hOccAxis);

                obj.HandleMap.Layer='top';
                grid(obj.HandleMap,'on');
                hold(obj.HandleMap,'on');


                obj.displayBaseAgent();
            end
        end

        function clearMapView(obj)

            cla(obj.HandleMap);
        end

        function updateOccMapView(obj)

            if~isempty(obj.MapDataMngr.OccMap)
                obj.MapDataMngr.OccMap.show('Parent',obj.HandleMap,'FastUpdate',1);
            end
        end

        function displayMapObjects(obj,src,event,station)



            if isa(station,'manager.data.ObstacleData')
                obj.updateOccMapView()
            else


                if strcmp(event.EventName,'MapObjectsRemoved')
                    clickedGrid=event.ClickedGrid;
                    markers=findobj(obj.HandleMap.Children,'Tag',class(src.ActiveObjSelector),...
                    'XData',clickedGrid(1),'YData',clickedGrid(2));
                    delete(markers);
                elseif strcmp(event.EventName,'MapObjectsAdded')


                    if~isempty(station.Positions)
                        existingMarkers=findobj(obj.HandleMap.Children,'Tag',class(src.ActiveObjSelector),...
                        'XData',station.Positions(end,1),'YData',station.Positions(end,2));
                        if isempty(existingMarkers)


                            lgd=obj.HandleMap.Legend;
                            if isempty(lgd)
                                lgd=legend(obj.HandleMap);
                            end


                            objectType=class(station);
                            objectName=strsplit(objectType,'.');


                            if~any(strcmp(lgd.String,objectName{3}))
                                lgd.AutoUpdate='on';
                            end

                            plot(obj.HandleMap,station.Positions(end,1),station.Positions(end,2),...
                            station.PlotMarker,'MarkerSize',10,'MarkerFaceColor',station.MarkerColor,...
                            'Tag',class(src.ActiveObjSelector),...
                            'ButtonDownFcn',@(ax,src)obj.MapDataMngr.mapClicked(ax,src));



                            if~any(strcmp(lgd.String,objectName{3}))
                                lgd.String{end}=objectName{3};
                            end
                            lgd.AutoUpdate='off';
                        end
                    end
                elseif strcmp(event.EventName,'ObjTableEdited')

                    if~isempty(station.Positions)
                        existingMarkers=findobj(obj.HandleMap.Children,'Tag',class(src.ActiveObjSelector),...
                        'XData',event.OldVal(1),'YData',event.OldVal(2));
                        if~isempty(existingMarkers)
                            existingMarkers.XData=event.NewVal(1);
                            existingMarkers.YData=event.NewVal(2);
                        end
                    end
                end
            end
        end

        function displayLoadedMapObjects(obj,src,event)


            labels={};
            cs=event.LoadedData.ChargingStations;
            for i=1:size(cs.Positions,1)
                plot(obj.HandleMap,cs.Positions(i,1),cs.Positions(i,2),...
                cs.PlotMarker,'MarkerSize',10,'MarkerFaceColor',cs.MarkerColor,...
                'Tag',class(cs),...
                'ButtonDownFcn',@(ax,s)src.mapClicked(ax,s));
                if i==1
                    labels{1}="ChargingStations";
                else
                    labels{i}="";
                end
            end

            ls=event.LoadedData.LoadingStations;
            for i=1:size(ls.Positions,1)
                plot(obj.HandleMap,ls.Positions(i,1),ls.Positions(i,2),...
                ls.PlotMarker,'MarkerSize',10,'MarkerFaceColor',ls.MarkerColor,...
                'Tag',class(ls),...
                'ButtonDownFcn',@(ax,s)src.mapClicked(ax,s));
                if i==1
                    labels{end+1}="LoadingStations";
                else
                    labels{end+1}="";
                end
            end

            uls=event.LoadedData.UnloadingStations;
            for i=1:size(uls.Positions,1)
                plot(obj.HandleMap,uls.Positions(i,1),uls.Positions(i,2),...
                uls.PlotMarker,'MarkerSize',10,'MarkerFaceColor',uls.MarkerColor,...
                'Tag',class(uls),...
                'ButtonDownFcn',@(ax,s)src.mapClicked(ax,s));
                if i==1
                    labels{end+1}="UnloadingStations";
                else
                    labels{end+1}="";
                end
            end

            legend(obj.HandleMap,labels,'AutoUpdate','off')
        end

        function displayBaseAgent(obj)

            baseAgentObj=findobj(obj.HandleMap,'tag','BaseAgent');
            resObj=findobj(obj.HandleMap,'tag','Reservation');


            if~isempty(baseAgentObj)
                delete(baseAgentObj);
                delete(resObj);
            end
            if obj.MapDataMngr.getBaseAgentPreview
                baseAgentX=obj.MapDataMngr.getBaseAgentX;
                baseAgentY=obj.MapDataMngr.getBaseAgentY;
                baseAgentWidth=obj.MapDataMngr.getBaseAgentWidth;
                baseAgentHeight=obj.MapDataMngr.getBaseAgentHeight;

                bottomLeft=[baseAgentX-baseAgentWidth/2,baseAgentY-baseAgentHeight/2];

                rectangle('Parent',obj.HandleMap,'Position',[bottomLeft,baseAgentWidth,baseAgentHeight],...
                'Tag','BaseAgent','FaceColor','yellow','EdgeColor','red');


                resLength=obj.MapDataMngr.getBaseAgentReservation;
                padding=obj.MapDataMngr.getBaseAgentPadding;
                resWidth=baseAgentWidth*padding;
                resHeight=baseAgentHeight*padding;

                for i=-resLength:resLength
                    resBottomLeft=[(baseAgentX+i*resWidth)-resWidth/2,baseAgentY-resHeight/2];
                    rectangle('Parent',obj.HandleMap,'Position',[resBottomLeft,resWidth,resHeight],...
                    'Tag','Reservation','FaceColor','none','EdgeColor','magenta')
                end
                hold(obj.HandleMap,'on');
            end
        end
    end
end

