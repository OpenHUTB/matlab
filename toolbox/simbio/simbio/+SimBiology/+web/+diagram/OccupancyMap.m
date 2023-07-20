classdef OccupancyMap<handle
    properties(GetAccess=public,SetAccess=private)
Canvas
        Rectangles double
AdjacencyMatrix
    end

    properties(Access=private)
SectioningFunction
GetDefaultChildRectangleAdjacenciesFunction
UpdateAllChildAdjacenciesFunction


        Debug logical=false
Figure
Axes
Graphical
InscribedGraphical
IntermediateGraphical
    end

    properties(Constant)

        LEFT=1;
        RIGHT=2;
        TOP=3;
        BOTTOM=4;
        OCCUPIED=5;




        HORIZ=1;
        VERT=2;

        HORIZ_RIGHT=1;
        HORIZ_LEFT=-1;
        VERT_BOTTOM=2;
        VERT_TOP=-2;
    end

    methods



        function obj=OccupancyMap(initialRect,sectioningMethod,debug)















            obj.Canvas=initialRect;
            obj.Rectangles=[initialRect,0];
            obj.AdjacencyMatrix=sparse(0);

            if nargin>=2
                switch sectioningMethod
                case 'corners'
                    obj.SectioningFunction=@SimBiology.web.diagram.OccupancyMap.sectionRectangleIntoCornerChildren;
                    obj.GetDefaultChildRectangleAdjacenciesFunction=@SimBiology.web.diagram.OccupancyMap.getDefaultChildRectangleAdjacenciesForCornerChildren;
                otherwise
                    obj.SectioningFunction=@SimBiology.web.diagram.OccupancyMap.sectionRectangleIntoHorizontalChildren;
                    obj.GetDefaultChildRectangleAdjacenciesFunction=@SimBiology.web.diagram.OccupancyMap.getDefaultChildRectangleAdjacenciesForHorizontalChildren;
                end
            else
                obj.SectioningFunction=@SimBiology.web.diagram.OccupancyMap.sectionRectangleIntoHorizontalChildren;
                obj.GetDefaultChildRectangleAdjacenciesFunction=@SimBiology.web.diagram.OccupancyMap.getDefaultChildRectangleAdjacenciesForHorizontalChildren;
            end


            if nargin==3
                obj.Debug=debug;
            end



            obj.Debug=obj.Debug&&obj.getWidth(obj.Canvas)>0&&obj.getHeight(obj.Canvas)>0;

            if obj.useDebug
                obj.Figure=figure;
                obj.Axes=axes(obj.Figure,'NextPlot','add','ydir','rev','XLim',initialRect(1:2),'YLim',initialRect(3:4));
                obj.Graphical=obj.drawTileRectangle(obj.Rectangles(:,1:4),false);
            end
        end

        function delete(obj)
            delete(obj.Figure);
        end




        function num=numRectangles(obj)
            num=obj.getNumRectanglesFromList(obj.Rectangles);
        end

        function rect=getRectangle(obj,index)
            rect=obj.getRectangleFromList(obj.Rectangles,index);
        end





        function isFit=isFitWithoutOverlap(obj,rect)



            if isRectangleContainedInCanvas(obj,rect)
                isFit=~isOverlapForContainedRectangle(obj,rect);
            else
                isFit=false;
            end
        end




        function isOverlap=isOverlap(obj,rect)





            rect=trimRectangleToFitInCanvas(obj,rect);
            if isempty(rect)
                isOverlap=false;
            else
                isOverlap=isOverlapForContainedRectangle(obj,rect);
            end
        end




        function accepted=add(obj,rect,allowOverlap)









            if nargin==2
                allowOverlap=true;
            end

            accepted=false;
            rect=trimRectangleToFitInCanvas(obj,rect);
            if~isempty(rect)

                rect(obj.OCCUPIED)=1;


                rect_i=obj.findRects(rect);



                overlappingIdx=logical(obj.Rectangles(rect_i,obj.OCCUPIED));
                if any(overlappingIdx)
                    if allowOverlap
                        accepted=true;




                        firstOverlappingRectangle=obj.getRectangle(rect_i(find(overlappingIdx,1)));
                        [partialRectsToAdd,zeroMask]=obj.SectioningFunction(rect,firstOverlappingRectangle);
                        partialRectsToAdd(zeroMask,:)=[];
                        for i=1:obj.getNumRectanglesFromList(partialRectsToAdd)
                            obj.add(obj.getRectangleFromList(partialRectsToAdd,i),allowOverlap);
                        end
                    else
                        return;
                    end
                else
                    accepted=true;

                    initialSize=size(obj.Rectangles,1);
                    oldAdjacenciesForAddedRectangle=zeros(initialSize,1);
                    newAdjacenciesForAddedRectangle=zeros(1,0);

                    for j=1:numel(rect_i)
                        originalRect=obj.Rectangles(rect_i(j),:);

                        [newRectangles,zeroMask]=obj.SectioningFunction(originalRect,rect);
                        zeroIdx=find(zeroMask);


                        [CHILD_ADJ_MATRIX,NEW_RECTANGLE_ADJACENIES,USE_FLAG_STRUCTS]=obj.GetDefaultChildRectangleAdjacenciesFunction(zeroMask);


                        originalSize=size(obj.AdjacencyMatrix,1);
                        additionalSize=4;
                        newAdjMatrix=[obj.AdjacencyMatrix,zeros(originalSize,additionalSize)];
                        newAdjMatrix=[newAdjMatrix;[zeros(additionalSize,originalSize),CHILD_ADJ_MATRIX]];%#ok<AGROW>




                        originalAdjCol=obj.AdjacencyMatrix(:,rect_i(j));
                        originalAdjRow=obj.AdjacencyMatrix(rect_i(j),:)';

                        for r=1:4
                            newAdjMatrix(1:originalSize,originalSize+r)=findChildAdjacencies(obj,newRectangles(r,:),...
                            USE_FLAG_STRUCTS(r).useLeft,USE_FLAG_STRUCTS(r).useRight,...
                            USE_FLAG_STRUCTS(r).useTop,USE_FLAG_STRUCTS(r).useBottom,...
                            originalAdjCol,originalAdjRow);
                        end






                        originalAdjCol=originalAdjCol(1:initialSize);
                        originalAdjRow=originalAdjRow(1:initialSize);


                        r=5;
                        oldAdjacenciesForAddedRectangle=oldAdjacenciesForAddedRectangle+findChildAdjacencies(obj,rect,...
                        USE_FLAG_STRUCTS(r).useLeft,USE_FLAG_STRUCTS(r).useRight,...
                        USE_FLAG_STRUCTS(r).useTop,USE_FLAG_STRUCTS(r).useBottom,...
                        originalAdjCol,originalAdjRow);


                        newRectangles(zeroMask,:)=[];
                        newAdjMatrix(zeroIdx+originalSize,:)=[];
                        newAdjMatrix(:,zeroIdx+originalSize)=[];


                        newAdjacenciesForAddedRectangle=[newAdjacenciesForAddedRectangle,NEW_RECTANGLE_ADJACENIES(~zeroMask)];%#ok<AGROW>


                        newRectangles(:,obj.OCCUPIED)=zeros(size(newRectangles,1),1);
                        obj.Rectangles=vertcat(obj.Rectangles,newRectangles);
                        obj.AdjacencyMatrix=newAdjMatrix;

                        if obj.useDebug
                            delete(obj.Graphical(rect_i(j)));
                            for k=1:size(newRectangles,1)
                                obj.Graphical(end+1)=obj.drawTileRectangle(obj.getRectangleFromList(newRectangles,k),false);
                            end
                        end
                    end


                    rect(obj.OCCUPIED)=1;
                    obj.Rectangles=vertcat(obj.Rectangles,rect);
                    if obj.useDebug
                        obj.Graphical(end+1)=obj.drawTileRectangle(rect,true);
                    end



                    obj.AdjacencyMatrix(end+1,:)=0;
                    obj.AdjacencyMatrix(:,end+1)=0;

                    obj.AdjacencyMatrix(1:initialSize,end)=oldAdjacenciesForAddedRectangle;
                    obj.AdjacencyMatrix(end-(numel(newAdjacenciesForAddedRectangle)):end-1,end)=newAdjacenciesForAddedRectangle;



                    obj.Rectangles(rect_i,:)=[];
                    obj.AdjacencyMatrix(rect_i,:)=[];
                    obj.AdjacencyMatrix(:,rect_i)=[];
                    if obj.useDebug
                        obj.Graphical(rect_i)=[];
                    end
                end
            end
        end




        function[success,rect]=findRectangle(obj,width,height,searchFirstToLast)









            if nargin==3
                searchFirstToLast=false;
            end

            newRect=[0,width,0,height];





            if searchFirstToLast
                start=1;
                finish=obj.numRectangles;
                delta=1;
            else
                start=obj.numRectangles;
                finish=1;
                delta=-1;
            end
            for i=start:delta:finish
                rect_i=obj.getRectangle(i);
                if~obj.isOccupied(rect_i)&&obj.fitsVertical(newRect,rect_i)&&obj.fitsHorizontal(newRect,rect_i)


                    if obj.useDebug
                        obj.InscribedGraphical=obj.drawInscribedRectangle(rect_i);
                    end


                    success=true;
                    rect=obj.placeNewRectangleInFreeRectangleInTopLeft(rect_i,obj.getAdjacencies(i),width,height);


                    if obj.useDebug
                        delete(obj.InscribedGraphical);
                    end

                    return;
                end
            end




            excludedIndices=logical(obj.Rectangles(:,obj.OCCUPIED))';
            [success,rect]=findRectangleRecursive(obj,newRect,[],[],[],excludedIndices,searchFirstToLast);
            if~isempty(obj.InscribedGraphical)
                delete(obj.InscribedGraphical);
            end
        end




        function[success,addedRect]=addNearTargetPoint(obj,targetRect)







            success=false;
            addedRect=[];


            xDelta=obj.getWidth(targetRect);
            yDelta=obj.getHeight(targetRect);
            maxShiftIterationsY=floor(max([0,targetRect(obj.TOP)-obj.Canvas(obj.TOP),obj.Canvas(obj.BOTTOM)-targetRect(obj.BOTTOM)])/yDelta);
            maxShiftIterationsX=floor(max([0,targetRect(obj.LEFT)-obj.Canvas(obj.LEFT),obj.Canvas(obj.RIGHT)-targetRect(obj.RIGHT)])/xDelta);

            for i=0:maxShiftIterationsY


                if i==maxShiftIterationsY
                    jmax=maxShiftIterationsX;
                else
                    jmax=min(i,maxShiftIterationsX);
                end
                for j=0:jmax

                    shift=[xDelta*j,xDelta*j,yDelta*i,yDelta*i];
                    directions=[1,1,1,1;
                    1,1,-1,-1;
                    -1,-1,1,1;
                    -1,-1,-1,-1];
                    for k=1:4
                        testRect=targetRect+shift.*directions(k,:);
                        isFit=obj.isFitWithoutOverlap(testRect);
                        if isFit
                            obj.add(testRect);
                            success=true;
                            addedRect=testRect;
                            return;
                        end
                    end
                end
            end
        end
    end

    methods(Access=private)




        function[success,rect]=findRectangleRecursive(obj,newRect,inscribedRectangle,inscribedRectangleAdjacencies,originalRectangleIndices,excludedIndices,searchFirstToLast)













            success=false;
            rect=[];


            isFitVertical=obj.fitsVertical(newRect,inscribedRectangle);
            isFitHorizontal=obj.fitsHorizontal(newRect,inscribedRectangle);

            if isFitVertical&&isFitHorizontal
                success=true;
                rect=obj.placeNewRectangleInFreeRectangleInTopLeft(inscribedRectangle,inscribedRectangleAdjacencies,obj.getWidth(newRect),obj.getHeight(newRect));
                return;



            else
                expandVertically=~isFitVertical;



                adjRectIndices=obj.getAdjacentRectanglesToTryAdding(expandVertically,inscribedRectangle,inscribedRectangleAdjacencies,excludedIndices,searchFirstToLast);

                for i=1:numel(adjRectIndices)





                    adjRectIndex=adjRectIndices(i);
                    excludedIndices(adjRectIndex)=true;


                    [updatedInscribedRect,updatedInscribedRectAdj]=obj.updateInscribedRectangle(expandVertically,inscribedRectangle,inscribedRectangleAdjacencies,originalRectangleIndices,adjRectIndex,excludedIndices);


                    if~isempty(updatedInscribedRect)
                        [success,rect]=findRectangleRecursive(obj,newRect,updatedInscribedRect,updatedInscribedRectAdj,[originalRectangleIndices,adjRectIndex],excludedIndices,searchFirstToLast);
                        if success
                            return;
                        end
                    end
                end
            end
        end

        function adjacentRectsIndices=getAdjacentRectanglesToTryAdding(obj,expandVertically,inscribedRect,inscribedRectAdjacencies,excludedIndices,searchFirstToLast)








            if isempty(inscribedRect)

                includedIndices=~excludedIndices;
            else
                if expandVertically
                    includedIndices=obj.findVerticallyAdjacentRectangleIndices(inscribedRectAdjacencies,excludedIndices);
                else
                    includedIndices=obj.findHorizontallyAdjacentRectangleIndices(inscribedRectAdjacencies,excludedIndices);
                end
            end

            adjacentRectsIndices=find(includedIndices);
            if~searchFirstToLast
                adjacentRectsIndices=flip(adjacentRectsIndices);
            end
        end

        function[updatedInscribedRect,updatedInscribedRectAdj]=updateInscribedRectangle(obj,expandVertically,inscribedRectangle,inscribedRectangleAdjacencies,originalRectangleIndices,rectangleToAddIndex,excludedIndices)







            rectangleToAdd=obj.getRectangle(rectangleToAddIndex);
            rectangleToAddAdjacencies=obj.getAdjacencies(rectangleToAddIndex,[]);



            if isempty(inscribedRectangle)
                updatedInscribedRect=rectangleToAdd;
                updatedInscribedRectAdj=rectangleToAddAdjacencies;
            else





                [intermediateRectangle,intermediateRectangleAdjacencies]=updateIntermediateRectangle(obj,expandVertically,originalRectangleIndices,rectangleToAdd,rectangleToAddAdjacencies);
                [updatedInscribedRect,updatedInscribedRectAdj]=findInscribedRectangle(obj,expandVertically,inscribedRectangle,inscribedRectangleAdjacencies,intermediateRectangle,intermediateRectangleAdjacencies);
            end


            if obj.useDebug
                if~isempty(obj.IntermediateGraphical)
                    delete(obj.IntermediateGraphical);
                end
                if~isempty(obj.InscribedGraphical)
                    delete(obj.InscribedGraphical);
                end
                obj.InscribedGraphical=obj.drawInscribedRectangle(updatedInscribedRect);
            end
        end

        function[intermediateRectangle,intermediateRectangleAdjacencies]=updateIntermediateRectangle(obj,expandVertically,originalRectangleIndices,intermediateRectangle,intermediateRectangleAdjacencies)












            if obj.useDebug
                if~isempty(obj.IntermediateGraphical)
                    delete(obj.IntermediateGraphical);
                end
                obj.IntermediateGraphical=obj.drawIntermediateRectangle(intermediateRectangle);
            end







            excludedIndices=true(1,obj.numRectangles);
            excludedIndices(originalRectangleIndices)=false;



            if expandVertically
                includedIndices=obj.findHorizontallyAdjacentRectangleIndices(intermediateRectangleAdjacencies,excludedIndices);
            else
                includedIndices=obj.findVerticallyAdjacentRectangleIndices(intermediateRectangleAdjacencies,excludedIndices);
            end





            rectanglesToAddIndices=find(includedIndices);
            if~isempty(rectanglesToAddIndices)
                for i=1:numel(rectanglesToAddIndices)
                    [intermediateRectangle,intermediateRectangleAdjacencies]=findInscribedRectangle(obj,~expandVertically,...
                    intermediateRectangle,intermediateRectangleAdjacencies,...
                    obj.getRectangle(rectanglesToAddIndices(i)),obj.getAdjacencies(rectanglesToAddIndices(i),[]));

                    if obj.useDebug
                        if~isempty(obj.IntermediateGraphical)
                            delete(obj.IntermediateGraphical);
                        end
                        obj.IntermediateGraphical=obj.drawIntermediateRectangle(intermediateRectangle);
                    end
                end
                [intermediateRectangle,intermediateRectangleAdjacencies]=updateIntermediateRectangle(obj,expandVertically,originalRectangleIndices,intermediateRectangle,intermediateRectangleAdjacencies);
            end

        end

        function[inscribedRect,inscribedRectAdjacencies]=findInscribedRectangle(obj,areAdjacentVertically,rect1,rect1Adj,rect2,rect2Adj)








            inscribedRect=[];
            inscribedRectAdjacencies=[];

            if areAdjacentVertically
                newLeft=max(rect1(obj.LEFT),rect2(obj.LEFT));
                newRight=min(rect1(obj.RIGHT),rect2(obj.RIGHT));
                if newRight>newLeft
                    newTop=min(rect1(obj.TOP),rect2(obj.TOP));
                    newBottom=max(rect1(obj.BOTTOM),rect2(obj.BOTTOM));
                    inscribedRect=[newLeft,newRight,newTop,newBottom];


                    isRect1OnTop=rect1(obj.TOP)<rect2(obj.TOP);

                    use1Left=(rect1(obj.LEFT)==newLeft);
                    use1Right=(rect1(obj.RIGHT)==newRight);
                    use1Top=isRect1OnTop;
                    use1Bottom=~isRect1OnTop;
                    use2Left=(rect2(obj.LEFT)==newLeft);
                    use2Right=(rect2(obj.RIGHT)==newRight);
                    use2Top=~isRect1OnTop;
                    use2Bottom=isRect1OnTop;

                    inscribedRectAdjacencies=obj.mergeAdjacencies(inscribedRect,rect1Adj,rect2Adj,...
                    use1Left,use1Right,use1Top,use1Bottom,...
                    use2Left,use2Right,use2Top,use2Bottom);
                end

            else
                newTop=max(rect1(obj.TOP),rect2(obj.TOP));
                newBottom=min(rect1(obj.BOTTOM),rect2(obj.BOTTOM));
                if newBottom>newTop
                    newLeft=min(rect1(obj.LEFT),rect2(obj.LEFT));
                    newRight=max(rect1(obj.RIGHT),rect2(obj.RIGHT));
                    inscribedRect=[newLeft,newRight,newTop,newBottom];


                    isRect1OnLeft=rect1(obj.LEFT)<rect2(obj.LEFT);

                    use1Left=isRect1OnLeft;
                    use1Right=~isRect1OnLeft;
                    use1Top=rect1(obj.TOP)==newTop;
                    use1Bottom=rect1(obj.BOTTOM)==newBottom;
                    use2Left=~isRect1OnLeft;
                    use2Right=isRect1OnLeft;
                    use2Top=rect2(obj.TOP)==newTop;
                    use2Bottom=rect2(obj.BOTTOM)==newBottom;

                    inscribedRectAdjacencies=obj.mergeAdjacencies(inscribedRect,rect1Adj,rect2Adj,...
                    use1Left,use1Right,use1Top,use1Bottom,...
                    use2Left,use2Right,use2Top,use2Bottom);
                end
            end
        end

        function adjacencies=getAdjacencies(obj,rectangleIndex,excludedIndices)






            if nargin==2
                excludedIndices=[];
            end

            adjacencies=obj.AdjacencyMatrix(rectangleIndex,:)-obj.AdjacencyMatrix(:,rectangleIndex)';

            adjacencies(excludedIndices)=0;
        end




        function idx=findRects(obj,rect)

            fx=rect(obj.LEFT)<obj.Rectangles(:,obj.RIGHT)&rect(obj.RIGHT)>obj.Rectangles(:,obj.LEFT);
            fy=rect(obj.TOP)<obj.Rectangles(:,obj.BOTTOM)&rect(obj.BOTTOM)>obj.Rectangles(:,obj.TOP);
            idx=find(fx&fy);
        end

        function flag=isRectangleContainedInCanvas(obj,rect)
            flag=(rect(obj.LEFT)>=obj.Canvas(obj.LEFT))&&...
            (rect(obj.RIGHT)<=obj.Canvas(obj.RIGHT))&&...
            (rect(obj.TOP)>=obj.Canvas(obj.TOP))&&...
            (rect(obj.BOTTOM)<=obj.Canvas(obj.BOTTOM));
        end

        function rect=trimRectangleToFitInCanvas(obj,rect)
            if rect(obj.LEFT)<obj.Canvas(obj.LEFT)
                rect(obj.LEFT)=obj.Canvas(obj.LEFT);
            elseif rect(obj.LEFT)>obj.Canvas(obj.RIGHT)
                rect=[];
                return;
            end

            if rect(obj.RIGHT)>obj.Canvas(obj.RIGHT)
                rect(obj.RIGHT)=obj.Canvas(obj.RIGHT);
            elseif rect(obj.RIGHT)<obj.Canvas(obj.LEFT)
                rect=[];
                return;
            end

            if rect(obj.TOP)<obj.Canvas(obj.TOP)
                rect(obj.TOP)=obj.Canvas(obj.TOP);
            elseif rect(obj.TOP)>obj.Canvas(obj.BOTTOM)
                rect=[];
                return;
            end

            if rect(obj.BOTTOM)>obj.Canvas(obj.BOTTOM)
                rect(obj.BOTTOM)=obj.Canvas(obj.BOTTOM);
            elseif rect(obj.BOTTOM)<obj.Canvas(obj.TOP)
                rect=[];
                return;
            end

            if obj.getWidth(rect)==0||obj.getHeight(rect)==0
                rect=[];
            end
        end

        function isOverlap=isOverlapForContainedRectangle(obj,rect)
            rect_i=obj.findRects(rect);
            isOverlap=any(logical(obj.Rectangles(rect_i,obj.OCCUPIED)));
        end

        function newRect=placeNewRectangleInFreeRectangleInTopLeft(~,freeRect,~,width,height)




            newRect=[freeRect(SimBiology.web.diagram.OccupancyMap.LEFT),...
            freeRect(SimBiology.web.diagram.OccupancyMap.LEFT)+width,...
            freeRect(SimBiology.web.diagram.OccupancyMap.TOP)...
            ,freeRect(SimBiology.web.diagram.OccupancyMap.TOP)+height];
        end

        function newRect=placeNewRectangleInFreeRectangle_maximizeAdjacencies(obj,freeRect,freeRectAdjacencies,width,height)





            freeRectWidth=obj.getWidth(freeRect);
            freeRectHeight=obj.getHeight(freeRect);



            rectsToTry=[freeRect(SimBiology.web.diagram.OccupancyMap.LEFT),...
            freeRect(SimBiology.web.diagram.OccupancyMap.LEFT)+width,...
            freeRect(SimBiology.web.diagram.OccupancyMap.TOP),...
            freeRect(SimBiology.web.diagram.OccupancyMap.TOP)+height;...

            freeRect(SimBiology.web.diagram.OccupancyMap.RIGHT)-width,...
            freeRect(SimBiology.web.diagram.OccupancyMap.RIGHT),...
            freeRect(SimBiology.web.diagram.OccupancyMap.TOP),...
            freeRect(SimBiology.web.diagram.OccupancyMap.TOP)+height;...

            freeRect(SimBiology.web.diagram.OccupancyMap.LEFT),...
            freeRect(SimBiology.web.diagram.OccupancyMap.LEFT)+width,...
            freeRect(SimBiology.web.diagram.OccupancyMap.BOTTOM)-height,...
            freeRect(SimBiology.web.diagram.OccupancyMap.BOTTOM);...

            freeRect(SimBiology.web.diagram.OccupancyMap.RIGHT)-width,...
            freeRect(SimBiology.web.diagram.OccupancyMap.RIGHT),...
            freeRect(SimBiology.web.diagram.OccupancyMap.BOTTOM)-height,...
            freeRect(SimBiology.web.diagram.OccupancyMap.BOTTOM)];



            isEqualWidth=(freeRectWidth==width);
            isEqualHeight=(freeRectHeight==height);


            adjacenciesUseFlags=[true,isEqualWidth,true,isEqualHeight;...
            isEqualWidth,true,true,isEqualHeight;...
            true,isEqualWidth,isEqualHeight,true;...
            isEqualWidth,true,isEqualHeight,true];


            i=1;
            rect_i=rectsToTry(i,:);
            adj_i=getFilteredAdjacencies(obj,rect_i,freeRectAdjacencies,adjacenciesUseFlags(i,1),adjacenciesUseFlags(i,2),adjacenciesUseFlags(i,3),adjacenciesUseFlags(i,4));
            occupiedPerimeter=obj.getOccupiedPerimeterLength(rect_i,adj_i);
            newRect=rect_i;

            for i=2:size(rectsToTry,1)
                rect_i=rectsToTry(i,:);
                adj_i=getFilteredAdjacencies(obj,rect_i,freeRectAdjacencies,adjacenciesUseFlags(i,1),adjacenciesUseFlags(i,2),adjacenciesUseFlags(i,3),adjacenciesUseFlags(i,4));
                occPerim_i=obj.getOccupiedPerimeterLength(rect_i,adj_i);

                if(occPerim_i>occupiedPerimeter)
                    occupiedPerimeter=occPerim_i;
                    newRect=rect_i;
                end
            end
        end

        function newRect=placeNewRectangleInCenter(~,freeRect,~,width,height)




            originalWidth=SimBiology.web.diagram.OccupancyMap.getWidth(freeRect);
            originalHeight=SimBiology.web.diagram.OccupancyMap.getHeight(freeRect);
            delta_horiz=originalWidth-width;
            delta_vert=originalHeight-height;

            newRect=[freeRect(SimBiology.web.diagram.OccupancyMap.LEFT)+ceil(delta_horiz/2),...
            freeRect(SimBiology.web.diagram.OccupancyMap.RIGHT)-floor(delta_horiz/2),...
            freeRect(SimBiology.web.diagram.OccupancyMap.TOP)+ceil(delta_vert/2),...
            freeRect(SimBiology.web.diagram.OccupancyMap.BOTTOM)-floor(delta_vert/2)];
        end




        function adjacencyCol=findChildAdjacencies(obj,newRectangle,useLeft,useRight,useTop,useBottom,originalAdjCol,originalAdjRow)



            adjacencyCol=mergeAdjacencies(obj,newRectangle,originalAdjCol,-originalAdjRow,useLeft,useRight,useTop,useBottom,useLeft,useRight,useTop,useBottom);
        end

        function adjacencies=mergeAdjacencies(obj,rect,adj1,adj2,use1Left,use1Right,use1Top,use1Bottom,use2Left,use2Right,use2Top,use2Bottom)

            adjacencies1=getFilteredAdjacencies(obj,rect,adj1,use1Left,use1Right,use1Top,use1Bottom);
            adjacencies2=getFilteredAdjacencies(obj,rect,adj2,use2Left,use2Right,use2Top,use2Bottom);




            adjacencies=adjacencies1;
            idx2=find(adjacencies2);
            adjacencies(idx2)=adjacencies2(idx2);
        end

        function adjacencies=getFilteredAdjacencies(obj,rect,adjacencies,useLeft,useRight,useTop,useBottom)

            index=(useRight&(adjacencies==obj.HORIZ_RIGHT))|...
            (useLeft&(adjacencies==obj.HORIZ_LEFT))|...
            (useBottom&(adjacencies==obj.VERT_BOTTOM))|...
            (useTop&(adjacencies==obj.VERT_TOP));

            adjacencies(~index)=0;


            adjacencies=obj.confirmOverlapForAdjacenies(rect,adjacencies);
        end

        function adjacencyCol=confirmOverlapForAdjacenies(obj,newRectangle,adjacencyCol)
            adjacentIdx=find(adjacencyCol);
            for idx=1:numel(adjacentIdx)
                i=adjacentIdx(idx);
                if~adjacencyCol(i)==0
                    adjVal=abs(adjacencyCol(i));

                    if adjVal==obj.HORIZ
                        if(newRectangle(obj.BOTTOM)<=obj.Rectangles(i,obj.TOP)||newRectangle(obj.TOP)>=obj.Rectangles(i,obj.BOTTOM))
                            adjacencyCol(i)=0;
                        end

                    elseif adjVal==obj.VERT
                        if(newRectangle(obj.RIGHT)<=obj.Rectangles(i,obj.LEFT)||newRectangle(obj.LEFT)>=obj.Rectangles(i,obj.RIGHT))
                            adjacencyCol(i)=0;
                        end
                    end
                end
            end
        end

        function occupiedPerimeter=getOccupiedPerimeterLength(obj,rect,rectAdj)
            occupiedPerimeter=0;
            for i=1:numel(rectAdj)
                if obj.isVerticallyAdjacent(rectAdj(i))&&obj.isOccupied(obj.getRectangle(i))
                    adjRect=obj.getRectangle(i);
                    leftBound=max(rect(obj.LEFT),adjRect(obj.LEFT));
                    rightBound=min(rect(obj.RIGHT),adjRect(obj.RIGHT));
                    occupiedPerimeter=occupiedPerimeter+(rightBound-leftBound);
                elseif obj.isHorizontallyAdjacent(rectAdj(i))&&obj.isOccupied(obj.getRectangle(i))
                    adjRect=obj.getRectangle(i);
                    topBound=max(rect(obj.TOP),adjRect(obj.TOP));
                    bottomBound=min(rect(obj.BOTTOM),adjRect(obj.BOTTOM));
                    occupiedPerimeter=occupiedPerimeter+(bottomBound-topBound);
                end
            end
        end




        function use=useDebug(obj)
            use=obj.Debug;
        end

        function r=drawTileRectangle(obj,rect,occupied)
            if occupied
                color=[1,0,0];
            else
                color=[0,1,0];
            end
            r=obj.drawRectangle(rect,color);
        end

        function r=drawInscribedRectangle(obj,rect)
            color=[0,0,1];
            r=obj.drawRectangle(rect,color);
        end

        function r=drawIntermediateRectangle(obj,rect)
            color=[1,1,0];
            r=obj.drawRectangle(rect,color);
        end

        function r=drawRectangle(obj,rect,color)
            x=[rect(obj.LEFT),rect(obj.LEFT),rect(obj.RIGHT),rect(obj.RIGHT)];
            y=[rect(obj.TOP),rect(obj.BOTTOM),rect(obj.BOTTOM),rect(obj.TOP)];
            r=patch(obj.Axes,x,y,color);
        end
    end





    methods(Static,Access=private)
        function num=getNumRectanglesFromList(rectList)
            num=size(rectList,1);
        end

        function rect=getRectangleFromList(rectList,index)
            rect=rectList(index,:);
        end

        function[childRectangles,zeroMask]=sectionRectangleIntoHorizontalChildren(parentRect,overlappingRect)
            operatingRect=SimBiology.web.diagram.OccupancyMap.intersect(parentRect,overlappingRect);

            LEFT=SimBiology.web.diagram.OccupancyMap.LEFT;
            RIGHT=SimBiology.web.diagram.OccupancyMap.RIGHT;
            TOP=SimBiology.web.diagram.OccupancyMap.TOP;
            BOTTOM=SimBiology.web.diagram.OccupancyMap.BOTTOM;

            childN=[parentRect(LEFT),parentRect(RIGHT),parentRect(TOP),operatingRect(TOP)];
            childW=[parentRect(LEFT),operatingRect(LEFT),operatingRect(TOP),operatingRect(BOTTOM)];
            childE=[operatingRect(RIGHT),parentRect(RIGHT),operatingRect(TOP),operatingRect(BOTTOM)];
            childS=[parentRect(LEFT),parentRect(RIGHT),operatingRect(BOTTOM),parentRect(BOTTOM)];




            childRectangles=[childS;childE;childW;childN];

            zeroMask=SimBiology.web.diagram.OccupancyMap.findZeroSizeRectangles(childRectangles);
        end

        function[childRectangles,zeroMask]=sectionRectangleIntoCornerChildren(parentRect,overlappingRect)
            operatingRect=SimBiology.web.diagram.OccupancyMap.intersect(parentRect,overlappingRect);

            LEFT=SimBiology.web.diagram.OccupancyMap.LEFT;
            RIGHT=SimBiology.web.diagram.OccupancyMap.RIGHT;
            TOP=SimBiology.web.diagram.OccupancyMap.TOP;
            BOTTOM=SimBiology.web.diagram.OccupancyMap.BOTTOM;

            childNW=[parentRect(LEFT),operatingRect(LEFT),parentRect(TOP),parentRect(BOTTOM)];
            childNE=[operatingRect(LEFT),parentRect(RIGHT),parentRect(TOP),operatingRect(TOP)];
            childSW=[operatingRect(LEFT),operatingRect(RIGHT),operatingRect(BOTTOM),parentRect(BOTTOM)];
            childSE=[operatingRect(RIGHT),parentRect(RIGHT),operatingRect(TOP),parentRect(BOTTOM)];

            childRectangles=[childNW;childNE;childSW;childSE];

            zeroMask=SimBiology.web.diagram.OccupancyMap.findZeroSizeRectangles(childRectangles);
        end

        function zeroMask=findZeroSizeRectangles(childRectangles)

            zeroW=childRectangles(:,SimBiology.web.diagram.OccupancyMap.RIGHT)-childRectangles(:,SimBiology.web.diagram.OccupancyMap.LEFT)==0;
            zeroH=childRectangles(:,SimBiology.web.diagram.OccupancyMap.BOTTOM)-childRectangles(:,SimBiology.web.diagram.OccupancyMap.TOP)==0;
            zeroMask=zeroW|zeroH;
        end

        function[CHILD_ADJ_MATRIX,NEW_RECTANGLE_ADJACENIES,USE_FLAG_STRUCTS]=getDefaultChildRectangleAdjacenciesForHorizontalChildren(zeroMask)

            S=1;
            E=2;
            W=3;
            N=4;
            OCCUPIED=5;


            CHILD_ADJ_MATRIX=zeros(4);


            CHILD_ADJ_MATRIX(S,E)=SimBiology.web.diagram.OccupancyMap.VERT_TOP;
            CHILD_ADJ_MATRIX(S,W)=SimBiology.web.diagram.OccupancyMap.VERT_TOP;
            CHILD_ADJ_MATRIX(E,N)=SimBiology.web.diagram.OccupancyMap.VERT_TOP;
            CHILD_ADJ_MATRIX(W,N)=SimBiology.web.diagram.OccupancyMap.VERT_TOP;


            NEW_RECTANGLE_ADJACENIES=[SimBiology.web.diagram.OccupancyMap.VERT_TOP,...
            SimBiology.web.diagram.OccupancyMap.HORIZ_LEFT,...
            SimBiology.web.diagram.OccupancyMap.HORIZ_RIGHT,...
            SimBiology.web.diagram.OccupancyMap.VERT_BOTTOM];



            USE_FLAG_STRUCTS=struct('index',{S,E,W,N,OCCUPIED},...
            'useLeft',{true,true,false,true,zeroMask(E)},...
            'useRight',{true,false,true,true,zeroMask(W)},...
            'useTop',{true,zeroMask(S),zeroMask(S),false,zeroMask(S)},...
            'useBottom',{false,zeroMask(N),zeroMask(N),true,zeroMask(N)});
        end

        function[CHILD_ADJ_MATRIX,NEW_RECTANGLE_ADJACENIES,USE_FLAG_STRUCTS]=getDefaultChildRectangleAdjacenciesForCornerChildren(zeroMask)

            NW=1;
            NE=2;
            SW=3;
            SE=4;
            OCCUPIED=5;


            CHILD_ADJ_MATRIX=zeros(4);

            CHILD_ADJ_MATRIX(NW,NE)=SimBiology.web.diagram.OccupancyMap.HORIZ_RIGHT;
            CHILD_ADJ_MATRIX(NW,SW)=SimBiology.web.diagram.OccupancyMap.HORIZ_RIGHT;
            CHILD_ADJ_MATRIX(SW,SE)=SimBiology.web.diagram.OccupancyMap.HORIZ_RIGHT;

            CHILD_ADJ_MATRIX(NE,SE)=SimBiology.web.diagram.OccupancyMap.VERT_BOTTOM;


            NEW_RECTANGLE_ADJACENIES=[SimBiology.web.diagram.OccupancyMap.HORIZ_RIGHT,...
            SimBiology.web.diagram.OccupancyMap.VERT_BOTTOM,...
            SimBiology.web.diagram.OccupancyMap.VERT_TOP,...
            SimBiology.web.diagram.OccupancyMap.HORIZ_LEFT];

            USE_FLAG_STRUCTS=struct('index',{NW,NE,SW,SE,OCCUPIED},...
            'useLeft',{false,true,zeroMask(SE),true,zeroMask(SE)},...
            'useRight',{true,zeroMask(NW),zeroMask(NW),false,zeroMask(NW)},...
            'useTop',{true,false,true,true,zeroMask(SW)},...
            'useBottom',{true,true,false,zeroMask(NE),zeroMask(NE)});
        end

        function rect=intersect(rectA,rectB)
            rects=[rectA;rectB];
            rect=[max(rects(:,1)),min(rects(:,2)),max(rects(:,3)),min(rects(:,4))];
        end

        function flag=isOccupied(rect)
            flag=rect(SimBiology.web.diagram.OccupancyMap.OCCUPIED);
        end

        function width=getWidth(rect)
            width=rect(SimBiology.web.diagram.OccupancyMap.RIGHT)-rect(SimBiology.web.diagram.OccupancyMap.LEFT);
        end

        function height=getHeight(rect)
            height=rect(SimBiology.web.diagram.OccupancyMap.BOTTOM)-rect(SimBiology.web.diagram.OccupancyMap.TOP);
        end

        function flag=fitsVertical(newRect,rect)
            if~isempty(rect)
                flag=SimBiology.web.diagram.OccupancyMap.getHeight(rect)>=SimBiology.web.diagram.OccupancyMap.getHeight(newRect);
            else
                flag=false;
            end
        end

        function flag=fitsHorizontal(newRect,rect)
            if~isempty(rect)
                flag=SimBiology.web.diagram.OccupancyMap.getWidth(rect)>=SimBiology.web.diagram.OccupancyMap.getWidth(newRect);
            else
                flag=false;
            end
        end

        function flag=isVerticallyAdjacent(adjacencies)
            flag=(abs(adjacencies)==SimBiology.web.diagram.OccupancyMap.VERT);
        end

        function flag=isHorizontallyAdjacent(adjacencies)
            flag=(abs(adjacencies)==SimBiology.web.diagram.OccupancyMap.HORIZ);
        end

        function idx=findVerticallyAdjacentRectangleIndices(adjacencies,excludedIndices)
            idx=SimBiology.web.diagram.OccupancyMap.isVerticallyAdjacent(adjacencies);
            idx(excludedIndices)=false;
        end

        function idx=findHorizontallyAdjacentRectangleIndices(adjacencies,excludedIndices)
            idx=SimBiology.web.diagram.OccupancyMap.isHorizontallyAdjacent(adjacencies);
            idx(excludedIndices)=false;
        end
    end
end