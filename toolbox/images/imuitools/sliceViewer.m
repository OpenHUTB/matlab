classdef sliceViewer<images.stacks.browser.internal.SliceViewer


    events
SliderValueChanged
SliderValueChanging
    end


    properties(Dependent)

SliceDirection


SliceNumber
    end

    properties(Hidden,Access=private,Transient=true)
NumSlices
SliceWidth
SliceHeight
InternalSliceNumber
SliceDirectionNormal
InternalSliceDirection


Slider
PrevBtn
NextBtn
SliceNumText
UIControlsHeight
BorderSize
    end


    properties(Hidden,Access=private,Transient=true)
SliderListener
    end


    methods
        function self=sliceViewer(vol,varargin)


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

        function delete(self)
            delete(self.SliderListener)
        end

        function hAxes=getAxesHandle(self)
            hAxes=self.AxesHandles;
        end

    end

    methods(Hidden,Access=protected)
        function setDefaults(self)

            self.setupSliceManager()
            self.setDefaultDisplayRangeInteraction();

            self.BorderSize=30;
            self.UIControlsHeight=50;


            self.InternalSliceDirection=[0,0,1];
            self.SliceDirectionNormal=[0,0,1];
            self.setSliceExtents();
            self.InternalSliceNumber=ceil(mean([1,self.ImgSizeScaled(3)]));

        end

        function setupView(self)



            self.ImageHandles=gobjects(1,1);
            slice=self.getSlice(self.InternalSliceNumber);
            self.ImageHandles(1)=imshow(slice,...
            'Parent',self.AxesHandles(1),'DisplayRange',self.InternalDisplayRange,...
            'InitialMagnification','fit');
            self.AxesHandles(1).Toolbar.Visible='on';

            self.Colormap=self.InternalColormap;
            self.DisplayRange=self.InternalDisplayRange;
            self.DisplayRangeInteraction=self.InternalDisplayRangeInteraction;

        end

        function createViewComponents(self)


            currImage=self.InternalSliceNumber;


            self.AxesHandles=gobjects(1,1);
            self.AxesHandles(1)=axes('Parent',self.hPanel,...
            'Units','pixels',...
            'ActivePositionProperty','position',...
            'HandleVisibility','callback',...
            'Tag','hAxes',...
            'Box','off');

            if isa(getCanvas(self.hPanel),'matlab.graphics.primitive.canvas.HTMLCanvas')

                iconFile=fullfile(matlabroot,'toolbox','images','icons','leftArrow.png');
                self.PrevBtn=uibutton('push',...
                'Parent',self.hPanel,...
                'Text','',...
                'Icon',iconFile,...
                'HandleVisibility','off',...
                'Tag','PrevBtn',...
                'ButtonPushedFcn',@(src,evt)self.prevBtnCallback());

                self.Slider=uislider('Parent',self.hPanel,...
                'MajorTicks',[],...
                'MinorTicks',[],...
                'Limits',[1,self.NumSlices],...
                'Value',currImage,...
                'HandleVisibility','off',...
                'Tag','Slider',...
                'ValueChangedFcn',@(src,evt)self.sliderMovedCallback(evt.Value),...
                'ValueChangingFcn',@(src,evt)self.sliderMovingCallback(evt.Value));

                iconFile=fullfile(matlabroot,'toolbox','images','icons','rightArrow.png');
                self.NextBtn=uibutton('push',...
                'Parent',self.hPanel,...
                'Text','',...
                'Icon',iconFile,...
                'HandleVisibility','off',...
                'Tag','NextBtn',...
                'ButtonPushedFcn',@(src,evt)self.nextBtnCallback());

                self.SliceNumText=uilabel('Parent',self.hPanel,...
                'HorizontalAlignment','right',...
                'VerticalAlignment','center',...
                'Enable','on',...
                'Text',[num2str(currImage),'/',num2str(self.NumSlices)],...
                'Tag','SliceNumber',...
                'HandleVisibility','off');
                self.SliceNumText.FontSize=self.SliceNumText.FontSize+1;

                self.isUIFigure=true;


                self.hPanel.AutoResizeChildren='off';
                self.hPanel.SizeChangedFcn=@(hobj,evt)self.managePanelResize();

            else

                self.Slider=uicontrol('Style','slider',...
                'Parent',self.hPanel,...
                'HorizontalAlignment','left',...
                'Units','pixels',...
                'Min',1,...
                'Max',self.NumSlices,...
                'SliderStep',[1/(self.NumSlices-1),1/(self.NumSlices-1)],...
                'Value',currImage,...
                'HandleVisibility','off',...
                'Tag','Slider',...
                'Callback',@(src,evt)self.sliderMovedCallback(src.Value));
                self.SliderListener=addlistener(self.Slider,'Value','PostSet',@(src,evt)self.sliderMovingCallback(evt.AffectedObject.Value));

                self.SliceNumText=uicontrol('Style','text',...
                'Parent',self.hPanel,...
                'Units','pixels',...
                'HorizontalAlignment','right',...
                'String',[num2str(currImage),'/',num2str(self.NumSlices)],...
                'Tag','SliceNumber',...
                'HandleVisibility','off');
                self.SliceNumText.FontSize=self.SliceNumText.FontSize+1;

                self.isUIFigure=false;


                self.hPanel.SizeChangedFcn=@(hobj,evt)self.managePanelResize();

            end
        end

        function resetView(self)

            self.setSliceExtents();
            self.layoutViewComponents();
            self.reconfigureUI();

            self.SliceNumber=ceil(mean([1,self.ImgSizeScaled(find(self.SliceDirection))]));

        end
    end


    methods(Hidden,Access=protected)

        function sliderMovingCallback(self,val)
            val=ceil(val);
            self.InternalSliceNumber=val;
            self.ImageHandles(1).CData=self.getSlice(val);

            if self.isUIFigure
                self.SliceNumText.Text=[num2str(self.SliceNumber),'/',num2str(self.NumSlices)];
            else
                self.SliceNumText.String=[num2str(self.SliceNumber),'/',num2str(self.NumSlices)];
            end

            evtData=images.stacks.browser.SliderMovingEventData(val);
            self.notify('SliderValueChanging',evtData);
        end

        function sliderMovedCallback(self,val)
            val=ceil(val);
            self.InternalSliceNumber=val;
            if self.isUIFigure
                if val==self.NumSlices
                    self.NextBtn.Enable='off';
                elseif val==1
                    self.PrevBtn.Enable='off';
                else
                    self.PrevBtn.Enable='on';
                    self.NextBtn.Enable='on';
                end
            end

            evtData=images.stacks.browser.SliderMovingEventData(val);
            self.notify('SliderValueChanged',evtData);
        end

        function prevBtnCallback(self)
            self.NextBtn.Enable='on';
            self.Slider.Value=ceil(self.Slider.Value)-1;
            if self.Slider.Value==1
                self.PrevBtn.Enable='off';
            end
            self.sliderMovingCallback(self.Slider.Value);
        end

        function nextBtnCallback(self)
            self.PrevBtn.Enable='on';
            self.Slider.Value=ceil(self.Slider.Value)+1;
            if self.Slider.Value==self.NumSlices
                self.NextBtn.Enable='off';
            end
            self.sliderMovingCallback(self.Slider.Value);
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

        function set.SliceDirection(self,direction)
            direction=matlab.images.internal.stringToChar(direction);
            if isnumeric(direction)
                validateattributes(direction,{'numeric'},...
                {'size',[1,3],'>=',0,'<=',1,'nonempty','nonsparse',...
                'nonnegative','integer'},mfilename,'SliceDirection');



                if sum(direction)~=1
                    error(message('images:sliceViewer:directionNotSupported'));
                end
                self.SliceDirectionNormal=direction;

            elseif ischar(direction)
                direction=upper(direction);
                direction=validatestring(direction,{'X','Y','Z'},mfilename,'SliceDirection');
                switch direction
                case 'X'
                    self.SliceDirectionNormal=[1,0,0];
                case 'Y'
                    self.SliceDirectionNormal=[0,1,0];
                case 'Z'
                    self.SliceDirectionNormal=[0,0,1];
                end
            else
                error(message('images:sliceViewer:directionNotSupported'));
            end

            self.InternalSliceDirection=direction;


            self.setSliceExtents();





            if~isempty(self.Parent)
                self.layoutViewComponents();
                self.reconfigureUI();
                self.SliceNumber=mean([1,self.NumSlices]);
            end
        end

        function direction=get.SliceDirection(self)
            direction=self.InternalSliceDirection;
        end


        function set.SliceNumber(self,sliceNum)
            if isempty(sliceNum)
                sliceNum=mean([1,self.NumSlices]);
            end

            validateattributes(sliceNum,{'numeric','integer'},...
            {'scalar','real','finite','nonempty','nonsparse','positive'},...
            mfilename,'SliceNumber');

            sliceNum=ceil(sliceNum);
            if sliceNum>self.NumSlices
                error(message('images:sliceViewer:sliceNumOutOfBounds'));
            end

            if~isempty(self.Parent)
                self.Slider.Value=sliceNum;





                self.sliderMovingCallback(sliceNum);
                self.sliderMovedCallback(sliceNum);
            end
            self.InternalSliceNumber=sliceNum;
        end

        function sliceNum=get.SliceNumber(self)
            sliceNum=self.InternalSliceNumber;
        end

    end


    methods(Hidden,Access=protected)
        function layoutViewComponents(self)




            btnSize=24;
            bottomBorder=self.BorderSize/4;
            widthBtwnCtrls=self.BorderSize/4;

            k=self.computeResizeFactor();
            axesWidth=k*self.SliceWidth;
            xyWidth=max(axesWidth,75);

            axesStart=self.PanelSize(1)/2-(axesWidth)/2;
            self.AxesHandles(1).Position=[axesStart,bottomBorder+self.UIControlsHeight,axesWidth,k*self.SliceHeight];

            uicontrolStart=self.PanelSize(1)/2-xyWidth/2;
            uicontrolEnd=self.PanelSize(1)/2+xyWidth/2;
            uicontrolWidth=uicontrolEnd-uicontrolStart;


            pos=[uicontrolStart,bottomBorder+btnSize,uicontrolWidth,btnSize];
            self.SliceNumText.Position=pos;

            if self.isUIFigure
                pos=[uicontrolStart,bottomBorder,btnSize,btnSize];
                self.PrevBtn.Position=pos;

                nextCtrlStart=uicontrolStart+btnSize+widthBtwnCtrls;
                sliderWidth=uicontrolWidth-(nextCtrlStart-uicontrolStart)-(btnSize+widthBtwnCtrls);
                pos=[nextCtrlStart,bottomBorder+10,sliderWidth,btnSize];
                self.Slider.Position(1:3)=pos(1:3);

                nextCtrlStart=nextCtrlStart+sliderWidth+widthBtwnCtrls;
                pos=[nextCtrlStart,bottomBorder,btnSize,btnSize];
                self.NextBtn.Position=pos;

            else
                nextCtrlStart=uicontrolStart;
                width=uicontrolWidth-(nextCtrlStart-uicontrolStart);
                pos=[nextCtrlStart,bottomBorder,width,btnSize];
                self.Slider.Position=pos;
            end
        end

        function reconfigureUI(self)



            self.AxesHandles(1).XLim=[1,self.SliceWidth]+[-0.5,0.5];
            self.AxesHandles(1).YLim=[1,self.SliceHeight]+[-0.5,0.5];

            if self.isUIFigure
                self.Slider.Limits=[1,self.NumSlices];
            else
                self.Slider.Max=self.NumSlices;
                self.Slider.SliderStep=[1/self.NumSlices,1/self.NumSlices];




                zoom(self.hFig,'reset');
            end

        end

        function reactToScaleFactorsChange(self,~)
            oldNumSlices=self.NumSlices;
            self.setSliceExtents();



            newSliceNum=ceil(self.SliceNumber*self.NumSlices/oldNumSlices);

            if~isempty(self.Parent)
                self.layoutViewComponents();
                self.reconfigureUI();
                self.ImageHandles(1).CData=self.getSlice(newSliceNum);
            end


            self.SliceNumber=newSliceNum;

        end

        function k=computeResizeFactor(self)
            [widthRequired,heightRequired]=self.computeRequiredUISize();
            kWidth=(self.PanelSize(1)-(2*self.BorderSize))/widthRequired;
            kHeight=(self.PanelSize(2)-self.BorderSize)/heightRequired;
            k=min(kWidth,kHeight);
        end

        function[widthRequired,heightRequired]=computeRequiredUISize(self,includeBordersFlag)


            if nargin==1
                includeBordersFlag=false;
            end

            heightRequired=self.UIControlsHeight+self.SliceHeight;
            widthRequired=self.SliceWidth;

            if includeBordersFlag
                heightRequired=heightRequired+self.BorderSize;
                widthRequired=self.BorderSize+widthRequired+self.BorderSize;
            end



            widthRequired=max(widthRequired,75);
        end

        function setSliceExtents(self)
            idx=find(self.SliceDirectionNormal==1);
            switch idx
            case 1

                self.SliceWidth=self.ImgSizeScaled(3);
                self.SliceHeight=self.ImgSizeScaled(1);
                self.NumSlices=self.ImgSizeScaled(2);
            case 2

                self.SliceWidth=self.ImgSizeScaled(2);
                self.SliceHeight=self.ImgSizeScaled(3);
                self.NumSlices=self.ImgSizeScaled(1);
            case 3

                self.SliceWidth=self.ImgSizeScaled(2);
                self.SliceHeight=self.ImgSizeScaled(1);
                self.NumSlices=self.ImgSizeScaled(3);
            otherwise
                assert(false,'Should not reach here');
            end
        end
    end


    methods(Hidden,Access=protected)

        function slice=getSlice(self,sliceNum)

            slice=self.getSliceVolume(sliceNum);
            if~isempty(self.Labels)
                labels=self.getSliceLabel(sliceNum);
                slice=images.internal.labeloverlayalgo(im2single(slice),double(labels),self.LabelColor,self.LabelOpacity,0:255);
            end

        end

        function slice=getSliceVolume(self,sliceNum)

            idx=find(self.SliceDirectionNormal==1);
            switch idx
            case 1

                slice=self.SliceManager.getYZSlice(sliceNum);
            case 2

                slice=rot90(self.SliceManager.getXZSlice(sliceNum));
            case 3

                slice=self.SliceManager.getXYSlice(sliceNum);
            otherwise
            end
        end

        function slice=getSliceLabel(self,sliceNum)

            slice=[];
            if isempty(self.Labels)||isempty(self.SliceManagerLabels)
                return
            end

            idx=find(self.SliceDirectionNormal==1);
            switch idx
            case 1

                slice=self.SliceManagerLabels.getYZSlice(sliceNum);
            case 2

                slice=rot90(self.SliceManagerLabels.getXZSlice(sliceNum));
            case 3

                slice=self.SliceManagerLabels.getXYSlice(sliceNum);
            otherwise
            end
        end

        function parseInputs(self,varargin)

            if~isempty(varargin)



                [hParent,varargin]=self.extractInputNameValue(varargin,'Parent');
                [hSliceDir,varargin]=self.extractInputNameValue(varargin,'SliceDirection');
                [hScale,varargin]=self.extractInputNameValue(varargin,'ScaleFactors');

                if~isempty(hScale)
                    self.ScaleFactors=hScale;
                end

                if~isempty(hSliceDir)
                    self.SliceDirection=hSliceDir;
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