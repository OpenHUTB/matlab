classdef Summary<handle&matlab.mixin.SetGet




    events

SummaryClicked

    end


    properties

        Enabled(1,1)logical=false;

        Empty(1,1)logical=true;

        BackgroundColor(1,3)single=[0,0,0];

        EmptyColor(1,3)single=[0.94,0.94,0.94];

        PopulatedColor(1,3)single=[0.5,0.5,0.5];

    end

    properties(Dependent)
SummaryVisible
    end


    properties(Access=private,Hidden,Transient)

        SummaryListener event.listener
        SelectionListener event.listener

        Height(1,1)double{mustBePositive}=20;

        IndicatorHeight(1,1)double{mustBePositive}=2;

    end


    properties(GetAccess={?images.uitest.factory.Tester,...
        ?uitest.factory.Tester},...
        SetAccess=private,Transient)

        Panel matlab.ui.container.Panel

        SummaryHandle matlab.graphics.primitive.Image

        IndicatorHandle matlab.graphics.primitive.Image

    end


    methods




        function self=Summary(hParent,pos)


            hFig=ancestor(hParent,'figure');
            if isa(getCanvas(hFig),'matlab.graphics.primitive.canvas.HTMLCanvas')

                if~isempty(hFig.Theme)
                    emptyColor=hFig.Theme.ContainerColor;
                else
                    emptyColor=[0.94,0.94,0.94];
                end

            else
                emptyColor=[0.94,0.94,0.94];
            end
            self.EmptyColor=emptyColor;

            self.Height=pos(4);

            self.Panel=uipanel('Parent',hParent,...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'Position',pos,...
            'BackgroundColor',self.EmptyColor,...
            'Tag','SummaryPanel',...
            'AutoResizeChildren','off');

            ax=axes(self.Panel,'Position',[0,0,1,1]);

            self.SummaryHandle=image(zeros([pos(3),pos(4),3],'uint8'),'Parent',ax,'Visible','off');
            self.SummaryListener=event.listener(self.SummaryHandle,'Hit',@(src,evt)clickCallback(self,evt));

            set(ax,'Box','on','XTick',[],'YTick',[],'Color',[0.94,0.94,0.94],'Visible','off','Toolbar',[]);
            disableDefaultInteractivity(ax);

            ax=axes(self.Panel,'Position',[0,0,1,1]);

            self.IndicatorHandle=image(zeros([pos(3),pos(4),3],'uint8'),'Parent',ax,'Visible','off');
            self.SelectionListener=event.listener(self.IndicatorHandle,'Hit',@(src,evt)clickCallback(self,evt));

            set(ax,'Box','on','XTick',[],'YTick',[],'Color',[0.94,0.94,0.94],'Visible','off','Toolbar',[]);
            disableDefaultInteractivity(ax);

            setAxesPosition(self);

        end




        function draw(self,data,color)

            if~isempty(self.SummaryHandle)

                if isempty(color)
                    img=repmat(self.EmptyColor,[numel(data),1]);
                else
                    img=repmat(self.BackgroundColor,[numel(data),1]);
                    img(data==1,:)=repmat(self.PopulatedColor,[sum(data==1),1]);
                    img(data==2,:)=repmat(color,[sum(data==2),1]);
                end

                img=reshape(img,[1,size(img,1),3]);

                isResetRequired=~isequal(size(img),size(self.SummaryHandle.CData));

                self.SummaryHandle.CData=img;

                if isResetRequired
                    xLim=get(self.SummaryHandle,'XData')+[-0.5,0.5];
                    yLim=get(self.SummaryHandle,'YData')+[-0.5,0.5];
                    set(self.SummaryHandle.Parent,'XLim',xLim,'YLim',yLim);
                end

            end

        end




        function drawIndicator(self,currentSlice,maxSlice)

            if~isempty(self.IndicatorHandle)

                img=repmat(self.BackgroundColor,[maxSlice,1]);
                img(currentSlice,:)=[0.349,0.667,0.847];

                img=reshape(img,[1,size(img,1),3]);

                isResetRequired=~isequal(size(img),size(self.IndicatorHandle.CData));

                self.IndicatorHandle.CData=img;

                if isResetRequired
                    xLim=get(self.IndicatorHandle,'XData')+[-0.5,0.5];
                    yLim=get(self.IndicatorHandle,'YData')+[-0.5,0.5];
                    set(self.IndicatorHandle.Parent,'XLim',xLim,'YLim',yLim);
                end

            end

        end




        function resize(self,pos)

            if~isequal(self.Panel.Position,pos)
                self.Panel.Position=pos;
                setAxesPosition(self);
            end

        end




        function clear(self)

            self.SummaryHandle.CData=ones([100,1,3],'uint8')*240;
            self.IndicatorHandle.CData=ones([100,1,3],'uint8')*240;
            self.Enabled=false;
            self.Empty=true;

        end




        function setPanelTag(self,tag)
            self.Panel.Tag=tag;
        end

    end


    methods(Access=private)


        function clickCallback(self,evt)

            if~self.Enabled||evt.Button~=1
                return;
            end

            notify(self,'SummaryClicked',images.internal.app.segmenter.volume.events.SliderMovingEventData(...
            round(evt.Source.Parent.CurrentPoint(1,1)),[]));

        end



        function setAxesPosition(self)

            sumPos=[self.Height,self.IndicatorHeight+1,self.Panel.Position(3)-(2*self.Height),...
            self.Panel.Position(4)-self.IndicatorHeight];

            indPos=[self.Height,1,...
            self.Panel.Position(3)-(2*self.Height),self.IndicatorHeight];

            if any(sumPos<0)||any(indPos<0)
                return;
            end

            set(self.SummaryHandle.Parent,'Units','pixels','Position',sumPos);
            set(self.IndicatorHandle.Parent,'Units','pixels','Position',indPos);

        end


        function updateEmptyState(self)

            if self.Empty
                set(self.SummaryHandle,'Visible','off');
                set(self.IndicatorHandle,'Visible','off');
                set(self.Panel,'BackgroundColor',self.EmptyColor);
            else
                set(self.SummaryHandle,'Visible','on');
                set(self.IndicatorHandle,'Visible','on');
                set(self.Panel,'BackgroundColor',self.BackgroundColor);
            end

        end

    end


    methods




        function set.Enabled(self,TF)

            if TF
                self.SummaryListener.Enabled=true;%#ok<MCSUP>
                self.SelectionListener.Enabled=true;%#ok<MCSUP>
            else
                self.SummaryListener.Enabled=false;%#ok<MCSUP>
                self.SelectionListener.Enabled=false;%#ok<MCSUP>
            end

            self.Enabled=TF;

        end




        function set.SummaryVisible(self,TF)
            self.SummaryHandle.Visible=TF;
            self.IndicatorHandle.Visible=TF;
        end




        function set.Empty(self,TF)

            self.Empty=TF;
            updateEmptyState(self);

        end




        function set.BackgroundColor(self,color)

            self.BackgroundColor=color;
            updateEmptyState(self);

        end




        function set.EmptyColor(self,color)

            self.EmptyColor=color;
            updateEmptyState(self);

        end

    end


end