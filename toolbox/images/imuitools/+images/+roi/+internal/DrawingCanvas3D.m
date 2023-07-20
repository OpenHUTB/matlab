classdef(Abstract)DrawingCanvas3D<images.roi.internal.DrawingCanvas






    properties(Hidden,Transient,Access=protected)
        SnapPoints=[];
    end

    methods(Sealed,Hidden,Access=protected)





        function clickPos=getCurrentAxesPoint(self)






            hAx=ancestor(self,'axes');
            cP=hAx.CurrentPoint;




            clickPos=cP(1,:);
        end


        function clickPos=getPointsInAndOutOfAxes(self)
            hAx=ancestor(self,'axes');
            clickPos=hAx.CurrentPoint;
        end


        function setDragBoundary(self,currentPoint,x,y,z)




            xMin=max(min(x)-self.PositionConstraint(1),0);
            xMax=max(self.PositionConstraint(2)-max(x),0);
            yMin=max(min(y)-self.PositionConstraint(3),0);
            yMax=max(self.PositionConstraint(4)-max(y),0);
            zMin=max(min(z)-self.PositionConstraint(5),0);
            zMax=max(self.PositionConstraint(6)-max(z),0);


            self.DragConstraint=[currentPoint(1)-xMin,currentPoint(1)+xMax,...
            currentPoint(2)-yMin,currentPoint(2)+yMax,...
            currentPoint(3)-zMin,currentPoint(3)+zMax];

        end


        function constrainedPos=getConstrainedPosition(self,pos)
            constrainedPos=[min(max(pos(1),self.PositionConstraint(1)),self.PositionConstraint(2)),...
            min(max(pos(2),self.PositionConstraint(3)),self.PositionConstraint(4)),...
            min(max(pos(3),self.PositionConstraint(5)),self.PositionConstraint(6))];
        end


        function constrainedPos=getConstrainedDragPosition(self,pos)
            constrainedPos=[min(max(pos(1),self.DragConstraint(1)),self.DragConstraint(2)),...
            min(max(pos(2),self.DragConstraint(3)),self.DragConstraint(4)),...
            min(max(pos(3),self.DragConstraint(5)),self.DragConstraint(6))];
        end


        function TF=isCandidatePositionInsideConstraint(self,pos)

            if~self.ConstrainedInternal
                TF=true;
                return;
            end

            TF=all(pos(:,1)>=self.PositionConstraint(1))&&...
            all(pos(:,1)<=self.PositionConstraint(2))&&...
            all(pos(:,2)>=self.PositionConstraint(3))&&...
            all(pos(:,2)<=self.PositionConstraint(4))&&...
            all(pos(:,3)>=self.PositionConstraint(5))&&...
            all(pos(:,3)<=self.PositionConstraint(6));

        end


        function setConstraintLimits(self,x,y,z)

            if self.ConstrainedInternal
                if isempty(self.DrawingAreaInternal)


                    hAx=ancestor(self,'axes');

                    if isempty(x)
                        xLim=hAx.XLim;
                        yLim=hAx.YLim;
                        zLim=hAx.ZLim;
                    else
                        xLim=[min(hAx.XLim(1),min(x)),max(hAx.XLim(2),max(x))];
                        yLim=[min(hAx.YLim(1),min(y)),max(hAx.YLim(2),max(y))];
                        zLim=[min(hAx.ZLim(1),min(z)),max(hAx.ZLim(2),max(z))];
                    end
                else

                    xLim=[self.DrawingAreaInternal(1),self.DrawingAreaInternal(1)+self.DrawingAreaInternal(4)];
                    yLim=[self.DrawingAreaInternal(2),self.DrawingAreaInternal(2)+self.DrawingAreaInternal(5)];
                    zLim=[self.DrawingAreaInternal(3),self.DrawingAreaInternal(3)+self.DrawingAreaInternal(6)];
                end
                self.PositionConstraint=[xLim(1),xLim(2),yLim(1),yLim(2),zLim(1),zLim(2)];
            else

                self.PositionConstraint=[-Inf,Inf,-Inf,Inf,-Inf,Inf];
            end

        end


        function setDrawingCanvas(self,bbox)



            if ischar(bbox)||isstring(bbox)

                validStr=validatestring(bbox,{'auto','unlimited'});

                switch validStr
                case 'auto'
                    self.ConstrainedInternal=true;
                    self.DrawingAreaInternal=[];
                case 'unlimited'
                    self.ConstrainedInternal=false;
                otherwise
                    error(message('images:imroi:invalidDrawingAreaInput'));
                end

            else
                validateattributes(bbox,{'numeric'},...
                {'nonempty','real','size',[1,6],'finite','nonsparse'},...
                mfilename,'DrawingArea');

                if bbox(4)<0||bbox(5)<0||bbox(6)<0
                    error(message('images:imroi:invalidLimits'));
                end

                self.ConstrainedInternal=true;
                self.DrawingAreaInternal=bbox;
            end

        end


        function setSnapPoints(self,varargin)


            if isempty(varargin)
                self.SnapPoints=[];
                return;
            end

            hPoints=varargin{1};


            if isa(hPoints,'matlab.graphics.chart.primitive.Scatter')
                if isempty(hPoints.ZData)

                    hPoints=[hPoints.XData',hPoints.YData',zeros(size(hPoints.XData),'like',hPoints.XData)'];
                else

                    hPoints=[hPoints.XData',hPoints.YData',hPoints.ZData'];
                end
            end

            validateattributes(hPoints,{'numeric'},{'real','nonsparse'});


            if~isa(hPoints,'double')
                hPoints=single(hPoints);
            end




            hPoints(any(~isfinite(hPoints),2),:)=[];



            self.SnapPoints=hPoints;

        end


        function pos=findNearestSnapPoint(self,clickPos)

            if isvector(clickPos)


                if isempty(self.SnapPoints)
                    pos=clickPos;
                else
                    [~,idx]=min(sqrt(sum((self.SnapPoints-clickPos).^2,2)));
                    pos=self.SnapPoints(idx,:);
                end

            else




                if isempty(self.SnapPoints)
                    pos=mean(clickPos);
                else

                    frontPoint=clickPos(1,:);
                    backPoint=clickPos(2,:);



                    diff1=frontPoint-backPoint;
                    diff1=repmat(diff1,size(self.SnapPoints,1),1);
                    diff2=self.SnapPoints-backPoint;

                    crossP=cross(diff1,diff2);
                    numerator=sqrt(sum((crossP.^2),2));
                    denom=sqrt(sum((diff1.^2),2));

                    d=numerator./denom;

                    hAx=ancestor(self,'axes');
                    minLimit=min([hAx.XLim(1),hAx.YLim(1),hAx.ZLim(1)]);
                    maxLimit=max([hAx.XLim(2),hAx.YLim(2),hAx.ZLim(2)]);

                    distanceThreshold=2.5*(maxLimit-minLimit)/100;

                    withinDataLimits=min(d)<distanceThreshold;

                    if withinDataLimits





                        [~,I]=sort(d);

                        if numel(I)>5
                            top5Idx=I(1:5);
                        else
                            top5Idx=I;
                        end
                        top5Points=self.SnapPoints(top5Idx,:);


                        [~,idx]=min(sqrt(sum((top5Points-frontPoint).^2,2)));
                        pos=self.SnapPoints(I(idx),:);

                    else


                        [~,idx]=min(d);
                        pos=self.SnapPoints(idx,:);
                    end

                end

            end

        end

    end

end