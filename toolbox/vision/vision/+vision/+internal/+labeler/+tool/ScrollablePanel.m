

classdef ScrollablePanel<handle

    properties(Abstract)



Items




ItemFactory
    end

    methods(Abstract)



        createItems(this)
    end


    properties(Access=protected)

Figure



FixedPanel


MovingPanel


VerticalSlider


HorizontalSlider



CornerFiller


        SliderHeightInPixels=18;
        SliderWidthInPixels=18;


HasVerticalSlider
HasHorizontalSlider

UseAppContainer
    end

    properties(Dependent)
Position
NumItems
SliderHeightInChar
SliderWidthInChar
    end

    properties(Constant)
        KeyboardUpDownScrollAmount=1;
        KeyboardPageUpDownScrollAmount=5;
        KeyboardHomeEndScrollAmount=Inf;
    end


    methods(Access=public)




        function p=getParentForItem(this)
            p=this.MovingPanel;
        end
    end


    methods

        function set.Position(this,value)
            this.FixedPanel.Position=max(0,value);
            this.update();
        end


        function value=get.Position(this)
            value=this.FixedPanel.Position;
        end


        function val=get.NumItems(this)
            val=numel(this.Items);
        end


        function val=get.SliderHeightInChar(this)
            val=pix2char(this,this.SliderHeightInPixels);
        end


        function val=get.SliderWidthInChar(this)
            val=pix2char(this,this.SliderWidthInPixels);
        end
    end


    methods

        function this=ScrollablePanel(parent,position)

            this.Figure=parent;
            this.UseAppContainer=this.useAppContainer();

            this.Figure.WindowKeyPressFcn=@this.keyboardScroll;

            if this.UseAppContainer
                this.MovingPanel=uipanel('Parent',this.Figure,...
                'BorderType','none',...
                'Title','',...
                'Units','Normalized',...
                'Position',position,...
                'Visible','off',...
                'Tag','MovingPanel',...
                'AutoResizeChildren','off');
                this.FixedPanel=this.MovingPanel;


                this.MovingPanel.Scrollable='on';
            else
                this.Figure.WindowScrollWheelFcn=@this.mouseScroll;

                this.FixedPanel=uipanel('Parent',this.Figure,...
                'BorderType','none',...
                'Title','',...
                'Units','Normalized',...
                'Position',position,...
                'Visible','off',...
                'Tag','FixedPanel');

                this.MovingPanel=uipanel('Parent',this.FixedPanel,...
                'BorderType','none',...
                'Title','',...
                'Units','Normalized',...
                'Position',[0,0,0,0],...
                'Visible','off',...
                'Tag','MovingPanel');
            end

            this.HasVerticalSlider=false;
            this.HasHorizontalSlider=false;
        end


        function show(this)
            set(this.MovingPanel,'Visible','on');

            if~this.UseAppContainer
                set(this.FixedPanel,'Visible','on');
            end
        end


        function c=pix2char(this,val)
            c=hgconvertunits(this.Figure,[val,0,0,0],'pixels','char',this.Figure);
            c=c(1);
        end


        function update(this)

            if this.NumItems<1
                return;
            end

            if~this.UseAppContainer
                this.MovingPanel.Units='char';

                parentPos=hgconvertunits(this.Figure,this.FixedPanel.Position,this.FixedPanel.Units,'char',this.Figure);

                sliderWidth=this.SliderWidthInChar;


                pos=this.getItemPixelPositions();



                movingPanelHeight=0;
                for i=this.NumItems:-1:1
                    itemPosition=hgconvertunits(this.Figure,pos(i,:),this.Items{i}.Units,this.MovingPanel.Units,this.Figure);

                    if this.Items{i}.Visible
                        movingPanelHeight=movingPanelHeight+itemPosition(4);
                    end
                end

                needsVerticalScroll=movingPanelHeight>parentPos(4);

                if needsVerticalScroll



                    parentPosInItemUnits=hgconvertunits(this.Figure,[0,0,parentPos(3)-sliderWidth,0],'char',this.Items{1}.Units,this.Figure);
                    parentWidth=parentPosInItemUnits(3);
                else
                    parentPosInItemUnits=hgconvertunits(this.Figure,this.FixedPanel.Position,this.FixedPanel.Units,this.Items{1}.Units,this.Figure);
                    parentWidth=parentPosInItemUnits(3);
                end

                layoutTop=0;

                for i=this.NumItems:-1:1


                    listPos=hgconvertunits(this.Figure,[0,layoutTop,1,1],this.MovingPanel.Units,this.Items{i}.Units,this.Figure);

                    this.Items{i}.Position(1)=0;
                    this.Items{i}.Position(2)=listPos(2);


                    adjustWidth(this.Items{i},parentWidth);


                    if this.Items{i}.Visible
                        itemPos=hgconvertunits(this.Figure,this.Items{i}.Position,...
                        this.Items{i}.Units,this.MovingPanel.Units,this.Figure);
                        layoutTop=layoutTop+itemPos(4);
                    end
                end


                this.MovingPanel.Position(4)=movingPanelHeight;
                this.MovingPanel.Position(2)=-(this.MovingPanel.Position(4)-parentPos(4));

                pos=this.getItemPixelPositions();
                [~,idx]=max(pos(:,3));
                pos=hgconvertunits(this.Figure,pos(idx,:),'pixels',this.MovingPanel.Units,this.Figure);
                maxItemWidth=pos(3);
                this.MovingPanel.Position(3)=maxItemWidth;




                for i=this.NumItems:-1:1
                    adjustHeight(this.Items{i},parentWidth);
                end


                pos=this.getItemPixelPositions();



                movingPanelHeight=0;

                for i=this.NumItems:-1:1
                    itemPosition=hgconvertunits(this.Figure,pos(i,:),this.Items{i}.Units,this.MovingPanel.Units,this.Figure);
                    if this.Items{i}.Visible
                        movingPanelHeight=movingPanelHeight+itemPosition(4);
                    end
                end

                layoutTop=0;


                for i=this.NumItems:-1:1


                    listPos=hgconvertunits(this.Figure,[0,layoutTop,1,1],this.MovingPanel.Units,this.Items{i}.Units,this.Figure);

                    this.Items{i}.Position(1)=0;
                    this.Items{i}.Position(2)=listPos(2);

                    if this.Items{i}.Visible
                        itemPos=hgconvertunits(this.Figure,this.Items{i}.Position,this.Items{i}.Units,this.MovingPanel.Units,this.Figure);
                        layoutTop=layoutTop+itemPos(4);
                    end
                end


                this.MovingPanel.Position(4)=movingPanelHeight;
                this.MovingPanel.Position(2)=-(this.MovingPanel.Position(4)-parentPos(4));

                needsVerticalScroll=movingPanelHeight>parentPos(4);




                if needsVerticalScroll
                    needsHorizontalScroll=this.MovingPanel.Position(3)>parentPos(3)-sliderWidth+1e-10;
                else
                    needsHorizontalScroll=this.MovingPanel.Position(3)>parentPos(3)+1e-10;
                end

                addScrollBarsIfNeeded(this,needsVerticalScroll,needsHorizontalScroll);


                this.MovingPanel.Position(3)=maxItemWidth;



                this.MovingPanel.Position(1)=0;

            else

                pos=this.getItemPixelPositions();




                movingPanelHeight=0;
                for i=this.NumItems:-1:1
                    itemPosition=hgconvertunits(this.Figure,pos(i,:),this.Items{i}.Units,this.MovingPanel.Units,this.Figure);

                    if this.Items{i}.Visible
                        movingPanelHeight=movingPanelHeight+itemPosition(4);
                    end
                end

                parentPosInItemUnits=hgconvertunits(this.Figure,this.FixedPanel.Position,this.FixedPanel.Units,this.Items{1}.Units,this.Figure);
                parentWidth=parentPosInItemUnits(3);



                layoutTop=max(this.MovingPanel.Position(4)-movingPanelHeight,0);



                itemWidth=parentWidth;

                for i=this.NumItems:-1:1


                    listPos=hgconvertunits(this.Figure,[0,layoutTop,1,1],this.MovingPanel.Units,this.Items{i}.Units,this.Figure);

                    this.Items{i}.Position(1)=0;
                    this.Items{i}.Position(2)=listPos(2);


                    adjustWidth(this.Items{i},itemWidth);
                    adjustHeight(this.Items{i},itemWidth);

                    if this.Items{i}.Visible
                        itemPos=hgconvertunits(this.Figure,this.Items{i}.Position,...
                        this.Items{i}.Units,this.MovingPanel.Units,this.Figure);
                        layoutTop=layoutTop+itemPos(4);
                    end
                end
            end

            cellfun(@(x)set(x.Panel,'Visible',x.Visible),this.Items);

        end




        function scrollTo(this,idx)

            if(this.UseAppContainer)
                if idx==1
                    scrollToTop(this);

                elseif idx==this.NumItems
                    scrollToBottom(this);
                else
                    itemPosition=getpixelposition(this.Items{idx}.Panel);
                    verticalScrollLoc=itemPosition(2);

                    scrollBarLoc=this.MovingPanel.ScrollableViewportLocation;
                    scroll(this.MovingPanel,scrollBarLoc(1),verticalScrollLoc);
                end
                drawnow;

            else
                if this.HasVerticalSlider
                    if idx==1
                        scrollToTop(this);

                    elseif idx==this.NumItems
                        scrollToBottom(this);

                    else
                        itemStepInSlider=(this.VerticalSlider.Max-this.VerticalSlider.Min)/this.NumItems;

                        amount=(this.NumItems-idx)*itemStepInSlider;

                        if this.HasHorizontalSlider
                            amount=amount+this.HorizontalSlider.Position(4);
                        end

                        if amount<=this.VerticalSlider.Max&&...
                            amount>=this.VerticalSlider.Min
                            this.VerticalSlider.Value=amount;
                        end
                    end
                    drawnow;
                end
            end
        end


        function horizontalScroll(this,varargin)
            if~(this.UseAppContainer)
                curPos=this.MovingPanel.Position;
                curPos(1)=-this.HorizontalSlider.Value;


                parentPos=hgconvertunits(this.Figure,this.FixedPanel.Position,this.FixedPanel.Units,'char',this.Figure);
                if~(abs(curPos(1))<this.MovingPanel.Position(3)-parentPos(3))

                    curPos(1)=-(this.MovingPanel.Position(3)-parentPos(3));
                end
                this.MovingPanel.Position=curPos;
            end
        end


        function verticalScroll(this,varargin)
            if~this.UseAppContainer
                if this.HasVerticalSlider
                    curPos=this.MovingPanel.Position;
                    curPos(2)=-this.VerticalSlider.Value;
                    this.MovingPanel.Position=curPos;
                end
            end
        end


        function mouseScroll(this,~,event)
            if~isempty(this.VerticalSlider)&&isvalid(this.VerticalSlider)
                amount=this.VerticalSlider.Value-event.VerticalScrollCount;
                amount=max(amount,this.VerticalSlider.Min);
                amount=min(amount,this.VerticalSlider.Max);
                this.VerticalSlider.Value=amount;
                this.verticalScroll();
            end
        end


        function scrollToTop(this)
            if(~this.UseAppContainer)
                if this.HasVerticalSlider
                    this.VerticalSlider.Value=this.VerticalSlider.Max;
                end

            else
                scroll(this.MovingPanel,'top');
            end
        end


        function scrollToBottom(this)
            if(~this.UseAppContainer)
                if this.HasVerticalSlider
                    this.VerticalSlider.Value=this.VerticalSlider.Min;
                    drawnow;
                end
            else
                drawnow;
                scroll(this.MovingPanel,'bottom');
            end
        end





        function tf=isItemVisible(this,idx)
            if isvalid(this.FixedPanel)
                panelPos=getpixelposition(this.FixedPanel,true);
            else
                tf=false;
                return
            end
            panelTop=panelPos(2)+panelPos(4)-1;
            panelBot=panelPos(2);

            if this.HasHorizontalSlider


                panelBot=panelBot+this.SliderHeightInPixels;
            end

            itemPos=getpixelposition(this.Items{idx},true);
            itemTop=itemPos(2)+itemPos(4)-1;
            itemBot=itemPos(2);

            if itemBot<panelBot||itemTop>panelTop
                tf=false;
            else
                tf=true;
            end
        end


        function[panelTop,panelBot]=getFixedPanelViewArea(this)


            panelPos=getpixelposition(this.FixedPanel,true);

            panelTop=panelPos(2)+panelPos(4)-1;
            panelBot=panelPos(2);

            if this.HasHorizontalSlider


                panelBot=panelBot+this.SliderHeightInPixels;
            end
        end


        function[panelTop,panelBot]=getMovingPanelLimits(this)


            panelPos=getpixelposition(this.MovingPanel,true);

            panelTop=panelPos(2)+panelPos(4)-1;
            panelBot=panelPos(2);
        end


        function keyboardScroll(this,~,event)


            if this.UseAppContainer
                pos=this.getItemPixelPositions();
                panelHeight=sum(pos(:,4));
                itemHeight=panelHeight/this.NumItems;
            else

                itemHeight=this.MovingPanel.Position(4)/this.NumItems;
            end

            switch event.Key
            case 'downarrow'
                scrollAmount=this.KeyboardUpDownScrollAmount*itemHeight;
            case 'uparrow'
                scrollAmount=-this.KeyboardUpDownScrollAmount*itemHeight;
            case 'pageup'
                scrollAmount=-this.KeyboardPageUpDownScrollAmount*itemHeight;
            case 'pagedown'
                scrollAmount=this.KeyboardPageUpDownScrollAmount*itemHeight;
            case 'home'
                scrollAmount=-this.KeyboardHomeEndScrollAmount;
            case 'end'
                scrollAmount=this.KeyboardHomeEndScrollAmount;
            otherwise

                return;
            end
            if this.UseAppContainer
                scrollBarLoc=this.MovingPanel.ScrollableViewportLocation;
                viewportLoc=getpixelposition(this.MovingPanel);
                viewportHeight=viewportLoc(4);
                maxVerticalScroll=panelHeight-viewportHeight;

                verticalScrollLoc=(scrollBarLoc(2)-scrollAmount);
                verticalScrollLoc=min(verticalScrollLoc,maxVerticalScroll);
                verticalScrollLoc=max(verticalScrollLoc,1);

                scroll(this.MovingPanel,scrollBarLoc(1),verticalScrollLoc);
            else
                if~isempty(this.VerticalSlider)&&isvalid(this.VerticalSlider)
                    amount=this.VerticalSlider.Value-scrollAmount;
                    amount=max(amount,this.VerticalSlider.Min);
                    amount=min(amount,this.VerticalSlider.Max);
                    this.VerticalSlider.Value=amount;
                    this.verticalScroll();
                end
            end
        end


        function addScrollBarsIfNeeded(this,needsVerticalScroll,needsHorizontalScroll)

            if this.HasVerticalSlider&&this.HasHorizontalSlider
                delete(this.CornerFiller);
            end

            if needsHorizontalScroll&&needsVerticalScroll

                parentPos=hgconvertunits(this.Figure,this.FixedPanel.Position,this.FixedPanel.Units,'pixels',this.Figure);
                pos=[];
                pos(1)=parentPos(3)-this.SliderWidthInPixels+1;
                pos(2)=0;
                pos(3)=this.SliderWidthInPixels;
                pos(4)=this.SliderHeightInPixels;
                hgconvertunits(this.Figure,pos,'char','pixels',this.Figure);
                this.CornerFiller=uipanel('Parent',this.FixedPanel,...
                'Units','pixels',...
                'Position',pos,...
                'BackgroundColor',[0.94,0.94,0.94],...
                'Tag','CornerFillerPanel');
            end

            if needsHorizontalScroll




                parentPos=hgconvertunits(this.Figure,this.FixedPanel.Position,this.FixedPanel.Units,'pixels',this.Figure);

                sliderPos=parentPos;

                if needsVerticalScroll
                    sliderPos(3)=parentPos(3)-this.SliderWidthInPixels;
                end

                sliderPos(2)=0;
                sliderPos(3)=max(0,sliderPos(3));
                sliderPos(4)=this.SliderHeightInPixels;
                sliderStep=[.1,1];

                parentPos=hgconvertunits(this.Figure,this.FixedPanel.Position,this.Figure.Units,this.MovingPanel.Units,this.Figure);

                if needsVerticalScroll
                    numExtraCharLines=this.MovingPanel.Position(3)-(parentPos(3)-this.SliderWidthInChar);
                else
                    numExtraCharLines=this.MovingPanel.Position(3)-parentPos(3);
                end

                if this.HasHorizontalSlider

                    this.HorizontalSlider.Units='pixels';
                    this.HorizontalSlider.Position=max(0,sliderPos);
                    this.HorizontalSlider.Units='char';
                    this.HorizontalSlider.Value=min(numExtraCharLines,this.HorizontalSlider.Value);
                    this.HorizontalSlider.Max=numExtraCharLines;
                else
                    this.HorizontalSlider=uicontrol('Style','Slider',...
                    'Parent',this.FixedPanel,...
                    'Units','pixels',...
                    'Min',0,...
                    'Value',0,...
                    'Callback',@this.horizontalScroll,...
                    'Position',sliderPos,...
                    'SliderStep',sliderStep);

                    this.HasHorizontalSlider=true;

                    this.HorizontalSlider.Units='char';

                    this.HorizontalSlider.Max=numExtraCharLines;
                end

                this.horizontalScroll();
            else
                if this.HasHorizontalSlider
                    delete(this.HorizontalSlider);
                    this.HasHorizontalSlider=false;
                end
            end

            if needsVerticalScroll



                parentPos=hgconvertunits(this.Figure,this.FixedPanel.Position,this.FixedPanel.Units,'pixels',this.Figure);

                sliderPos=parentPos;

                sliderPos(1)=sliderPos(3)-this.SliderWidthInPixels+1;
                sliderPos(3)=this.SliderWidthInPixels;

                if needsHorizontalScroll
                    sliderPos(2)=this.SliderHeightInPixels;
                    sliderPos(4)=max(0,sliderPos(4)-this.SliderHeightInPixels);
                else
                    sliderPos(2)=0;
                end

                sliderStep=[.1,1];
                parentPos=hgconvertunits(this.Figure,this.FixedPanel.Position,this.FixedPanel.Units,'char',this.Figure);
                numExtraCharLines=(this.MovingPanel.Position(4)-parentPos(4));
                if this.HasHorizontalSlider
                    minValue=-this.HorizontalSlider.Position(4);
                else
                    minValue=0;
                end

                if this.HasVerticalSlider

                    this.VerticalSlider.Units='pixels';
                    this.VerticalSlider.Position=sliderPos;
                    this.VerticalSlider.Units='char';

                    if this.VerticalSlider.Value==this.VerticalSlider.Max


                        this.VerticalSlider.Value=numExtraCharLines;
                    else
                        this.VerticalSlider.Value=min(numExtraCharLines,this.VerticalSlider.Value);
                    end

                    this.VerticalSlider.Min=minValue;
                    this.VerticalSlider.Max=numExtraCharLines;
                else
                    this.VerticalSlider=uicontrol('Style','Slider',...
                    'Parent',this.FixedPanel,...
                    'Units','pixels',...
                    'Min',minValue,...
                    'Callback',@this.verticalScroll,...
                    'Position',sliderPos,...
                    'SliderStep',sliderStep);

                    this.VerticalSlider.Units='char';
                    this.VerticalSlider.Max=numExtraCharLines;
                    this.VerticalSlider.Value=numExtraCharLines;

                    this.HasVerticalSlider=true;
                end
                this.verticalScroll();
            else
                if this.HasVerticalSlider
                    delete(this.VerticalSlider);
                    this.HasVerticalSlider=false;
                end
            end
        end


        function pos=getItemPixelPositions(this)


            panels=cellfun(@(x)x.Panel,this.Items);
            pos=[];
            for panelIdx=1:numel(panels)
                pos(panelIdx,:)=getpixelposition(panels(panelIdx));%#ok<AGROW>
            end
            if iscell(pos)
                pos=vertcat(pos{:});
            end
        end


        function tf=useAppContainer(~)
            tf=vision.internal.labeler.jtfeature('UseAppContainer');
        end
    end
end
