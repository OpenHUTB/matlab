classdef CalloutsLayoutManager<handle
    properties
        LayoutRect;
        OccupiedRects={};
    end

    properties(SetAccess=private)
        HasSpaceLeft=true;
    end

    properties(Constant,GetAccess=private)
        StepSize=5;
    end

    methods
        function this=CalloutsLayoutManager(layoutRect)
            this.LayoutRect=layoutRect;
        end

        function targetPoint=getTargetPoint(this,calloutRect,targetRect)
            calloutPoint=calloutRect(1:2)-calloutRect(3:4)/2;

            dst=[...
            (targetRect(1)+targetRect(3)/2),targetRect(2);...
            targetRect(1),(targetRect(2)+targetRect(4)/2);...
            (targetRect(1)+targetRect(3)/2),(targetRect(2)+targetRect(4));...
            (targetRect(1)+targetRect(3)),(targetRect(2)+targetRect(4)/2)];
            src=repmat(calloutPoint,size(dst,1),1);
            [~,targetPoint]=this.findMinDistancePoint(src,dst);
        end

        function calloutRect=getCalloutRect(this,labelSize,targetRect)
            targetCenter=[(targetRect(1)+targetRect(3)/2)...
            ,(targetRect(2)+targetRect(4)/2)];

            idealRect=this.getIdealRect(labelSize,targetCenter);




            if this.isOccupied(idealRect)
                clockWiseRect=this.getNextRect(1,idealRect);
                cClockWiseRect=this.getNextRect(-1,idealRect);

                if(~isempty(clockWiseRect)&&~isempty(cClockWiseRect))
                    minPoint=this.findMinDistancePoint(...
                    [clockWiseRect(1:2);...
                    cClockWiseRect(1:2)],...
                    [targetCenter;...
                    targetCenter]);
                    calloutRect=[minPoint,labelSize];

                elseif isempty(clockWiseRect)
                    calloutRect=cClockWiseRect;

                elseif isempty(cClockWiseRect)
                    calloutRect=clockWiseRect;

                else
                    this.HasSpaceLeft=false;
                    calloutRect=[];
                end

            else
                calloutRect=idealRect;
            end

            this.addOccupied(calloutRect);
        end
    end

    methods(Access=private)
        function idealRect=getIdealRect(this,labelSize,targetPoint)
            layoutRect=this.LayoutRect;

            src=[targetPoint(1),layoutRect(2);...
            layoutRect(1),targetPoint(2);...
            targetPoint(1),layoutRect(2)+layoutRect(4);...
            layoutRect(1)+layoutRect(3),targetPoint(2)];

            dst=repmat(targetPoint,size(src,1),1);

            minPoint=this.findMinDistancePoint(src,dst);

            idealRect=[minPoint-labelSize/2,labelSize];
        end

        function nextRect=getNextRect(this,direction,startRect)
            nextRect=startRect;

            allSidesVisited=false;
            leftSideVisited=false;
            topSideVisited=false;
            rightSideVisited=false;
            bottomSideVisited=false;

            while(this.isOccupied(nextRect)&&~allSidesVisited)
                if this.onTopSide(nextRect)
                    nextRect=this.getNextRectOnTopSide(direction,nextRect);
                    topSideVisited=true;

                elseif this.onLeftSide(nextRect)
                    nextRect=this.getNextRectOnLeftSide(direction,nextRect);
                    leftSideVisited=true;

                elseif this.onRightSide(nextRect)
                    nextRect=this.getNextRectOnRightSide(direction,nextRect);
                    rightSideVisited=true;

                elseif this.onBottomSide(nextRect)
                    nextRect=this.getNextRectOnBottomSide(direction,nextRect);
                    bottomSideVisited=true;
                else
                    topSideVisited=true;
                    leftSideVisited=true;
                    rightSideVisited=true;
                    bottomSideVisited=true;
                end

                allSidesVisited=leftSideVisited&&topSideVisited...
                &&rightSideVisited&&bottomSideVisited;
            end

            if this.isOccupied(nextRect)
                nextRect=[];
            end
        end

        function tf=isOccupied(this,rect)
            tf=false;
            for i=1:length(this.OccupiedRects)
                if this.isIntersectingRect(this.OccupiedRects{i},rect)
                    tf=true;
                    return;
                end
            end
        end

        function addOccupied(this,rect)
            if~isempty(rect)
                this.OccupiedRects{end+1}=rect;
            end
        end

        function nextRect=getNextRectOnTopSide(this,direction,startRect)
            increment=direction*this.StepSize;

            nextRect=startRect+[increment,0,0,0];
            while(this.isOccupied(nextRect)&&this.onTopSide(nextRect))
                nextRect=nextRect+[increment,0,0,0];
            end

            if~this.onTopSide(nextRect)

                layoutRect=this.LayoutRect;
                if direction==1

                    nextPoint=[layoutRect(1)+layoutRect(3),layoutRect(2)];
                else

                    nextPoint=layoutRect(1:2);
                end
                nextRect=[nextPoint-startRect(3:4)/2,startRect(3:4)];
            end
        end

        function nextRect=getNextRectOnLeftSide(this,direction,startRect)
            increment=direction*this.StepSize;
            nextRect=startRect+[0,-increment,0,0];
            while(this.isOccupied(nextRect)&&this.onLeftSide(nextRect))
                nextRect=nextRect+[0,-increment,0,0];
            end

            if~this.onLeftSide(nextRect)

                layoutRect=this.LayoutRect;
                if direction==1

                    nextPoint=[layoutRect(1)+1,layoutRect(2)];
                else

                    nextPoint=[layoutRect(1)+1,layoutRect(2)+layoutRect(4)];
                end
                nextRect=[nextPoint-startRect(3:4)/2,startRect(3:4)];
            end
        end

        function nextRect=getNextRectOnRightSide(this,direction,startRect)
            increment=direction*this.StepSize;
            nextRect=startRect+[0,increment,0,0];
            while(this.isOccupied(nextRect)&&this.onRightSide(nextRect))
                nextRect=nextRect+[0,increment,0,0];
            end

            if~this.onRightSide(nextRect)

                layoutRect=this.LayoutRect;
                if direction==1

                    nextPoint=[layoutRect(1)+layoutRect(3)-1,layoutRect(2)+layoutRect(4)];
                else

                    nextPoint=[layoutRect(1)+layoutRect(3)-1,layoutRect(2)];
                end
                nextRect=[nextPoint-startRect(3:4)/2,startRect(3:4)];
            end
        end

        function nextRect=getNextRectOnBottomSide(this,direction,startRect)
            increment=direction*this.StepSize;
            nextRect=startRect+[-increment,0,0,0];
            while(this.isOccupied(nextRect)&&this.onBottomSide(nextRect))
                nextRect=nextRect+[-increment,0,0,0];
            end

            if~this.onBottomSide(nextRect)

                layoutRect=this.LayoutRect;
                if direction==1

                    nextPoint=[layoutRect(1),layoutRect(2)+layoutRect(4)];
                else

                    nextPoint=[layoutRect(1)+layoutRect(3),layoutRect(2)+layoutRect(4)];
                end
                nextRect=[nextPoint-startRect(3:4)/2,startRect(3:4)];
            end
        end

        function tf=onLeftSide(this,rect)
            cpoint=rect(1:2)+rect(3:4)/2;
            lrect=this.LayoutRect;
            tf=(cpoint(1)==lrect(1))...
            &&(cpoint(2)>=lrect(2))...
            &&(cpoint(2)<=(lrect(2)+lrect(4)));
        end

        function tf=onTopSide(this,rect)
            cpoint=rect(1:2)+rect(3:4)/2;
            lrect=this.LayoutRect;
            tf=(cpoint(2)==lrect(2))...
            &&(cpoint(1)>lrect(1))...
            &&(cpoint(1)<(lrect(1)+lrect(3)));
        end

        function tf=onRightSide(this,rect)
            cpoint=rect(1:2)+rect(3:4)/2;
            lrect=this.LayoutRect;
            tf=(cpoint(1)==(lrect(1)+lrect(3)))...
            &&(cpoint(2)>=lrect(2))...
            &&(cpoint(2)<=(lrect(2)+lrect(4)));
        end

        function tf=onBottomSide(this,rect)
            cpoint=rect(1:2)+rect(3:4)/2;
            lrect=this.LayoutRect;
            tf=(cpoint(2)==(lrect(2)+lrect(4)))...
            &&(cpoint(1)>lrect(1))...
            &&(cpoint(1)<(lrect(1)+lrect(3)));
        end

    end

    methods(Static,Access=private)
        function tf=isIntersectingRect(rect1,rect2)
            x1min=rect1(1);
            x1max=rect1(1)+rect1(3);
            x2min=rect2(1);
            x2max=rect2(1)+rect2(3);

            xImin=max(x1min,x2min);
            xImax=min(x1max,x2max);

            if(xImin<=xImax)

                y1min=rect1(2);
                y1max=rect1(2)+rect1(4);
                y2min=rect2(2);
                y2max=rect2(2)+rect2(4);

                yImin=max(y1min,y2min);
                yImax=min(y1max,y2max);


                tf=(yImin<=yImax);
            else
                tf=false;
            end
        end

        function[minPts1,minPts2]=findMinDistancePoint(pts1,pts2)
            dist=sqrt(sum((pts1-pts2).^2,2));
            [~,I]=min(dist);
            minPts1=pts1(I,:);
            minPts2=pts2(I,:);
        end
    end

end