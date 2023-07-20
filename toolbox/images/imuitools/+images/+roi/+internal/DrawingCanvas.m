classdef(Abstract)DrawingCanvas<handle







    properties(Dependent)













DrawingArea

    end

    properties(Hidden,Access=protected)
        DrawingAreaInternal=[];
        ConstrainedInternal(1,1)logical=true;
    end

    properties(Transient,NonCopyable=true,Hidden,Access=protected)




PositionConstraint




DragConstraint

    end

    methods(Hidden,Access=protected)



        function clickPos=getCurrentAxesPoint(self)






            hAx=ancestor(self,{'axes','geoaxes'});
            cP=hAx.CurrentPoint;





            clickPos=[cP(2,1),cP(2,2)];


        end


        function setDragBoundary(self,currentPoint,x,y,~)




            xMin=max(min(x)-self.PositionConstraint(1),0);
            xMax=max(self.PositionConstraint(2)-max(x),0);
            yMin=max(min(y)-self.PositionConstraint(3),0);
            yMax=max(self.PositionConstraint(4)-max(y),0);


            self.DragConstraint=[currentPoint(1)-xMin,currentPoint(1)+xMax,...
            currentPoint(2)-yMin,currentPoint(2)+yMax];

        end


        function constrainedPos=getConstrainedPosition(self,pos)
            constrainedPos=[min(max(pos(1),self.PositionConstraint(1)),self.PositionConstraint(2)),...
            min(max(pos(2),self.PositionConstraint(3)),self.PositionConstraint(4))];
        end


        function constrainedPos=getConstrainedDragPosition(self,pos)
            constrainedPos=[min(max(pos(1),self.DragConstraint(1)),self.DragConstraint(2)),...
            min(max(pos(2),self.DragConstraint(3)),self.DragConstraint(4))];
        end


        function TF=isCandidatePositionInsideConstraint(self,pos)


            if~self.ConstrainedInternal
                TF=true;
                return;
            end

            x=[self.PositionConstraint(1);self.PositionConstraint(1);...
            self.PositionConstraint(2);self.PositionConstraint(2);...
            self.PositionConstraint(1)];

            y=[self.PositionConstraint(3);...
            self.PositionConstraint(4);self.PositionConstraint(4);...
            self.PositionConstraint(3);self.PositionConstraint(3)];


            TF=all(images.internal.inpoly(pos(:,1),pos(:,2),x,y));

        end


        function setConstraintLimits(self,x,y,~)

            if self.ConstrainedInternal
                if isempty(self.DrawingAreaInternal)


                    hAx=ancestor(self,{'axes','geoaxes'});

                    if isa(hAx,'matlab.graphics.axis.GeographicAxes')

                        if isempty(x)
                            xLim=hAx.LatitudeLimits;
                            yLim=hAx.LongitudeLimits;
                        else
                            xLim=[min(hAx.LatitudeLimits(1),min(x)),max(hAx.LatitudeLimits(2),max(x))];
                            yLim=[min(hAx.LongitudeLimits(1),min(y)),max(hAx.LongitudeLimits(2),max(y))];
                        end

                    else

                        if isempty(x)
                            xLim=hAx.XLim;
                            yLim=hAx.YLim;
                        else
                            xLim=[min(hAx.XLim(1),min(x)),max(hAx.XLim(2),max(x))];
                            yLim=[min(hAx.YLim(1),min(y)),max(hAx.YLim(2),max(y))];
                        end

                    end

                else

                    xLim=[self.DrawingAreaInternal(1),self.DrawingAreaInternal(1)+self.DrawingAreaInternal(3)];
                    yLim=[self.DrawingAreaInternal(2),self.DrawingAreaInternal(2)+self.DrawingAreaInternal(4)];
                end
                self.PositionConstraint=[xLim(1),xLim(2),yLim(1),yLim(2)];
            else

                self.PositionConstraint=[-Inf,Inf,-Inf,Inf];
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
                {'nonempty','real','size',[1,4],'finite','nonsparse'},...
                mfilename,'DrawingArea');

                if bbox(3)<0||bbox(4)<0
                    error(message('images:imroi:invalidLimits'));
                end

                self.ConstrainedInternal=true;
                self.DrawingAreaInternal=bbox;
            end

        end

    end

    methods


        function set.DrawingArea(self,bbox)

            setDrawingCanvas(self,bbox);
        end

        function bbox=get.DrawingArea(self)
            if self.ConstrainedInternal
                if isempty(self.DrawingAreaInternal)
                    bbox='auto';
                else
                    bbox=self.DrawingAreaInternal;
                end
            else
                bbox='unlimited';
            end
        end

    end

end
