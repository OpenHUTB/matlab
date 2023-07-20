classdef LevelTracing<handle&matlab.mixin.SetGet




    events

DrawingStarted

MaskReady

DeletingROI

OutlineRefreshed

    end

    properties(Dependent)


Mask


Color


Image
ImageSize


UserData


Parent


Tolerance


Connectivity


Neighborhood

    end

    properties(Access=private)

        OutlineColorInternal(1,3)double=[1,1,0];
        OutlineWidthInternal(1,1)double=1.0;

ImageInternal
        MaskInternal logical=logical.empty;
        UserDataInternal=[];
ParentInternal
        ToleranceInternal(1,1)double
        ConnectivityInternal(1,1)double=8;
        NeighborhoodInternal(1,1)double=1;

FigureHandle

ButtonUpEvt
EmptyCallbackHandle

Boundary

        Outline matlab.graphics.primitive.Line
OutlineListener

    end

    methods




        function self=LevelTracing()

        end




        function beginDrawing(self)

            prepareToDraw(self);
            wireUpListeners(self);
            notify(self,'DrawingStarted');

        end




        function clear(self)

            self.MaskInternal=logical.empty;
            set(self.Outline,"XData",NaN,"YData",NaN);

        end




        function delete(self)

            notify(self,'DeletingROI');
            self.MaskInternal=logical.empty;
            delete(self.ButtonUpEvt);
            delete(self.OutlineListener);
            delete(self.Outline)

        end

    end


    methods(Access=protected)


        function move(self,evt)

            self.notify('OutlineRefreshed');

            if evt.HitObject.Parent~=self.Parent
                set(self.Outline,"XData",NaN,"YData",NaN);
                return
            end

            clickPos=round(getCurrentAxesPoint(self));

            if isInBounds(self,clickPos(1),clickPos(2))&&~isModeManagerActive(self)

                self.Boundary=self.levelTracingAlgo(clickPos(1),...
                clickPos(2),self.ToleranceInternal,...
                self.ConnectivityInternal,self.NeighborhoodInternal);

                if~isempty(self.Boundary)
                    set(self.Outline,"XData",self.Boundary{1}(:,2),...
                    "YData",self.Boundary{1}(:,1),...
                    "Color",self.OutlineColorInternal,...
                    "LineWidth",self.OutlineWidthInternal);
                end

            else
                set(self.Outline,"XData",NaN,"YData",NaN);
            end

            drawnow('limitrate')

        end


        function stop(self)

            clickPos=round(getCurrentAxesPoint(self));
            if isInBounds(self,clickPos(1),clickPos(2))&&~isModeManagerActive(self)

                self.Boundary=self.levelTracingAlgo(clickPos(1),...
                clickPos(2),self.ToleranceInternal,...
                self.ConnectivityInternal,self.NeighborhoodInternal);

                if~isempty(self.Boundary)

                    self.Mask=images.internal.builtins.poly2mask(self.Boundary{1,1}(:,2),...
                    self.Boundary{1,1}(:,1),uint32(self.ImageSize(1)),uint32(self.ImageSize(2)));
                end

                notify(self,'MaskReady');

            end

        end


        function wireUpListeners(self)

            if isempty(self.Parent)
                return;
            end

            self.FigureHandle=ancestor(self.Parent,'figure');

            color=self.OutlineColorInternal;

            if isempty(self.Outline)
                self.Outline=line(NaN,NaN,'Parent',self.Parent,...
                'PickableParts','none','HitTest','off',...
                'HandleVisibility','off','Color',color);
            else
                set(self.Outline,'Color',color);
            end

            if isempty(self.OutlineListener)
                self.OutlineListener=event.listener(self.FigureHandle,...
                'WindowMouseMotion',@(~,evt)move(self,evt));

                self.ButtonUpEvt=event.listener(self.FigureHandle,...
                'WindowMouseRelease',@(~,~)stop(self));

            else
                self.OutlineListener.Enabled=true;
                self.ButtonUpEvt.Enabled=true;
            end

            if isempty(self.FigureHandle.WindowButtonMotionFcn)

                self.FigureHandle.WindowButtonMotionFcn=self.EmptyCallbackHandle;


                self.EmptyCallbackHandle=@(~,~)self.emptyCallback();
            end


        end


        function prepareToDraw(self)

            prop=isprop(self.FigureHandle,'ModeManager');

            if~isempty(prop)&&prop&&...
                ~isempty(self.FigureHandle.ModeManager.CurrentMode)
                self.FigureHandle.ModeManager.CurrentMode=[];
            end

        end


        function clickPos=getCurrentAxesPoint(self)

            cP=self.Parent.CurrentPoint;
            clickPos=[cP(1,1),cP(1,2)];

        end


        function TF=isInBounds(self,X,Y)

            XLim=self.Parent.XLim;
            YLim=self.Parent.YLim;
            TF=X>=XLim(1)&&X<=XLim(2)&&Y>=YLim(1)&&Y<=YLim(2);

        end


        function TF=isModeManagerActive(self)

            TF=imageslib.internal.app.utilities.isAxesInteractionModeActive(...
            ancestor(self,"axes"),ancestor(self,"figure"));
        end


        function boundary=levelTracingAlgo(self,seedpointC,seedpointR,tolerance,conn,nHood)



            mask=self.grayconnectedAlgo(double(seedpointR),...
            double(seedpointC),double(tolerance),conn,nHood);


            [boundary,~]=bwboundaries(mask,"noholes");

        end


        function bw=grayconnectedAlgo(self,r,c,tolerance,conn,nHood)

            X=self.ImageInternal;

            if nHood==3
                pixelLocation=[r,c];
                sz=self.ImageSize;
                idxY=max(pixelLocation(1)-1,1):min(pixelLocation(1)+1,sz(1));
                idxX=max(pixelLocation(2)-1,1):min(pixelLocation(2)+1,sz(2));
                nHoodMembers=X(idxY,idxX);
                value=mean(nHoodMembers(:));
            elseif nHood==5
                pixelLocation=[r,c];
                sz=self.ImageSize;
                idxY=max(pixelLocation(1)-2,1):min(pixelLocation(1)+2,sz(1));
                idxX=max(pixelLocation(2)-2,1):min(pixelLocation(2)+2,sz(2));
                nHoodMembers=X(idxY,idxX);
                value=mean(nHoodMembers(:));
            else
                value=X(r,c);
            end

            minWindow=value-tolerance;
            maxWindow=value+tolerance;

            similarValuesImage=(X>=minWindow)&(X<=maxWindow);
            bw=bwselect(similarValuesImage,c,r,conn);

        end

    end


    methods





        function set.Mask(self,mask)

            assert(isequal(size(mask),[self.ImageSize(1),self.ImageSize(2)]),...
            'Mask must match first two dimensions of image size');
            self.MaskInternal=logical(mask);

        end

        function pos=get.Mask(self)

            pos=self.MaskInternal;

        end




        function set.UserData(self,data)

            self.UserDataInternal=data;

        end

        function data=get.UserData(self)

            data=self.UserDataInternal;

        end




        function set.Parent(self,ax)

            self.ParentInternal=ax;
            wireUpListeners(self);

        end

        function ax=get.Parent(self)

            ax=self.ParentInternal;

        end




        function set.Tolerance(self,value)

            self.ToleranceInternal=value;

        end

        function value=get.Tolerance(self)

            value=self.ToleranceInternal;

        end




        function set.Connectivity(self,value)

            self.ConnectivityInternal=value;

        end

        function value=get.Connectivity(self)

            value=self.ConnectivityInternal;

        end




        function set.Neighborhood(self,value)

            self.NeighborhoodInternal=value;

        end

        function value=get.Neighborhood(self)

            value=self.NeighborhoodInternal;

        end




        function set.Color(self,value)

            self.OutlineColorInternal=value;

        end

        function value=get.Color(self)

            value=self.OutlineColorInternal;

        end




        function set.Image(self,value)

            self.ImageInternal=value;

        end

        function value=get.Image(self)

            value=self.ImageInternal;

        end




        function value=get.ImageSize(self)

            value=[1,1];
            if~isempty(self.ImageInternal)
                value=size(self.ImageInternal,[1,2]);
            end

        end


    end


    methods(Static,Hidden,Access=protected)


        function emptyCallback(varargin)

















        end

    end


end
