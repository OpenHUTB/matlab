classdef orthosliceViewer<images.stacks.browser.internal.SliceViewer


    events
CrosshairMoving
CrosshairMoved
    end


    properties(Dependent)

SliceNumbers


CrosshairColor


CrosshairLineWidth


CrosshairStripeColor


CrosshairEnable
    end

    properties(Hidden,Access=private,Transient=true)
InternalSliceNumbers
InternalCrosshairColor
InternalCrosshairLineWidth

hOriantationAxes
zLetter
SliceNumText
BorderSize

XYCrosshair
XZCrosshair
YZCrosshair


hLinkAxes
hLinkCrosshair
    end


    properties(Hidden,Access=private,Transient=true)

CrosshairMovingListener
CrosshairMovedListener
    end


    methods
        function self=orthosliceViewer(vol,varargin)


            varargin=matlab.images.internal.stringToChar(varargin(:));

            labels=[];
            if~isempty(varargin)&&~ischar(varargin{1})
                labels=varargin{1};
                varargin=varargin(2:end);
            end

            self@images.stacks.browser.internal.SliceViewer;
            self.loadData(vol,labels);
            self.setDefaults();

            self.parseInputs(varargin{:});

        end

        function[hXYAxes,hYZAxes,hXZAxes]=getAxesHandles(self)
            hXYAxes=self.AxesHandles(1);
            hYZAxes=self.AxesHandles(2);
            hXZAxes=self.AxesHandles(3);
        end

        function delete(self)
            delete(self.CrosshairMovedListener)
            delete(self.CrosshairMovingListener)
        end
    end

    methods(Hidden,Access=protected)
        function setDefaults(self)

            self.setupSliceManager()
            self.setDefaultDisplayRangeInteraction();

            self.BorderSize=20;

            self.XYCrosshair=images.roi.Crosshair('HandleVisibility','callback','UIContextMenu',[],'Tag','XYCh');
            self.XZCrosshair=images.roi.Crosshair('HandleVisibility','callback','UIContextMenu',[],'Tag','XZCh');
            self.YZCrosshair=images.roi.Crosshair('HandleVisibility','callback','UIContextMenu',[],'Tag','YZCh');


            self.hLinkCrosshair=linkprop([self.XYCrosshair,self.XZCrosshair,self.YZCrosshair],...
            {'Color','StripeColor','LineWidth'});


            self.InternalCrosshairColor=[1,1,0];
            self.InternalCrosshairLineWidth=1;
            self.InternalSliceNumbers=round([mean([1,self.ImgSizeScaled(2)]),...
            mean([1,self.ImgSizeScaled(1)]),mean([1,self.ImgSizeScaled(3)])]);
        end

        function setupView(self)





            self.ImageHandles=gobjects(1,3);
            self.ImageHandles(1)=imshow(self.getSlice('XY',self.InternalSliceNumbers(3)),...
            'Parent',self.AxesHandles(1),'DisplayRange',self.DisplayRange,...
            'InitialMagnification','fit');
            self.ImageHandles(2)=imshow(self.getSlice('YZ',self.InternalSliceNumbers(1)),...
            'Parent',self.AxesHandles(2),'DisplayRange',self.DisplayRange,...
            'InitialMagnification','fit');
            self.ImageHandles(3)=imshow(self.getSlice('XZ',self.InternalSliceNumbers(2)),...
            'Parent',self.AxesHandles(3),'DisplayRange',self.DisplayRange,...
            'InitialMagnification','fit');


            self.Colormap=self.InternalColormap;
            self.DisplayRange=self.InternalDisplayRange;
            self.SliceNumbers=self.InternalSliceNumbers;
            self.DisplayRangeInteraction=self.InternalDisplayRangeInteraction;
            self.CrosshairColor=self.InternalCrosshairColor;
            self.CrosshairLineWidth=self.InternalCrosshairLineWidth;

            set(self.AxesHandles,{'XTick','YTick'},{[],[]});
            set(self.AxesHandles,'XAxisLocation','top');


            self.AxesHandles(2).XLabel.String=getString(message('images:sliceViewer:Z'));
            labelFontSize=self.AxesHandles(2).XLabel.FontSize;


            self.AxesHandles(1).XLabel.String=getString(message('images:sliceViewer:X'));
            self.AxesHandles(1).XLabel.FontSize=labelFontSize;
            self.AxesHandles(1).YLabel.String=getString(message('images:sliceViewer:Y'));
            self.AxesHandles(1).YLabel.FontSize=labelFontSize;
            self.AxesHandles(1).YLabel.Rotation=0;


            self.AxesHandles(3).YLabel.String=getString(message('images:sliceViewer:Z'));
            self.AxesHandles(3).YLabel.FontSize=labelFontSize;
            self.AxesHandles(3).YLabel.Rotation=0;


            set(self.AxesHandles,'Visible','on');


            self.AxesHandles(1).Toolbar.Visible='on';
            self.AxesHandles(2).Toolbar.Visible='on';
            self.AxesHandles(3).Toolbar.Visible='on';

            self.XYCrosshair.Parent=self.AxesHandles(1);
            self.YZCrosshair.Parent=self.AxesHandles(2);
            self.XZCrosshair.Parent=self.AxesHandles(3);


            self.CrosshairMovingListener=event.listener([self.XYCrosshair,self.XZCrosshair,self.YZCrosshair],...
            'MovingROI',@(hObj,data)self.crosshairMoving(hObj,data));

            self.CrosshairMovedListener=event.listener([self.XYCrosshair,self.XZCrosshair,self.YZCrosshair],...
            'ROIMoved',@(hObj,data)self.crosshairMoved(hObj,data));


        end

        function resetView(self)

            self.setSliceExtents();
            self.layoutViewComponents();

            self.SliceNumbers=round([mean([1,self.ImgSizeScaled(2)]),...
            mean([1,self.ImgSizeScaled(1)]),mean([1,self.ImgSizeScaled(3)])]);




            zoom(self.hFig,'reset');

        end

        function createViewComponents(self)





            self.AxesHandles=gobjects(1,3);

            self.AxesHandles(1)=axes('Parent',self.hPanel,...
            'Units','pixels',...
            'ActivePositionProperty','position',...
            'HandleVisibility','callback',...
            'Tag','XYAxes',...
            'Box','off');

            self.AxesHandles(2)=axes('Parent',self.hPanel,...
            'Units','pixels',...
            'ActivePositionProperty','position',...
            'HandleVisibility','callback',...
            'Tag','YZAxes',...
            'Box','off');

            self.AxesHandles(3)=axes('Parent',self.hPanel,...
            'Units','pixels',...
            'ActivePositionProperty','position',...
            'HandleVisibility','callback',...
            'Tag','XZAxes',...
            'Box','off');

            self.hOriantationAxes=axes('Parent',self.hPanel,...
            'Units','pixels',...
            'XTick',[],'YTick',[],...
            'Toolbar',[],...
            'ActivePositionProperty','position',...
            'HandleVisibility','callback',...
            'Visible','off',...
            'Box','off');

            self.SliceNumText=text('Parent',self.hOriantationAxes,...
            'HorizontalAlignment','left',...
            'VerticalAlignment','top',...
            'Position',[0,1],...
            'Tag','SliceNumber',...
            'HandleVisibility','off');


            self.hLinkAxes=linkprop(self.AxesHandles,{'CLim','Colormap'});

            if isa(getCanvas(self.hPanel),'matlab.graphics.primitive.canvas.HTMLCanvas')

                self.hPanel.AutoResizeChildren='off';
                self.hPanel.SizeChangedFcn=@(hobj,evt)self.managePanelResize();
                self.isUIFigure=true;

            else

                self.hPanel.SizeChangedFcn=@(hobj,evt)self.managePanelResize();
                self.isUIFigure=true;
            end
        end

        function[prevPos,currPos]=updateView(self,hObj,data)



            sliceNum=self.InternalSliceNumbers;
            previousPosition=round(data.PreviousPosition);
            currentPosition=round(data.CurrentPosition);

            if hObj==self.XYCrosshair
                prevPos=[previousPosition,sliceNum(3)];
                currPos=[currentPosition,sliceNum(3)];
                currPos=bsxfun(@min,currPos,self.ImgSizeScaled([2,1,3]));
                currPos=bsxfun(@max,currPos,[1,1,1]);

                self.ImageHandles(2).CData=self.getSlice('YZ',currPos(1));
                self.ImageHandles(3).CData=self.getSlice('XZ',currPos(2));

            elseif hObj==self.XZCrosshair
                prevPos=[previousPosition(1),sliceNum(2),previousPosition(2)];
                currPos=[currentPosition(1),sliceNum(2),currentPosition(2)];
                currPos=bsxfun(@min,currPos,self.ImgSizeScaled([2,1,3]));
                currPos=bsxfun(@max,currPos,[1,1,1]);

                self.ImageHandles(1).CData=self.getSlice('XY',currPos(3));
                self.ImageHandles(2).CData=self.getSlice('YZ',currPos(1));

            elseif hObj==self.YZCrosshair
                prevPos=[sliceNum(1),previousPosition(2),previousPosition(1)];
                currPos=[sliceNum(1),currentPosition(2),currentPosition(1)];
                currPos=bsxfun(@min,currPos,self.ImgSizeScaled([2,1,3]));
                currPos=bsxfun(@max,currPos,[1,1,1]);

                self.ImageHandles(1).CData=self.getSlice('XY',currPos(3));
                self.ImageHandles(3).CData=self.getSlice('XZ',currPos(2));
            else
                assert(true,'Should never reach here');
            end

            self.InternalSliceNumbers=currPos;
            self.updateCrosshairPositions(currPos);

        end
    end


    methods(Hidden,Access=protected)
        function crosshairMoved(self,hObj,data)

            [prevPos,currPos]=self.updateView(hObj,data);
            evtData=images.stacks.browser.CrosshairMovingEventData(prevPos,currPos);
            self.notify('CrosshairMoved',evtData);
        end

        function crosshairMoving(self,hObj,data)

            [prevPos,currPos]=self.updateView(hObj,data);
            evtData=images.stacks.browser.CrosshairMovingEventData(prevPos,currPos);
            self.notify('CrosshairMoving',evtData);
        end

        function managePanelResize(self)
            panelUnits=self.hPanel.Units;
            self.hPanel.Units='pixels';
            self.PanelSize=self.hPanel.Position(3:4);
            self.hPanel.Units=panelUnits;

            self.layoutViewComponents();
        end
    end


    methods

        function set.CrosshairColor(self,chColor)


            if~isempty(chColor)
                self.XYCrosshair.Color=chColor;
                self.XZCrosshair.Color=chColor;
                self.YZCrosshair.Color=chColor;
            end
            self.InternalCrosshairColor=chColor;

        end

        function chColor=get.CrosshairColor(self)
            chColor=self.InternalCrosshairColor;
        end


        function set.CrosshairLineWidth(self,chWidth)

            if~isempty(chWidth)
                self.XYCrosshair.LineWidth=chWidth;
                self.XZCrosshair.LineWidth=chWidth;
                self.YZCrosshair.LineWidth=chWidth;
            end
            self.InternalCrosshairLineWidth=chWidth;
        end

        function chWidth=get.CrosshairLineWidth(self)
            chWidth=self.InternalCrosshairLineWidth;
        end


        function set.CrosshairStripeColor(self,chStripeColor)

            if~isempty(chStripeColor)
                self.XYCrosshair.StripeColor=chStripeColor;
                self.XZCrosshair.StripeColor=chStripeColor;
                self.YZCrosshair.StripeColor=chStripeColor;
            end
        end

        function chStripeColor=get.CrosshairStripeColor(self)
            chStripeColor=self.XYCrosshair.StripeColor;
        end


        function set.SliceNumbers(self,sliceNum)

            validateattributes(sliceNum,{'numeric','integer'},...
            {'size',[1,3],'real','finite','nonempty','nonsparse','positive'},...
            mfilename,'SliceNumbers');

            sliceNum=round(sliceNum);
            if any(sliceNum>self.ImgSizeScaled([2,1,3]))
                error(message('images:sliceViewer:sliceNumsOutOfBounds'));
            end

            if~isempty(self.Parent)

                self.ImageHandles(1).CData=self.getSlice('XY',sliceNum(3));
                self.ImageHandles(2).CData=self.getSlice('YZ',sliceNum(1));
                self.ImageHandles(3).CData=self.getSlice('XZ',sliceNum(2));
            end


            self.updateCrosshairPositions(sliceNum);
            self.InternalSliceNumbers=sliceNum;
        end

        function sliceNum=get.SliceNumbers(self)
            sliceNum=self.InternalSliceNumbers;
        end


        function set.CrosshairEnable(self,val)
            validateattributes(val,{'char','string'},{'scalartext'},...
            mfilename,'CrosshairEnable');

            validStr=validatestring(val,{'on','off','inactive'},mfilename,...
            'CrosshairEnable');

            switch validStr
            case 'on'
                set([self.XYCrosshair,self.XZCrosshair,self.YZCrosshair],...
                'Visible','on');
                set([self.XYCrosshair,self.XZCrosshair,self.YZCrosshair],...
                'InteractionsAllowed','all');

            case 'inactive'
                set([self.XYCrosshair,self.XZCrosshair,self.YZCrosshair],...
                'Visible','on');
                set([self.XYCrosshair,self.XZCrosshair,self.YZCrosshair],...
                'InteractionsAllowed','none');

            case 'off'
                set([self.XYCrosshair,self.XZCrosshair,self.YZCrosshair],...
                'Visible','off');
                set([self.XYCrosshair,self.XZCrosshair,self.YZCrosshair],...
                'InteractionsAllowed','none');

            otherwise
                assert(false,'Should not reach here');
            end
        end

        function val=get.CrosshairEnable(self)
            if isequal(self.XYCrosshair.Visible,'on')
                if isequal(self.XYCrosshair.InteractionsAllowed,'all')
                    val='on';
                else
                    val='inactive';
                end
            else
                val='off';
            end
        end
    end


    methods(Hidden,Access=protected)
        function layoutViewComponents(self)

            k=self.computeResizeFactor();
            borderSize=self.BorderSize;
            imgSizeScaled=k*self.ImgSizeScaled;
            width=imgSizeScaled(2)+borderSize+imgSizeScaled(3);
            height=imgSizeScaled(1)+borderSize+imgSizeScaled(3);

            leftStart=(self.PanelSize(1)-width)/2;
            bottomStart=(self.PanelSize(2)-height)/2;

            pos=[leftStart,bottomStart,imgSizeScaled(2),imgSizeScaled(3)];
            self.AxesHandles(3).Position=pos;

            bottomStart=bottomStart+imgSizeScaled(3)+borderSize;
            pos=[leftStart,bottomStart,imgSizeScaled(2),imgSizeScaled(1)];
            self.AxesHandles(1).Position=pos;

            leftStart=leftStart+imgSizeScaled(2)+borderSize;
            pos=[leftStart,bottomStart,imgSizeScaled(3),imgSizeScaled(1)];
            self.AxesHandles(2).Position=pos;

            bottomStart=self.AxesHandles(3).Position(2)-2*borderSize;
            pos=[leftStart,bottomStart,2*borderSize+imgSizeScaled(3),2*borderSize+imgSizeScaled(3)];
            self.hOriantationAxes.Position=pos;
        end

        function reactToScaleFactorsChange(self,oldSize)

            if~isempty(self.Parent)


                self.layoutViewComponents();
                self.setSliceExtents();
            end



            newSliceNum=ceil(self.SliceNumbers.*self.ImgSizeScaled([2,1,3])./oldSize([2,1,3]));
            self.SliceNumbers=newSliceNum;

        end

        function setSliceExtents(self)

            self.AxesHandles(1).XLim=[1,self.ImgSizeScaled(2)]+[-0.5,0.5];
            self.AxesHandles(1).YLim=[1,self.ImgSizeScaled(1)]+[-0.5,0.5];

            self.AxesHandles(2).XLim=[1,self.ImgSizeScaled(3)]+[-0.5,0.5];
            self.AxesHandles(2).YLim=[1,self.ImgSizeScaled(1)]+[-0.5,0.5];

            self.AxesHandles(3).XLim=[1,self.ImgSizeScaled(2)]+[-0.5,0.5];
            self.AxesHandles(3).YLim=[1,self.ImgSizeScaled(3)]+[-0.5,0.5];

        end

        function updateCrosshairPositions(self,sliceNum)




            self.XYCrosshair.Position=sliceNum([1,2]);
            self.XZCrosshair.Position=sliceNum([1,3]);
            self.YZCrosshair.Position=sliceNum([3,2]);

            val={['X: ',num2str(sliceNum(1))],['Y: ',num2str(sliceNum(2))],['Z: ',num2str(sliceNum(3))]};
            self.SliceNumText.String=val;
        end

        function k=computeResizeFactor(self)
            [widthRequired,heightRequired]=self.computeRequiredUISize();
            kWidth=(self.PanelSize(1)-(5*self.BorderSize))/widthRequired;
            kHeight=(self.PanelSize(2)-(5*self.BorderSize))/heightRequired;
            k=min(kWidth,kHeight);
        end

        function[widthRequired,heightRequired]=computeRequiredUISize(self,includeBordersFlag)
            if nargin==1
                includeBordersFlag=false;
            end



            widthRequired=self.ImgSizeScaled(2)+self.ImgSizeScaled(3);
            heightRequired=self.ImgSizeScaled(1)+self.ImgSizeScaled(3);

            if includeBordersFlag
                widthRequired=2*self.BorderSize+widthRequired+3*self.BorderSize;
                heightRequired=2*self.BorderSize+heightRequired+3*self.BorderSize;
            end
        end

    end


    methods(Hidden,Access=protected)

        function slice=getSlice(self,direction,idx)

            slice=self.getSliceVolume(direction,idx);
            if~isempty(self.Labels)
                labels=self.getSliceLabel(direction,idx);
                slice=images.internal.labeloverlayalgo(im2single(slice),double(labels),self.LabelColor,self.LabelOpacity,0:255);
            end

        end

        function slice=getSliceVolume(self,direction,idx)
            switch direction
            case 'XY'
                slice=self.SliceManager.getXYSlice(idx);
            case 'YZ'
                slice=self.SliceManager.getYZSlice(idx);
            case 'XZ'
                slice=flip(rot90(self.SliceManager.getXZSlice(idx)));
            end
        end

        function slice=getSliceLabel(self,direction,idx)
            switch direction
            case 'XY'
                slice=self.SliceManagerLabels.getXYSlice(idx);
            case 'YZ'
                slice=self.SliceManagerLabels.getYZSlice(idx);
            case 'XZ'
                slice=flip(rot90(self.SliceManagerLabels.getXZSlice(idx)));
            end
        end

        function parseInputs(self,varargin)

            if~isempty(varargin)



                [hParent,varargin]=self.extractInputNameValue(varargin,'Parent');

                [hScale,varargin]=self.extractInputNameValue(varargin,'ScaleFactors');

                if~isempty(hScale)
                    self.ScaleFactors=hScale;
                end


                if~isempty(varargin)
                    set(self,varargin{:});
                end



                if isempty(hParent)
                    hFig=gcf;
                    hFig.MenuBar='none';
                    hFig.ToolBar='none';
                    self.Parent=hFig;
                else
                    self.Parent=hParent;
                end

            else

                hFig=gcf;
                hFig.MenuBar='none';
                hFig.ToolBar='none';
                self.Parent=hFig;
            end

        end
    end
end