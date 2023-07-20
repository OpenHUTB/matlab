classdef Slice<handle&matlab.mixin.SetGet




    events

ImageClicked

ImageRotated

InteractionModeChanged

UpdateDatatip

BlockIndexShifted

    end


    properties

        Enabled(1,1)logical=false;

        Empty(1,1)logical=true;

    end


    properties(GetAccess={?uitest.factory.Tester,...
        ?images.uitest.factory.Tester,...
        ?images.internal.app.segmenter.volume.dialogs.RegionSelectorDialog,...
        ?medical.internal.app.home.labeler.display.Slice,...
        ?medical.internal.app.labeler.view.sliceView.Slice,...
        ?medical.internal.app.labeler.view.sliceView.ScrollableSliceView},...
        SetAccess=protected,Transient)

        Panel matlab.ui.container.Panel

        Image images.internal.app.utilities.Image

Thumbnail

Datatip

        DatatipListener event.listener

ColorIndicator

ModeIndicator

SliceIndicator

BlockToolbarButton

        Tag(1,1)string="SliceDisplay"
    end


    properties(Dependent,Hidden)

RotationState

Alpha

SuperpixelOverlay

ShowOverlay

PixelSize

    end


    properties(Dependent,SetAccess=protected,GetAccess={...
        ?images.internal.app.segmenter.volume.View,...
        ?images.internal.app.segmenter.volume.dialogs.RegionSelectorDialog,...
        ?medical.internal.app.labeler.view.sliceView.Slice,...
        ?images.uitest.factory.Tester,...
        ?uitest.factory.Tester})

ImageHandle

    end


    methods




        function self=Slice(hParent,pos)

            self.Panel=uipanel('Parent',hParent,...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'Position',pos,...
            'Tag','SlicePanel',...
            'AutoResizeChildren','off');

            self.Image=images.internal.app.utilities.Image(self.Panel);
            addlistener(self.Image,'ImageRotated',@(~,~)notify(self,'ImageRotated'));
            addlistener(self.Image,'ImageClicked',@(src,evt)notify(self,'ImageClicked',evt));
            addlistener(self.Image,'ViewChanged',@(~,~)setAxesPosition(self));
            addlistener(self.Image,'InteractionModeChanged',@(src,evt)notify(self,'InteractionModeChanged',evt));

            self.BlockToolbarButton=matlab.ui.controls.ToolbarDropdown(...
            'Tag','BlockDropdown','Visible','off');

            self.BlockToolbarButton.Icon=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','AxesDropdown.png');

            inButton=matlab.ui.controls.ToolbarPushButton(...
            'Tag','Down','Tooltip',getString(message('images:segmenter:inTooltip')),...
            'Parent',self.BlockToolbarButton,'ButtonPushedFcn',@(~,~)moveBlock(self,'in'));

            inButton.Icon=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','AxesMoveIn.png');

            outButton=matlab.ui.controls.ToolbarPushButton(...
            'Tag','Up','Tooltip',getString(message('images:segmenter:outTooltip')),...
            'Parent',self.BlockToolbarButton,'ButtonPushedFcn',@(~,~)moveBlock(self,'out'));

            outButton.Icon=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','AxesMoveOut.png');

            rightButton=matlab.ui.controls.ToolbarPushButton(...
            'Tag','Right','Tooltip',getString(message('images:segmenter:rightTooltip')),...
            'Parent',self.BlockToolbarButton,'ButtonPushedFcn',@(~,~)moveBlock(self,'right'));

            rightButton.Icon=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','AxesMoveRight.png');

            leftButton=matlab.ui.controls.ToolbarPushButton(...
            'Tag','Left','Tooltip',getString(message('images:segmenter:leftTooltip')),...
            'Parent',self.BlockToolbarButton,'ButtonPushedFcn',@(~,~)moveBlock(self,'left'));

            leftButton.Icon=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','AxesMoveLeft.png');

            downButton=matlab.ui.controls.ToolbarPushButton(...
            'Tag','Down','Tooltip',getString(message('images:segmenter:downTooltip')),...
            'Parent',self.BlockToolbarButton,'ButtonPushedFcn',@(~,~)moveBlock(self,'down'));

            downButton.Icon=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','AxesMoveDown.png');

            upButton=matlab.ui.controls.ToolbarPushButton(...
            'Tag','Up','Tooltip',getString(message('images:segmenter:upTooltip')),...
            'Parent',self.BlockToolbarButton,'ButtonPushedFcn',@(~,~)moveBlock(self,'up'));

            upButton.Icon=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','AxesMoveUp.png');

            set(self.BlockToolbarButton,'Parent',self.Image.AxesHandle.Toolbar);

            ax=axes(self.Panel,'Units','pixels','Position',[1,6,100,100]);
            self.Thumbnail=image(ones([100,100,3],'uint8')*240,'Parent',ax,...
            'Interpolation','nearest','HitTest','off','PickableParts','none','Visible','off');
            set(ax,'Box','on','XTick',[],'YTick',[],'Visible','off','Toolbar',[]);

            disableDefaultInteractivity(ax);

            if isa(getCanvas(self.Panel),'matlab.graphics.primitive.canvas.HTMLCanvas')

                self.ColorIndicator=uiimage('Parent',self.Panel,...
                'ScaleMethod','fill',...
                'Visible','off',...
                'Tag','ColorIndicator',...
                'ImageSource',zeros([20,20,3]));

                self.ModeIndicator=uiimage('Parent',self.Panel,...
                'Visible','off',...
                'Tag','ModeIndicator',...
                'ScaleMethod','fill');

                self.SliceIndicator=uilabel('Parent',self.Panel,...
                'Text','',...
                'Visible','off',...
                'VerticalAlignment','top',...
                'FontColor',[0.94,0.94,0.94],...
                'FontSize',18,...
                'Tag','SliceIndicator');

            else

                colorAxes=axes(self.Panel,'Position',[0,0,1,1],'HitTest','off','PickableParts','none','Toolbar',[]);
                self.ColorIndicator=imshow(zeros([20,20,3],'uint8'),'Parent',colorAxes,'InitialMagnification','fit','Interpolation','nearest');
                set(self.ColorIndicator,'HitTest','off','PickableParts','none','Visible','off','Tag','ColorIndicator');
                disableDefaultInteractivity(colorAxes);

                modeAxes=axes(self.Panel,'Position',[0,0,1,1],'Toolbar',[]);
                self.ModeIndicator=imshow(zeros([20,20,3],'uint8'),'Parent',modeAxes,'InitialMagnification','fit','Interpolation','nearest');
                set(self.ModeIndicator,'HitTest','off','PickableParts','none','Visible','off','Tag','ModeIndicator');
                disableDefaultInteractivity(modeAxes);

                sliceAxes=axes(self.Panel,'Position',[0,0,1,1],'Visible','off','HitTest','off','PickableParts','none','XTick',[],'YTick',[],'Color',[0.94,0.94,0.94],'XColor',[0.94,0.94,0.94],'YColor',[0.94,0.94,0.94],'ZColor',[0.94,0.94,0.94],'Toolbar',[]);
                self.SliceIndicator=text('String','','Parent',sliceAxes,'VerticalAlignment','bottom','Color',[0.94,0.94,0.94],'FontSize',12,'HitTest','off','PickableParts','none','BackgroundColor','none','Tag','SliceIndicator');
                disableDefaultInteractivity(sliceAxes);

            end

            hfig=ancestor(hParent,'figure');
            self.Datatip=text('Parent',self.Image.AxesHandle,'String',["[X,Y,X]";"Intensity"],...
            'BackgroundColor',[0,0,0],'EdgeColor',[0.5,0.5,0.5],'Color',[1,1,1],'Visible','off',...
            'PickableParts','none','HitTest','off','VerticalAlignment','bottom','Margin',2,...
            'Tag','Datatip');
            self.DatatipListener=event.listener(hfig,'WindowMouseMotion',@(src,evt)moveDatatip(self,evt));
            self.DatatipListener.Enabled=false;

            displayMode(self,'Freehand');

            setAxesPosition(self);

        end




        function draw(self,img,label,cmap,contrastLimits,varargin)

            draw(self.Image,img,label,cmap,contrastLimits,varargin{:});

        end




        function resize(self,pos)

            if~isequal(self.Panel.Position,pos)
                self.Panel.Position=pos;
                resize(self.Image);
                setAxesPosition(self);
            end

        end




        function clear(self)

            self.Empty=true;
            self.Enabled=false;
            clear(self.Image);

        end




        function zoomIn(self)
            zoomIn(self.Image);
        end




        function zoomOut(self)
            zoomOut(self.Image);
        end




        function pan(self,str)
            pan(self.Image,str);
        end




        function scroll(self,scrollCount)
            scroll(self.Image,scrollCount);
        end




        function deselectAxesInteraction(self)
            showVoxelInfo(self,false);
            deselectAxesInteraction(self.Image);
        end




        function rotate(self,val)
            rotate(self.Image,val);
        end




        function displaySliceNumber(self,currentSlice,maxSlice)

            str=[num2str(currentSlice),'/',num2str(maxSlice)];

            if isa(self.SliceIndicator,'matlab.ui.control.Label')
                set(self.SliceIndicator,'Text',str);
            else
                set(self.SliceIndicator,'String',str);
            end

        end




        function displayLabelColor(self,color)

            I(1:20,1:20,1)=color(1);
            I(1:20,1:20,2)=color(2);
            I(1:20,1:20,3)=color(3);

            if isa(self.ColorIndicator,'matlab.ui.control.Image')
                self.ColorIndicator.ImageSource=I;
            else
                self.ColorIndicator.CData=I;
            end

        end




        function displayMode(self,mode)

            if isa(self.ModeIndicator,'matlab.ui.control.Image')

                switch mode

                case 'Freehand'
                    self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Freehand_20.png');
                case 'AssistedFreehand'
                    self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_AssistedFreehand_20.png');
                case 'Polygon'
                    self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Polygon_20.png');
                case 'PaintBrush'
                    self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Brush_20.png');
                case 'Eraser'
                    self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Eraser_20.png');
                case{'FillRegion','FloodFill'}
                    self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_FillRegion_20.png');
                case 'Select'
                    self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_SelectRegion_20.png');
                end

            else

                switch mode

                case 'Freehand'
                    [icon,~,alpha]=imread(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Freehand_20.png'));
                case 'AssistedFreehand'
                    [icon,~,alpha]=imread(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_AssistedFreehand_20.png'));
                case 'Polygon'
                    [icon,~,alpha]=imread(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Polygon_20.png'));
                case 'PaintBrush'
                    [icon,~,alpha]=imread(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Brush_20.png'));
                case 'Eraser'
                    [icon,~,alpha]=imread(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Eraser_20.png'));
                case{'FillRegion','FloodFill'}
                    [icon,~,alpha]=imread(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_FillRegion_20.png'));
                case 'Select'
                    [icon,~,alpha]=imread(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_SelectRegion_20.png'));
                end


                set(self.ModeIndicator,'CData',icon(:,2:end,:),'AlphaData',alpha(:,2:end));

            end

        end




        function setImageColors(self,backgroundColor,boxColor)
            self.Image.BackgroundColor=backgroundColor;
            self.Image.BoxColor=boxColor;
        end




        function updateThumbnailDisplay(self,img,label,cmap,contrastLimits)

            sz=size(img);

            if sz(1)>sz(2)
                img=imresize(img,[100,NaN],'bilinear');
                if~isempty(label)
                    label=imresize(label,[100,NaN],'nearest');
                end
            else
                img=imresize(img,[NaN,100],'bilinear');
                if~isempty(label)
                    label=imresize(label,[NaN,100],'nearest');
                end
            end

            TF=self.Image.SuperpixelsVisible;
            self.Image.SuperpixelsVisible=false;

            img=blendImage(self.Image,img,label,cmap,contrastLimits);

            self.Image.SuperpixelsVisible=TF;

            isResetRequired=~isequal(size(self.Thumbnail.CData,1,2),size(img,1,2));

            self.Thumbnail.CData=img;

            if isResetRequired
                xLim=get(self.Thumbnail,'XData')+[-0.5,0.5];
                yLim=get(self.Thumbnail,'YData')+[-0.5,0.5];
                set(self.Thumbnail.Parent,'XLim',xLim,'YLim',yLim);
            end

            sz=size(img);

            mousePos=self.Panel.Parent.CurrentPoint;
            pos=self.Thumbnail.Parent.Position;

            pct=sz(2)*(mousePos(1)/self.Panel.Position(3));

            if pct>sz(2)
                pct=sz(2);
            end

            if pct<0
                pct=0;
            end

            pos(1)=mousePos(1)-pct;
            pos(3)=sz(2);
            pos(4)=sz(1);

            set(self.Thumbnail.Parent,'Position',pos,'Visible','on');

            self.Thumbnail.Visible='on';

        end




        function hideThumbnail(self)
            if isa(getCanvas(self.Panel),'matlab.graphics.primitive.canvas.HTMLCanvas')


                pos=self.Thumbnail.Parent.Position;
                pos(1)=-300;
                set(self.Thumbnail.Parent,'Position',pos)
            else
                self.Thumbnail.Visible='off';
                self.Thumbnail.Parent.Visible='off';
            end
        end




        function updateVoxelInfo(self,loc,val)

            info=['[X,Y,Z]:  [',num2str(loc),']'];

            if isscalar(val)
                colorinfo=['Intensity:  ',num2str(val)];
            else
                colorinfo=['[R,G,B]:  [',num2str(val),']'];
            end

            set(self.Datatip,'String',[string(info);string(colorinfo)]);

        end




        function showVoxelInfo(self,TF)

            if TF
                self.DatatipListener.Enabled=true;
            else
                self.Datatip.Visible='off';
                self.DatatipListener.Enabled=false;
            end

        end




        function setBlockToolbarVisibility(self,TF)

            if TF
                self.BlockToolbarButton.Visible='on';
            else
                self.BlockToolbarButton.Visible='off';
            end

        end




        function moveBlock(self,str)

            switch str

            case 'up'
                unrotatedPoints=[0,-1];
                z=0;
            case 'down'
                unrotatedPoints=[0,1];
                z=0;
            case 'left'
                unrotatedPoints=[-1,0];
                z=0;
            case 'right'
                unrotatedPoints=[1,0];
                z=0;
            case 'in'
                unrotatedPoints=[0,0];
                z=-1;
            case 'out'
                unrotatedPoints=[0,0];
                z=1;
            otherwise
                return;

            end

            pts=applyOffsetBackward(self.Image.Rotate,unrotatedPoints);

            notify(self,'BlockIndexShifted',images.internal.app.segmenter.volume.events.BlockIndexShiftedEventData([pts(2),pts(1),z]));

        end

    end


    methods(Access=protected)


        function setAxesPosition(self)

            pos=self.Panel.Position;

            pos(1)=5;
            pos(2)=5;
            pos(3)=pos(3)-10;
            pos(4)=pos(4)-25;

            if any(pos<1)
                return;
            end

            axesInfo=GetLayoutInformation(self.ImageHandle.Parent);

            pos(1)=axesInfo.PlotBox(1);

            if pos(1)<=1
                pos(1)=10;
            end

            pos(2)=axesInfo.PlotBox(2)+axesInfo.PlotBox(4);

            if pos(2)>pos(4)+7
                pos(2)=pos(4)-5;
            end

            w=pos(3);

            pos(4)=20;
            pos(3)=20;

            if isa(self.ColorIndicator,'matlab.ui.control.Image')
                set(self.ColorIndicator,'Position',pos);
            else
                set(self.ColorIndicator.Parent,'Units','pixels','Position',pos);
            end

            pos(1)=pos(1)+22;

            if isa(self.ModeIndicator,'matlab.ui.control.Image')
                set(self.ModeIndicator,'Position',pos);
            else
                set(self.ModeIndicator.Parent,'Units','pixels','Position',pos);
            end

            pos(1)=pos(1)+22;
            pos(3)=max(w-45,1);

            if isa(self.SliceIndicator,'matlab.ui.control.Label')
                pos(3)=100;
                set(self.SliceIndicator,'Position',pos);
            else
                set(self.SliceIndicator.Parent,'Units','pixels','Position',pos);
            end

            if strcmp(self.Datatip.Visible,'on')
                set(self.Datatip,'Position',[self.Image.AxesHandle.CurrentPoint(1,1:2),0]);
            end

        end


        function moveDatatip(self,evt)

            if evt.HitObject==self.Image.ImageHandle

                unrotatedPoints=self.Image.AxesHandle.CurrentPoint(1,1:2);

                pts=applyOffsetBackward(self.Image.Rotate,unrotatedPoints);
                pts=ceil(pts-0.5);

                notify(self,'UpdateDatatip',images.internal.app.segmenter.volume.events.HitEventData(pts));

                set(self.Datatip,'Position',[unrotatedPoints,0]);

                if strcmp(self.Datatip.Visible,'off')
                    self.Datatip.Visible='on';
                end

            elseif strcmp(self.Datatip.Visible,'on')
                self.Datatip.Visible='off';
            end

        end


        function reactToEmptyPropChange(~)


        end

    end


    methods




        function set.Empty(self,TF)

            if TF

                bgColor=[0.94,0.94,0.94];
                set(self.Panel.Parent,'Color',bgColor);
                set(self.Panel,'BackgroundColor',bgColor);
                if isa(self.SliceIndicator,'matlab.ui.control.Label')
                    set(self.SliceIndicator,'Text','');
                    set(self.SliceIndicator,'Visible','off');
                else
                    set(self.SliceIndicator,'String','');
                    set(self.SliceIndicator,'Visible','off');
                end
                set(self.ColorIndicator,'Visible','off');
                set(self.ModeIndicator,'Visible','off');

            else
                bgColor=[0,0,0];
                set(self.Panel.Parent,'Color',bgColor);
                set(self.Panel,'BackgroundColor',bgColor);%#ok<*MCSUP>
                set(self.SliceIndicator,'Visible','on');
                set(self.ColorIndicator,'Visible','on');
                set(self.ModeIndicator,'Visible','on');
            end

            if isa(getCanvas(self.Panel),'matlab.graphics.primitive.canvas.HTMLCanvas')



                set(self.SliceIndicator,'BackgroundColor','none');
                set(self.ModeIndicator,'BackgroundColor','none');
                set(self.ColorIndicator,'BackgroundColor','none');
            end

            self.Image.Visible=~TF;
            self.Empty=TF;

            self.reactToEmptyPropChange();

        end




        function set.Enabled(self,TF)

            self.Image.Enabled=TF;
            self.Enabled=TF;

        end




        function set.RotationState(self,val)

            self.Image.RotationState=val;

        end

        function val=get.RotationState(self)

            val=self.Image.RotationState;

        end




        function set.Alpha(self,val)

            self.Image.Alpha=val;

        end

        function val=get.Alpha(self)

            val=self.Image.Alpha;

        end




        function val=get.ImageHandle(self)

            val=self.Image.ImageHandle;

        end




        function set.SuperpixelOverlay(self,L)
            self.Image.Superpixels=L;
        end

        function L=get.SuperpixelOverlay(self)
            L=self.Image.Superpixels;
        end




        function set.ShowOverlay(self,TF)
            self.Image.SuperpixelsVisible=TF;
        end

        function TF=get.ShowOverlay(self)
            TF=self.Image.SuperpixelsVisible;
        end




        function set.PixelSize(self,pixelSize)
            self.Image.PixelSize=pixelSize;
            self.Thumbnail.Parent.DataAspectRatio=[1/pixelSize(1),1/pixelSize(2),1];
        end

        function pixelSize=get.PixelSize(self)
            pixelSize=self.Image.PixelSize;
        end

    end


end