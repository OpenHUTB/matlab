classdef(Sealed,Hidden)LayoutManager<handle












    properties(Hidden)


        HorizontalGraph(1,:);


        VerticalGraph(1,:);
        SystemName(1,:)char;


        BlkPaths(1,:)cell;


        Annotations(1,:)double;


        ConnectedComponents;


        ConnectedRegions(1,:)Simulink.internal.variantlayout.ConnectedRegion;


        VerticalPartitions(1,:)Simulink.internal.variantlayout.Partition;


        HorizontalPartitions(1,:)Simulink.internal.variantlayout.Partition;
    end

    methods

        function obj=LayoutManager(sys)
            obj.SystemName=sys;




            allBlocks=find_system(obj.SystemName,'SearchDepth','1',...
            'LookUnderMasks','on','MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on');



            if numel(allBlocks)>1
                obj.BlkPaths=allBlocks(2:end);
            else
                obj.BlkPaths={};
            end


            if isempty(obj.BlkPaths)


                return;
            end

            obj.Annotations=find_system(sys,'SearchDepth','1',...
            'MatchFilter',@Simulink.match.allVariants,...
            'FindAll','on','Type','annotation');


            obj.HorizontalGraph=Simulink.internal.variantlayout.DirGraphHorizontal(obj.SystemName,obj.BlkPaths,obj.Annotations);
            obj.VerticalGraph=Simulink.internal.variantlayout.DirGraphVertical(obj.SystemName,obj.BlkPaths,obj.Annotations);


            obj.findConnectedComponents;


            obj.sortConnectedComponents;


            obj.findConnectedRegions;


            obj.findPartitions;
        end


        function layoutModel(obj)

            if isempty(obj.BlkPaths)


                return;
            end

            hHorzGraphId=1;
            hVertGraphId=1;

            for connId=1:numel(obj.ConnectedRegions)
                if obj.ConnectedRegions(connId).HierarchyIdx==...
                    Simulink.internal.variantlayout.Hierarchy.HORIZONTAL
                    layoutModelLocal(connId,'h');
                else
                    layoutModelLocal(connId,'v');
                end

                obj.ConnectedRegions(connId).updateSpan;
            end



            obj.placeConnectedRegions;



            obj.setModeltoFitView;


            function layoutModelLocal(connId,type)

                switch lower(type(1))
                case 'h'
                    isHorizontallyPlaced=1;
                    obj.HorizontalGraph(hHorzGraphId)=Simulink.internal.variantlayout.DirGraphHorizontal(obj.SystemName,...
                    obj.ConnectedRegions(connId).BlkPaths,obj.ConnectedRegions(connId).Annotations);
                    obj.HorizontalGraph(hHorzGraphId).autoLayoutWithPlace(obj.ConnectedRegions(connId).HasRight,obj.ConnectedRegions(connId).HasLeft);
                    hHorzGraphId=hHorzGraphId+1;
                    if obj.ConnectedRegions(connId).HasDown||obj.ConnectedRegions(connId).HasTop
                        obj.VerticalGraph(hVertGraphId)=Simulink.internal.variantlayout.DirGraphVertical(obj.SystemName,...
                        obj.ConnectedRegions(connId).BlkPaths,obj.ConnectedRegions(connId).Annotations);
                        obj.VerticalGraph(hVertGraphId).autoLayoutWithoutPlace(isHorizontallyPlaced,obj.ConnectedRegions(connId).HasDown,obj.ConnectedRegions(connId).HasTop);
                        hVertGraphId=hVertGraphId+1;
                    end
                case 'v'
                    isHorizontallyPlaced=0;
                    obj.VerticalGraph(hVertGraphId)=Simulink.internal.variantlayout.DirGraphVertical(obj.SystemName,...
                    obj.ConnectedRegions(connId).BlkPaths,obj.ConnectedRegions(connId).Annotations);
                    obj.VerticalGraph(hVertGraphId).autoLayoutWithPlace(obj.ConnectedRegions(connId).HasDown,obj.ConnectedRegions(connId).HasTop);
                    hVertGraphId=hVertGraphId+1;
                    if obj.ConnectedRegions(connId).HasLeft||obj.ConnectedRegions(connId).HasRight
                        obj.HorizontalGraph(hHorzGraphId)=Simulink.internal.variantlayout.DirGraphHorizontal(obj.SystemName,...
                        obj.ConnectedRegions(connId).BlkPaths,obj.ConnectedRegions(connId).Annotations);
                        obj.HorizontalGraph(hHorzGraphId).autoLayoutWithoutPlace(isHorizontallyPlaced,obj.ConnectedRegions(connId).HasRight,obj.ConnectedRegions(connId).HasLeft);
                        hHorzGraphId=hHorzGraphId+1;
                    end
                otherwise
                    error('Invalid input. Please enter: h, v or b');
                end
            end
        end


        function placeLayers(obj)
            hHorzGraphId=1;
            hVertGraphId=1;

            for connId=1:numel(obj.ConnectedRegions)
                if obj.ConnectedRegions(connId).HierarchyIdx==...
                    Simulink.internal.variantlayout.Hierarchy.HORIZONTAL
                    placeLayerLocal(connId,'h');
                else
                    placeLayerLocal(connId,'v');
                end

                obj.ConnectedRegions(connId).updateSpan;
            end



            obj.placeConnectedRegions;

            obj.placePartitions(100);


            function placeLayerLocal(connId,type)

                switch lower(type(1))
                case 'h'
                    obj.HorizontalGraph(hHorzGraphId)=Simulink.internal.variantlayout.DirGraphHorizontal(obj.SystemName,...
                    obj.ConnectedRegions(connId).BlkPaths,obj.ConnectedRegions(connId).Annotations);
                    obj.HorizontalGraph(hHorzGraphId).autoLayoutPlace();
                    hHorzGraphId=hHorzGraphId+1;
                case 'v'
                    obj.VerticalGraph(hVertGraphId)=Simulink.internal.variantlayout.DirGraphVertical(obj.SystemName,...
                    obj.ConnectedRegions(connId).BlkPaths,obj.ConnectedRegions(connId).Annotations);
                    obj.VerticalGraph(hVertGraphId).autoLayoutPlace();
                    hVertGraphId=hVertGraphId+1;
                otherwise
                    error('Invalid input. Please enter: h, v or b');
                end
            end
        end



        function findConnectedComponents(obj)

            adjacencylistPorts=obj.HorizontalGraph.AdjacencyListPorts;


            adjacencylistNodes=zeros(size(adjacencylistPorts));
            for listId=1:size(adjacencylistPorts,1)

                srcBlkPath=get(adjacencylistPorts(listId,1),'Parent');
                srcBlkHandle=get_param(srcBlkPath,'Handle');

                dstBlkPath=get(adjacencylistPorts(listId,2),'Parent');
                dstBlkHandle=get_param(dstBlkPath,'Handle');

                adjacencylistNodes(listId,1)=srcBlkHandle;
                adjacencylistNodes(listId,2)=dstBlkHandle;
            end


            adjacencylistNodes=unique(sort(adjacencylistNodes,2),'rows');


            srcBlkPaths=getfullname(adjacencylistNodes(:,1));
            dstBlkPaths=getfullname(adjacencylistNodes(:,2));
            gMatlabGraph=graph(srcBlkPaths,dstBlkPaths);


            bins=conncomp(gMatlabGraph,'OutputForm','cell');
            obj.ConnectedComponents=struct;
            connId=1;

            for binId=1:numel(bins)
                obj.ConnectedComponents(connId).BlkPaths=bins{binId};
                obj.ConnectedComponents(connId).BlkHandles=...
                Simulink.variant.utils.i_cell2mat(get_param(bins{binId},'Handle'));
                obj.ConnectedComponents(connId).Span=...
                Simulink.internal.variantlayout.ConnectedRegion.findBoundingArea(...
                obj.ConnectedComponents(connId).BlkHandles);
                connId=connId+1;
            end








            unConnectedNodeHandles=setdiff([obj.HorizontalGraph.Nodes(:).NodeHandle],...
            adjacencylistNodes(:));
            for nodeId=1:numel(unConnectedNodeHandles)
                obj.ConnectedComponents(connId).BlkPaths=getfullname(unConnectedNodeHandles(nodeId));
                obj.ConnectedComponents(connId).BlkHandles=unConnectedNodeHandles(nodeId);
                obj.ConnectedComponents(connId).Span=...
                Simulink.internal.variantlayout.ConnectedRegion.findBoundingArea(...
                obj.ConnectedComponents(connId).BlkHandles);
                connId=connId+1;
            end


            for areaId=1:numel(obj.HorizontalGraph.Areas)
                obj.ConnectedComponents(connId).BlkPaths=getfullname(obj.HorizontalGraph.Areas(areaId).Handle);
                obj.ConnectedComponents(connId).BlkHandles=obj.HorizontalGraph.Areas(areaId).Handle;
                obj.ConnectedComponents(connId).Span=...
                Simulink.internal.variantlayout.ConnectedRegion.findBoundingArea(...
                obj.ConnectedComponents(connId).BlkHandles);
                connId=connId+1;
            end
        end


        function findConnectedRegions(obj)





            grConnectedRegions=graph;
            for connId=1:numel(obj.ConnectedComponents)
                grConnectedRegions=addnode(grConnectedRegions,num2str(connId));
            end
            for connId1=1:numel(obj.ConnectedComponents)-1
                for connId2=connId1+1:numel(obj.ConnectedComponents)
                    if doOverlap(obj.ConnectedComponents(connId1),obj.ConnectedComponents(connId2))
                        grConnectedRegions=addedge(grConnectedRegions,num2str(connId1),num2str(connId2));
                    end
                end
            end


            hRegions=conncomp(grConnectedRegions,'OutputForm','cell');
            for connRegionId=1:numel(hRegions)
                compIds=str2double(hRegions{connRegionId});


                blkHandles=cat(1,obj.ConnectedComponents(compIds).BlkHandles);

                obj.ConnectedRegions(connRegionId)=Simulink.internal.variantlayout.ConnectedRegion(blkHandles);
            end

            function isOverlap=doOverlap(connComp1,connComp2)


                rect1=connComp1.Span;
                rect2=connComp2.Span;





                isOverlap=~((rect1(3)<rect2(1))||(rect1(1)>rect2(3))...
                ||(rect1(4)<rect2(2))||(rect1(2)>rect2(4)));
            end
        end


        function sortConnectedComponents(obj)



            xPos=zeros(numel(obj.ConnectedComponents),1);
            yPos=zeros(numel(obj.ConnectedComponents),1);
            for connId=1:numel(obj.ConnectedComponents)
                position=obj.ConnectedComponents(connId).Span;

                xPos(connId)=position(1);
                yPos(connId)=position(2);
            end



            [~,xSortIdx]=sortrows([xPos,yPos]);


            tmp=obj.ConnectedComponents;
            obj.ConnectedComponents=tmp(xSortIdx);
        end


        function sortConnectedRegions(obj,direction)
            xPos=zeros(numel(obj.ConnectedRegions),1);
            yPos=zeros(numel(obj.ConnectedRegions),1);
            for connRegionId=1:numel(obj.ConnectedRegions)
                position=obj.ConnectedRegions(connRegionId).OrigSpan;
                xPos(connRegionId)=position(1);
                yPos(connRegionId)=position(2);
            end
            if direction==Simulink.internal.variantlayout.Hierarchy.HORIZONTAL


                [~,xSortIdx]=sortrows([xPos,yPos]);

                tmp=obj.ConnectedRegions;
                obj.ConnectedRegions=tmp(xSortIdx);
            else


                [~,ySortIdx]=sortrows([yPos,xPos]);

                tmp=obj.ConnectedRegions;
                obj.ConnectedRegions=tmp(ySortIdx);
            end
        end



        function findPartitions(obj)



            obj.sortConnectedRegions(Simulink.internal.variantlayout.Hierarchy.HORIZONTAL);
            obj.ConnectedRegions(1).VerticalPartitionIndex=1;
            rect1=obj.ConnectedRegions(1).OrigSpan;
            xSegment=[rect1(1),rect1(3)];

            obj.VerticalPartitions=Simulink.internal.variantlayout.Partition(obj.ConnectedRegions(1));

            for connRegionId=1:numel(obj.ConnectedRegions)-1
                rect2=obj.ConnectedRegions(connRegionId+1).OrigSpan;



                if(rect2(1)>xSegment(2))||(rect2(3)<xSegment(1))

                    obj.ConnectedRegions(connRegionId+1).VerticalPartitionIndex=...
                    obj.ConnectedRegions(connRegionId).VerticalPartitionIndex+1;
                    xSegment=[rect2(1),rect2(3)];
                    obj.VerticalPartitions(end+1)=Simulink.internal.variantlayout.Partition(obj.ConnectedRegions(connRegionId+1));
                else

                    obj.ConnectedRegions(connRegionId+1).VerticalPartitionIndex=...
                    obj.ConnectedRegions(connRegionId).VerticalPartitionIndex;
                    xSegment=[min(xSegment(1),rect2(1)),max(xSegment(2),rect2(3))];
                    obj.VerticalPartitions(obj.ConnectedRegions(connRegionId).VerticalPartitionIndex).appendRegion(obj.ConnectedRegions(connRegionId+1));
                end
            end



            obj.sortConnectedRegions(Simulink.internal.variantlayout.Hierarchy.VERTICAL);
            obj.ConnectedRegions(1).HorizontalPartitionIndex=1;
            rect1=obj.ConnectedRegions(1).OrigSpan;
            ySegment=[rect1(2),rect1(4)];
            obj.HorizontalPartitions=Simulink.internal.variantlayout.Partition(obj.ConnectedRegions(1));

            for connRegionId=1:numel(obj.ConnectedRegions)-1
                rect2=obj.ConnectedRegions(connRegionId+1).OrigSpan;



                if(rect2(2)>ySegment(2))||(rect2(4)<ySegment(1))

                    obj.ConnectedRegions(connRegionId+1).HorizontalPartitionIndex=...
                    obj.ConnectedRegions(connRegionId).HorizontalPartitionIndex+1;
                    ySegment=[rect2(2),rect2(4)];
                    obj.HorizontalPartitions(end+1)=Simulink.internal.variantlayout.Partition(obj.ConnectedRegions(connRegionId+1));
                else

                    obj.ConnectedRegions(connRegionId+1).HorizontalPartitionIndex=...
                    obj.ConnectedRegions(connRegionId).HorizontalPartitionIndex;
                    ySegment=[min(ySegment(1),rect2(2)),max(ySegment(2),rect2(4))];
                    obj.HorizontalPartitions(obj.ConnectedRegions(connRegionId).HorizontalPartitionIndex).appendRegion(obj.ConnectedRegions(connRegionId+1));
                end
            end
        end



        function placeConnectedRegions(obj)


            for verticalPartitionIdx=1:numel(obj.VerticalPartitions)

                obj.VerticalPartitions(verticalPartitionIdx).sortRegions(Simulink.internal.variantlayout.Hierarchy.VERTICAL);
                deltaLocal=0;
                for regionId=1:numel(obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions)-1
                    oldSpan=obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions(regionId).OrigSpan;
                    newSpan=obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions(regionId).UpdatedSpan;


                    if oldSpan(4)>=newSpan(4)
                        continue;
                    end
                    deltaLocal=max(deltaLocal,newSpan(4)-oldSpan(4));
                    deltaVec=[0,deltaLocal];

                    obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions(regionId+1).setRegionPosition(deltaVec);

                    obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions(regionId+1).updateSpan;
                end
                deltaLocal=0;
                for regionId=numel(obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions):-1:2
                    oldSpan=obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions(regionId).OrigSpan;
                    newSpan=obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions(regionId).UpdatedSpan;


                    if oldSpan(2)<=newSpan(2)
                        continue;
                    end
                    deltaLocal=max(deltaLocal,newSpan(2)-oldSpan(2));
                    deltaVec=[0,deltaLocal];

                    obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions(regionId-1).setRegionPosition(deltaVec);

                    obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions(regionId-1).updateSpan;
                end
            end



            for horizontalPartitionIdx=1:numel(obj.HorizontalPartitions)

                obj.HorizontalPartitions(horizontalPartitionIdx).sortRegions(Simulink.internal.variantlayout.Hierarchy.HORIZONTAL);
                deltaLocal=0;
                for regionId=1:numel(obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions)-1
                    oldSpan=obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions(regionId).OrigSpan;
                    newSpan=obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions(regionId).UpdatedSpan;


                    if oldSpan(3)>=newSpan(3)
                        continue;
                    end
                    deltaLocal=max(deltaLocal,newSpan(3)-oldSpan(3));
                    deltaVec=[deltaLocal,0];

                    obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions(regionId+1).setRegionPosition(deltaVec);

                    obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions(regionId+1).updateSpan;
                end
                deltaLocal=0;
                for regionId=numel(obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions):-1:2
                    oldSpan=obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions(regionId).OrigSpan;
                    newSpan=obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions(regionId).UpdatedSpan;


                    if oldSpan(1)<=newSpan(1)
                        continue;
                    end
                    deltaLocal=max(deltaLocal,newSpan(1)-oldSpan(1));
                    deltaVec=[deltaLocal,0];

                    obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions(regionId-1).setRegionPosition(deltaVec);

                    obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions(regionId-1).updateSpan;
                end
            end



            for horzGraphId=1:numel(obj.HorizontalGraph)
                obj.HorizontalGraph(horzGraphId).reRoute;
            end
            for vertGraphId=1:numel(obj.VerticalGraph)
                obj.VerticalGraph(vertGraphId).reRoute;
            end
        end


        function setModeltoFitView(obj)
            try






                if~isvarname(obj.SystemName),return;end
                if strcmp(get_param(obj.SystemName,'Shown'),'on')
                    set_param(obj.SystemName,'ZoomFactor','FitSystem');
                end
            catch
            end
        end


        function placePartitions(obj,margin)




            for verticalPartitionIdx=2:numel(obj.VerticalPartitions)


                boundPrev=obj.VerticalPartitions(verticalPartitionIdx-1).Bounds;
                currBound=obj.VerticalPartitions(verticalPartitionIdx).Bounds;
                desiredBound=boundPrev(3)+margin;
                deltaX=desiredBound-currBound(1);

                obj.VerticalPartitions(verticalPartitionIdx).sortRegions(Simulink.internal.variantlayout.Hierarchy.VERTICAL);
                for regionId=1:numel(obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions)
                    deltaVec=[deltaX,0];

                    obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions(regionId).setRegionPosition(deltaVec);

                    obj.VerticalPartitions(verticalPartitionIdx).ConnectedRegions(regionId).updateSpan;
                end
                obj.VerticalPartitions(verticalPartitionIdx).updateBounds;
            end



            for horizontalPartitionIdx=2:numel(obj.HorizontalPartitions)


                boundPrev=obj.HorizontalPartitions(horizontalPartitionIdx-1).Bounds;
                currBound=obj.HorizontalPartitions(horizontalPartitionIdx).Bounds;
                desiredBound=boundPrev(4)+margin;
                deltaY=desiredBound-currBound(2);

                obj.HorizontalPartitions(horizontalPartitionIdx).sortRegions(Simulink.internal.variantlayout.Hierarchy.HORIZONTAL);
                for regionId=1:numel(obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions)
                    deltaVec=[0,deltaY];

                    obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions(regionId).setRegionPosition(deltaVec);

                    obj.HorizontalPartitions(horizontalPartitionIdx).ConnectedRegions(regionId).updateSpan;
                end
                obj.HorizontalPartitions(horizontalPartitionIdx).updateBounds;
            end



            for horzGraphId=1:numel(obj.HorizontalGraph)
                obj.HorizontalGraph(horzGraphId).reRoute;
            end
            for vertGraphId=1:numel(obj.VerticalGraph)
                obj.VerticalGraph(vertGraphId).reRoute;
            end
        end
    end


end


