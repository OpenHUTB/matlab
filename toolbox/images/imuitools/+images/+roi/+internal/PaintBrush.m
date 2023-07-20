classdef PaintBrush<handle&matlab.mixin.SetGet




    events

DrawingStarted

DrawingFinished

MaskEdited

DeletingROI

    end

    properties(Dependent)


Color



Erase


EraseColor


BrushSize


Mask


UserData


Parent


OutlineVisible


Superpixels

    end

    properties

        ImageSize(1,2)=[1,1];

    end

    properties(Access=private)

        ColorInternal(1,3)double=[0.5,0.5,0.5];
        EraseInternal(1,1)logical=false;
        EraseColorInternal(1,3)double=[1,1,1];
        BrushSizeInternal(1,1)double=101;
        MaskInternal logical=logical.empty;
        UserDataInternal=[];
        OutlineVisibleInternal(1,1)logical=false;
ParentInternal
        SuperpixelsInternal(:,:)double=[];
        UserIsDrawing(1,1)logical=false;

FigureHandle

ButtonDownEvt
ButtonMotionEvt
ButtonUpEvt
EmptyCallbackHandle

        Indices=[];
        PatchColor(1,3)double

        LastPoint=[];

        Points=[];
        ConnectivityList=[];
        Neighborhood logical
Boundary
        Patches matlab.graphics.primitive.Patch

        Outline matlab.graphics.primitive.Line
OutlineListener

    end

    methods




        function self=PaintBrush()

            performTriangulation(self);

        end




        function add(self,pixels)

            if~isempty(self.SuperpixelsInternal)
                mask=ismember(self.SuperpixelsInternal,self.SuperpixelsInternal(pixels));
            else
                mask=false([self.ImageSize(1),self.ImageSize(2)]);
                mask(pixels)=true;
                mask=imdilate(mask,self.Neighborhood,'same');
            end

            if isempty(self.MaskInternal)
                self.MaskInternal=mask;
            else
                self.MaskInternal=self.MaskInternal|mask;
            end
            notify(self,'MaskEdited');

        end




        function remove(self,pixels)

            mask=false([self.ImageSize(1),self.ImageSize(2)]);
            if isempty(self.MaskInternal)
                self.MaskInternal=mask;
            end

            if~isempty(self.SuperpixelsInternal)
                mask=ismember(self.SuperpixelsInternal,self.SuperpixelsInternal(pixels));
            else
                mask(pixels)=true;
                mask=imdilate(mask,self.Neighborhood,'same');
            end
            self.MaskInternal=self.MaskInternal&~mask;
            notify(self,'MaskEdited');

        end




        function draw(self)

            prepareToDraw(self);
            self.ButtonDownEvt=event.listener(self.FigureHandle,...
            'WindowMousePress',@(~,~)wireUpListeners(self));
            notify(self,'DrawingStarted');
            uiwait(self.FigureHandle);

        end




        function beginDrawing(self)

            prepareToDraw(self);
            wireUpListeners(self);
            notify(self,'DrawingStarted');
            uiwait(self.FigureHandle);

        end




        function clear(self)

            delete(self.Patches);
            self.Patches=matlab.graphics.primitive.Patch.empty;
            self.MaskInternal=logical.empty;

        end




        function delete(self)

            notify(self,'DeletingROI');
            self.MaskInternal=logical.empty;
            delete(self.ButtonDownEvt);
            delete(self.ButtonMotionEvt);
            delete(self.ButtonUpEvt);
            delete(self.OutlineListener);

        end

    end


    methods(Access=protected)


        function move(self)

            clickPos=round(getCurrentAxesPoint(self));

            if~isInBounds(self,clickPos(1),clickPos(2))
                self.LastPoint=[];
                return;
            end

            if~isempty(self.LastPoint)


                lastClickPos=self.LastPoint;
                numInterp=round(max(abs(clickPos-lastClickPos))+1);
                interpPos(:,1)=round(linspace(lastClickPos(1),clickPos(1),numInterp));
                interpPos(:,2)=round(linspace(lastClickPos(2),clickPos(2),numInterp));

                addPatch(self,interpPos);

            else
                addPatch(self,clickPos);
            end

            self.LastPoint=clickPos;
        end


        function stop(self)

            self.Indices=unique(self.Indices);

            if~self.Erase
                self.add(self.Indices)
            else
                self.remove(self.Indices)
            end

            self.Indices=[];
            self.LastPoint=[];

            self.endInteractivePlacement();
        end


        function addPatch(self,clickPos)

            try
                ind=sub2ind(self.ImageSize(1:2),clickPos(:,2),clickPos(:,1));
                self.Indices=[self.Indices,ind'];

                if~isempty(self.SuperpixelsInternal)

                    mask=ismember(self.SuperpixelsInternal,self.SuperpixelsInternal(ind));
                    pos=images.internal.builtins.bwborders(double(mask),4);

                    poly=polyshape(fliplr(pos{1}),'Simplify',false);
                    tri=triangulation(poly);

                    p=patch('Parent',self.Parent,'HitTest','off','HandleVisibility','off',...
                    'PickableParts','none',...
                    'FaceColor',self.PatchColor,'EdgeColor','none','Faces',tri.ConnectivityList,...
                    'Vertices',tri.Points);

                elseif self.BrushSize>1





                    mask=false(self.ImageSize(1:2));
                    mask(ind)=true;
                    mask=imdilate(mask,self.Neighborhood,'same');
                    pos=images.internal.builtins.bwborders(double(mask),4);

                    poly=polyshape(fliplr(pos{1}),'Simplify',false);
                    tri=triangulation(poly);

                    p=patch('Parent',self.Parent,'HitTest','off','HandleVisibility','off',...
                    'PickableParts','none',...
                    'FaceColor',self.PatchColor,'EdgeColor','none','Faces',tri.ConnectivityList,...
                    'Vertices',tri.Points);

                else



                    n=size(clickPos,1);
                    offset=round((self.BrushSize-1)/2)+0.5;

                    offsetMat=[-offset,-offset;
                    +offset,-offset;
                    +offset,+offset;
                    -offset,+offset];

                    offsetMat=repmat(offsetMat,[n,1]);

                    patchVerts=imresize(clickPos,[4*n,2],'nearest')+offsetMat;
                    patchFaces=reshape((1:4*n),[4,n])';

                    p=patch('Parent',self.Parent,'HitTest','off','HandleVisibility','off',...
                    'PickableParts','none',...
                    'FaceColor',self.PatchColor,'EdgeColor','none','Faces',patchFaces,...
                    'Vertices',patchVerts);

                end

                self.Patches=[self.Patches,p];

            catch

            end

        end


        function wireUpListeners(self)

            prepareToDraw(self);

            delete(self.ButtonDownEvt);


            self.EmptyCallbackHandle=@(~,~)self.emptyCallback();

            if isempty(self.FigureHandle.WindowButtonMotionFcn)
                self.FigureHandle.WindowButtonMotionFcn=self.EmptyCallbackHandle;
            end

            performTriangulation(self);

            self.ButtonMotionEvt=event.listener(self.FigureHandle,...
            'WindowMouseMotion',@(~,~)move(self));


            self.ButtonUpEvt=event.listener(self.FigureHandle,...
            'WindowMouseRelease',@(~,~)stop(self));


            move(self);
        end


        function wireUpOutline(self)

            if isempty(self.Parent)
                return;
            end

            self.FigureHandle=ancestor(self.Parent,'figure');

            if self.OutlineVisibleInternal

                if self.Erase
                    color=self.EraseColorInternal;
                else
                    color=self.ColorInternal;
                end

                if isempty(self.Outline)
                    self.Outline=line(NaN,NaN,'Parent',self.Parent,...
                    'PickableParts','none','HitTest','off','HandleVisibility','off','Color',color);
                else
                    set(self.Outline,'Color',color);
                end

                if isempty(self.OutlineListener)
                    self.OutlineListener=event.listener(self.FigureHandle,...
                    'WindowMouseMotion',@(~,~)updateOutline(self));
                else
                    self.OutlineListener.Enabled=true;
                end


                self.EmptyCallbackHandle=@(~,~)self.emptyCallback();

                if isempty(self.FigureHandle.WindowButtonMotionFcn)
                    self.FigureHandle.WindowButtonMotionFcn=self.EmptyCallbackHandle;
                end

            elseif~isempty(self.OutlineListener)
                self.OutlineListener.Enabled=false;
                set(self.Outline,'XData',NaN,'YDAta',NaN);
            end

        end


        function updateColor(self)

            if self.Erase
                color=self.EraseColorInternal;
            else
                color=self.ColorInternal;
            end

            if~isempty(self.Outline)
                set(self.Outline,'Color',color);
            end

        end


        function updateOutline(self)

            clickPos=round(getCurrentAxesPoint(self));

            if isInBounds(self,clickPos(1),clickPos(2))&&~isModeManagerActive(self)
                if~isempty(self.SuperpixelsInternal)
                    if self.UserIsDrawing
                        set(self.Outline,'XData',NaN,'YData',NaN);
                    else
                        superpixelTriangulation(self);
                        set(self.Outline,'XData',self.Boundary(:,1),'YData',self.Boundary(:,2));
                    end
                else
                    set(self.Outline,'XData',self.Boundary(:,1)+clickPos(1),'YData',self.Boundary(:,2)+clickPos(2));
                end
            else
                set(self.Outline,'XData',NaN,'YData',NaN);
            end

        end


        function prepareToDraw(self)


            self.Indices=[];
            self.LastPoint=[];
            delete(self.Patches);
            self.Patches=matlab.graphics.primitive.Patch.empty;

            if~self.Erase
                self.PatchColor=self.ColorInternal;
            else
                self.PatchColor=self.EraseColorInternal;
            end

            self.UserIsDrawing=true;

            prop=isprop(self.FigureHandle,'ModeManager');

            if~isempty(prop)&&prop&&...
                ~isempty(self.FigureHandle.ModeManager.CurrentMode)
                self.FigureHandle.ModeManager.CurrentMode=[];
            end

        end


        function endInteractivePlacement(self)

            delete(self.ButtonMotionEvt);
            delete(self.ButtonUpEvt);
            self.UserIsDrawing=false;
            uiresume(self.FigureHandle);
            notify(self,'DrawingFinished')

        end


        function performTriangulation(self)

            if~isempty(self.SuperpixelsInternal)
                return;
            end

            mask=false([self.BrushSize,self.BrushSize]);
            mask(ceil(self.BrushSize/2),ceil(self.BrushSize/2))=true;
            self.Neighborhood=bwdist(mask)<self.BrushSize/2;

            if self.BrushSize>1
                poscell=images.internal.builtins.bwborders(double(self.Neighborhood),4);
                pos=poscell{1};
                self.Boundary=pos-ceil(self.BrushSize/2);
            else
                self.Boundary=[-0.5,-0.5;0.5,-0.5;0.5,0.5;-0.5,0.5;-0.5,-0.5];
            end

            poly=polyshape(self.Boundary,'Simplify',false);
            tri=triangulation(poly);

            self.Points=tri.Points;
            self.ConnectivityList=tri.ConnectivityList;

        end


        function superpixelTriangulation(self)

            clickPos=round(getCurrentAxesPoint(self));
            ind=sub2ind(self.ImageSize(1:2),clickPos(:,2),clickPos(:,1));
            mask=ismember(self.SuperpixelsInternal,self.SuperpixelsInternal(ind));
            pos=images.internal.builtins.bwborders(double(mask),4);
            self.Boundary=fliplr(pos{1});

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

    end


    methods





        function set.Mask(self,mask)
            assert(isequal(size(mask),[self.ImageSize(1),self.ImageSize(2)]),'Mask must match first two dimensions of image size');
            self.MaskInternal=logical(mask);
        end

        function pos=get.Mask(self)
            pos=self.MaskInternal;
        end




        function set.Color(self,color)
            self.ColorInternal=color;
            updateColor(self);
        end

        function color=get.Color(self)
            color=self.ColorInternal;
        end




        function set.Erase(self,TF)
            self.EraseInternal=TF;
            updateColor(self);
        end

        function TF=get.Erase(self)
            TF=self.EraseInternal;
        end




        function set.EraseColor(self,color)
            self.EraseColorInternal=color;
        end

        function color=get.EraseColor(self)
            color=self.EraseColorInternal;
        end




        function set.BrushSize(self,val)
            val=round(val);
            if val>=1

                if mod(val,2)==0
                    val=round(val+1);
                end
                self.BrushSizeInternal=val;
                performTriangulation(self);
            end
        end

        function val=get.BrushSize(self)
            val=self.BrushSizeInternal;
        end




        function set.UserData(self,data)
            self.UserDataInternal=data;
        end

        function data=get.UserData(self)
            data=self.UserDataInternal;
        end




        function set.Parent(self,ax)
            self.ParentInternal=ax;
            wireUpOutline(self);
        end

        function ax=get.Parent(self)
            ax=self.ParentInternal;
        end




        function set.OutlineVisible(self,TF)
            self.OutlineVisibleInternal=TF;
            wireUpOutline(self);
        end

        function TF=get.OutlineVisible(self)
            TF=self.OutlineVisibleInternal;
        end




        function set.Superpixels(self,L)
            self.SuperpixelsInternal=L;
            if isempty(self.SuperpixelsInternal)
                performTriangulation(self);
            end
            updateOutline(self);
        end

        function L=get.Superpixels(self)
            L=self.SuperpixelsInternal;
        end

    end


    methods(Static,Hidden,Access=protected)


        function emptyCallback(varargin)

















        end

    end


end