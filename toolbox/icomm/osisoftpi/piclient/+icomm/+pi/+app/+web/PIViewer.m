classdef PIViewer<icomm.pi.app.Container
    properties(GetAccess=public,SetAccess=public,Dependent)
        PIClient icomm.pi.Client
    end

    properties(GetAccess=public,SetAccess=private)

        StartDateSelector icomm.pi.app.web.DateSelector

        EndDateSelector icomm.pi.app.web.DateSelector

        TagSelector icomm.pi.app.web.TagSelector

        RightBox matlab.ui.container.GridLayout

        ChartGallery icomm.pi.app.web.ChartGallery

        Chart icomm.pi.app.charts.Chart

        CollapseButton matlab.ui.control.Button

        OverlayMenu matlab.ui.container.Menu
    end


    properties(GetAccess=private,Constant)
        LeftBoxWidth=600
    end

    properties(GetAccess=private,SetAccess=private)
        PIClient_ icomm.pi.Client
        Listeners(1,:)event.listener
    end


    methods

        function value=get.PIClient(this)
            value=this.PIClient_;
        end


        function set.PIClient(this,value)
            this.PIClient_=value;

            this.updateAllAvailableTags();
        end

    end


    methods(Access=public)

        function this=PIViewer(varargin)

            fakeParent=uifigure(...
            'Visible','off',...
            'Tag',icomm.pi.app.Container.TemporaryFigureTag);
            box=uigridlayout(...
            'Parent',fakeParent);
            this@icomm.pi.app.Container(box,varargin{:});

            this.initializeMenu();
        end

    end


    methods(Access=protected)

        function initialize(this)

            this.OverlayMenu=uimenu(...
            'Parent',[],...
            'Text','Overlay plots',...
            'Checked',true,...
            'MenuSelectedFcn',@this.onOverlayChanged);

            this.UiContainer.ColumnWidth={this.LeftBoxWidth,20,'1x'};
            this.UiContainer.RowHeight={'1x'};
            leftBox=uigridlayout(...
            'Parent',this.UiContainer,...
            'Padding',0,...
            'RowHeight',{21,'1x'},...
            'ColumnWidth',{'1x'});
            this.CollapseButton=uibutton('push',...
            'Parent',this.UiContainer,...
            'Text','<',...
            'ButtonPushedFcn',@this.onCollapse);
            this.RightBox=uigridlayout(...
            'Parent',this.UiContainer,...
            'Padding',0,...
            'RowHeight',{icomm.pi.app.web.ChartGallery.Height,'1x'},...
            'ColumnWidth',{'1x'});

            dateBox=uigridlayout(...
            'Parent',leftBox,...
            'Padding',0,...
            'ColumnWidth',{'1x','1x'},...
            'RowHeight',{'1x'});
            this.StartDateSelector=icomm.pi.app.web.DateSelector(...
            'Parent',dateBox,...
            'Label','Start Date:',...
            'Datetime',datetime('now','TimeZone',icomm.pi.internal.defaultTimeZone())-days(1));
            this.Listeners(end+1)=event.listener(this.StartDateSelector,...
            'DatetimeChanged',@this.onDateChanged);
            this.EndDateSelector=icomm.pi.app.web.DateSelector(...
            'Parent',dateBox,...
            'Label','End Date:');
            this.Listeners(end+1)=event.listener(this.EndDateSelector,...
            'DatetimeChanged',@this.onDateChanged);
            this.TagSelector=icomm.pi.app.web.TagSelector(...
            'Parent',leftBox);
            this.Listeners(end+1)=event.listener(this.TagSelector,...
            'SelectedTagsChanged',@this.onSelectedTagChanged);

            this.ChartGallery=icomm.pi.app.web.ChartGallery(...
            'Parent',this.RightBox);
            this.Listeners(end+1)=event.listener(this.ChartGallery,...
            'ChartTypeChanged',@this.onChartTypeChanged);
            this.Listeners(end+1)=event.listener(this.TagSelector,...
            'SelectedTagOrderChanged',@this.onSelectedTagChanged);

            this.updateDateSelectorLimits();
            this.updateChartType();
        end

    end


    methods(Access=private)

        function initializeMenu(this)
            menu=uimenu(...
            'Parent',ancestor(this.UiContainer,'figure'),...
            'Text','Option');
            this.OverlayMenu.Parent=menu;
        end


        function update(this)
            tags=this.TagSelector.SelectedTags;
            if~isempty(this.PIClient_)

                values=this.PIClient_.getRecordedValues(tags,'From',this.StartDateSelector.Datetime,'To',this.EndDateSelector.Datetime);
                tags=cellstr(tags);
                tags=matlab.lang.makeValidName(tags);
                safeTagNames=tags;
                for ii=1:numel(tags)

                    if(strlength(tags(ii))>56)
                        tagName=convertStringsToChars(tags{ii});
                        tagName=tagName(1:end-7);
                        safeTagNames{ii}=tagName;
                    end
                end
                if~isempty(values)
                    this.Chart.Data=values(:,safeTagNames);
                end
                this.updateChartOverlay();
            end
        end


        function updateAllAvailableTags(this)
            this.TagSelector.AllAvailableTags=this.PIClient_.tags(Name='*');
            this.update();
        end


        function updateDateSelectorLimits(this)
            this.StartDateSelector.Limits(2)=this.EndDateSelector.Datetime;

            this.EndDateSelector.Limits(1)=this.StartDateSelector.Datetime;
        end


        function updateChartType(this)
            delete(this.Chart);
            layoutPosition=matlab.ui.layout.GridLayoutOptions(...
            'Row',2,...
            'Column',1);
            this.Chart=icomm.pi.app.charts.(this.ChartGallery.SelectedChartType)(...
            'GraphicsType','web',...
            'Parent',this.RightBox,...
            'Layout',layoutPosition);
            this.update();
        end


        function updateChartOverlay(this)
            this.Chart.Overlay=this.OverlayMenu.Checked=="on";
        end


        function onCollapse(this,varargin)
            switch this.CollapseButton.Text
            case '<'
                this.UiContainer.ColumnWidth{1}=0;
                this.CollapseButton.Text='>';
            case '>'
                this.UiContainer.ColumnWidth{1}=this.LeftBoxWidth;
                this.CollapseButton.Text='<';
            end
        end


        function onDateChanged(this,varargin)
            this.updateDateSelectorLimits();
            this.update();
        end


        function onSelectedTagChanged(this,varargin)
            this.update();
        end


        function onChartTypeChanged(this,varargin)
            this.updateChartType();
        end


        function onOverlayChanged(this,varargin)
            if this.OverlayMenu.Checked=="on"
                this.OverlayMenu.Checked='off';
            else
                this.OverlayMenu.Checked='on';
            end
            this.updateChartOverlay();
        end

    end

end