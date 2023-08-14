classdef LineVisual<matlabshared.scopes.visual.AxesVisual




    properties(SetAccess=protected,SetObservable)
        Lines;
    end

    properties(Hidden)
        Plotter;
        StyleDialog;
    end

    properties(Access=protected)
        InsideYTicks;
        InsideXTicks;
        AxesContextMenu=-1;
        LimitListener;
        ScopeCloseListener;
        ScopeVisibleListener;
    end

    events





        DisplayUpdated;




        DisplayShowContentUpdated;
    end

    methods
        function this=LineVisual(varargin)

            this@matlabshared.scopes.visual.AxesVisual(varargin{:});
        end

        function close(this)



            delete(this.StyleDialog);
            this.StyleDialog=[];
        end

        function xlim=calculateXLim(this)



            xyz=getXYZExtents(this);
            xlim=[xyz(1,1),xyz(1,2)];
        end

        function channelNames=getChannelNames(this)


            channelNames=this.Plotter.ChannelNames;
        end

        function hideStyleDialog(this)


            this.StyleDialog.Visible=false;
        end

        function updatePropertySet(this,varargin)


            axesPropNames={'Color'...
            ,'XColor','YColor','ZColor'...
            ,'XGrid','YGrid','ZGrid'...
            ,'Box'...
            ,'XScale','YScale','ZScale'...
            ,'XDir','YDir','ZDir'...
            ,'XTickMode','YTickMode','ZTickMode'...
            ,'XTick','YTick','ZTick'...
            ,'XTickLabelMode','YTickLabelMode','ZTickLabelMode'...
            ,'XTickLabel','YTickLabel','ZTickLabel'...
            ,'FontName','FontSize','FontUnits','FontWeight'};

            hAxes=this.Axes;



            axesProperties=cell2struct(get(hAxes,axesPropNames),axesPropNames,2);

            if strcmp(axesProperties(1,1).XTickMode,'auto')
                axesProperties=rmfield(axesProperties,'XTick');
            end
            if strcmp(axesProperties(1,1).YTickMode,'auto')
                axesProperties=rmfield(axesProperties,'YTick');
            end
            if strcmp(axesProperties(1,1).ZTickMode,'auto')
                axesProperties=rmfield(axesProperties,'ZTick');
            end
            if strcmp(axesProperties(1,1).XTickLabelMode,'auto')
                axesProperties=rmfield(axesProperties,'XTickLabel');
            end
            if strcmp(axesProperties(1,1).YTickLabelMode,'auto')
                axesProperties=rmfield(axesProperties,'YTickLabel');
            end
            if strcmp(axesProperties(1,1).ZTickLabelMode,'auto')
                axesProperties=rmfield(axesProperties,'ZTickLabel');
            end



            axesProperties(1,1).Title=get(get(hAxes(1,1),'Title'),'String');
            axesProperties(1,1).XLabel=get(get(hAxes(1,1),'XLabel'),'String');
            axesProperties(1,1).YLabel=get(get(hAxes(1,1),'YLabel'),'String');
            axesProperties(1,1).ZLabel=get(get(hAxes(1,1),'ZLabel'),'String');

            axesProperties(2,1).Title=get(get(hAxes(1,2),'Title'),'String');
            axesProperties(2,1).XLabel=get(get(hAxes(1,2),'XLabel'),'String');
            axesProperties(2,1).YLabel=get(get(hAxes(1,2),'YLabel'),'String');
            axesProperties(2,1).ZLabel=get(get(hAxes(1,2),'ZLabel'),'String');

            if nargin<2
                hConfig=this.Configuration;
            else
                hConfig=varargin{:};
            end


            setValue(hConfig.pPropertySet,'AxesProperties',axesProperties);

            lineVisual_updatePropertyDb(this,varargin{:});
        end

        function lineVisual_updatePropertyDb(this,hConfig)





            hLines=this.Lines;
            if isempty(hLines)
                return;
            end


            defaultProps=this.getDefaultLineProperties;



            linePropNames=fieldnames(defaultProps);


            lineProperties=getPropertyValue(this,'LineProperties');

            if isempty(lineProperties)


                lineProperties=defaultProps;
            end

            userChannelNames=this.Plotter.UserDefinedChannelNames;

            for indx=1:numel(hLines)


                lineProperties(indx)=cell2struct(get(hLines(indx),linePropNames),...
                linePropNames,2);



                if indx<=numel(userChannelNames)
                    lineProperties(indx).DisplayName=userChannelNames{indx};
                else
                    lineProperties(indx).DisplayName='';
                end
            end


            lineProperties=lineProperties(1:numel(hLines));

            if nargin<2
                hConfig=this.Configuration;
            end
            pSet=hConfig.pPropertySet;


            setValue(pSet,'LineProperties',lineProperties,true);



            setValue(pSet,'UserDefinedChannelNames',userChannelNames);
        end

        function updateStyle(this,action)




            updateOutput(this.StyleDialog);
            op=this.StyleDialog.Output;


            figureColorChanged=false;
            if~isempty(op.FigureColor)

                set(get(this.Axes(1,1),'Parent'),'BackgroundColor',op.FigureColor);


                hApp=this.Application;
                generalUIExt=hApp.getExtInst('Core','General UI');
                setPropertyValue(generalUIExt,'FigureColor',op.FigureColor);
                figureColorChanged=true;
            end


            axesColorChanged=false;
            if~isempty(op.AxesColor)
                set(this.Axes,'Color',op.AxesColor);


                updatePropertySet(this);
                axesColorChanged=true;
            end


            axesTickColorChanged=false;
            if~isempty(op.AxesTickColor)
                set(this.Axes(1,1),'XColor',op.AxesTickColor,'YColor',...
                op.AxesTickColor,'ZColor',op.AxesTickColor);
                set(this.Axes(1,2),'XColor',op.AxesTickColor,'YColor',...
                op.AxesTickColor,'ZColor',op.AxesTickColor);


                updatePropertySet(this);
                axesTickColorChanged=true;
            end


            hLines=this.Lines;
            if any(op.LineDirty)
                lp=struct;
                for k=find(op.LineDirty)
                    lp.Color=op.LineColors{k};
                    lp.LineStyle=op.LineStyles{k};
                    lp.LineWidth=op.LineWidths{k};
                    lp.Marker=op.MarkerStyles{k};
                    lp.Visible=op.LineVisible{k};
                    set(hLines(k),lp);
                end

                lineVisual_updatePropertyDb(this);

                notify(this,'DisplayUpdated');
            end

            if axesColorChanged||axesTickColorChanged||figureColorChanged
                updateLegend(this);

                notify(this,'DisplayUpdated');
            end


            if axesTickColorChanged
                onAxesTickColorChanged(this.Plotter);
            end

            if strcmpi(action,'ok')
                hideStyleDialog(this);
            else


                op.DisplayNames={'1'};
                updateInput(this.StyleDialog,op);
            end
        end

        function updateXAxisLimits(this)


            if this.getPropertyValue('AutoDisplayLimits')
                xlim=calculateXLim(this);
            else
                xlim=[evalPropertyValue(this,'MinXLim'),evalPropertyValue(this,'MaxXLim')];
                if xlim(1)>xlim(2)
                    return;
                end
            end



            l=get(this,'LimitListener');
            uiservices.setListenerEnable(l,false);


            set(this.Axes,'XLim',xlim);


            uiservices.setListenerEnable(l,true);
        end

        function updateYAxisLimits(~)


        end

        function updateYLabel(~)


        end
    end

    methods(Hidden)
        function setup(this,hVisParent)



            this.ScopeCloseListener=addlistener(this.Application,...
            'Close',@(h,ed)close(this));


            this.ScopeVisibleListener=uiservices.addlistener(this.Application.Parent,...
            'Visible','PostSet',@(h,ed)onScopeVisibleChange(this));

            hAxes(1,1)=axes(...
            'Tag','VisualAxes',...
            'Parent',hVisParent,...
            'OuterPosition',[0,0,1,1],...
            'Layer','bottom',...
            'NextPlot','add',...
            'Visible','On');

            set(hAxes(1,1),'Toolbar',[]);

            disableDefaultInteractivity(hAxes(1,1));

            hAxes(1,2)=axes(...
            'Tag','VisualAxes',...
            'Parent',hVisParent,...
            'OuterPosition',[0,0,1,0.5],...
            'Layer','bottom',...
            'NextPlot','add',...
            'Visible','off');

            set(hAxes(1,2),'Toolbar',[]);

            disableDefaultInteractivity(hAxes(1,2));

            axesProps=getPropertyValue(this,'AxesProperties');

            if~isempty(axesProps)
                for idx=1:size(axesProps,2)
                    xlabel(hAxes(1,idx),axesProps(1,idx).XLabel,'Color',axesProps(1,idx).XColor);
                    ylabel(hAxes(1,idx),axesProps(1,idx).YLabel,'Color',axesProps(1,idx).XColor);
                    zlabel(hAxes(1,idx),axesProps(1,idx).ZLabel,'Color',axesProps(1,idx).XColor);
                    title(hAxes(1,idx),axesProps(1,idx).Title,'Color',axesProps(1,idx).XColor);
                end
                set(hAxes,rmfield(axesProps,{'XLabel','YLabel','ZLabel','Title','FontName'}));
            end

            this.Axes=hAxes;
            hgaddbehavior(hAxes,uiservices.getPlotEditBehavior('select'));

            updateGrid(this);

            set(hAxes,'Box','On');
            updateYAxisLimits(this);
            ylabel(hAxes(1,1),getPropertyValue(this,'YLabel'));
            ylabel(hAxes(1,2),getPropertyValue(this,'YLabel'));


            hAxes(1,2).YLabel.Rotation=-90;
            hAxes(1,2).YLabel.VerticalAlignment='top';
            onResize(this);


            createAxesContextMenu(this);

            this.LimitListener=[];
        end

        function propertyChanged(this,eventData)


            if~ischar(eventData)
                eventData=get(eventData.AffectedObject,'Name');
            end

            switch lower(eventData)
            case 'grid'
                updateGrid(this);
            case{'legend','linenames'}
                updateLegend(this);
            case 'compact'
                updateAxesLocation(this);
            case{'minylim','maxylim'}
                if ishghandle(this.Axes)
                    updateYAxisLimits(this);
                    onResize(this);
                end
            case{'minxlim','maxxlim','autodisplaylimits'}
                if ishghandle(this.Axes)
                    updateXAxisLimits(this);
                    onResize(this);
                end
            case 'lineproperties'
                updateLineProperties(this);
            case 'ylabel'
                updateYLabel(this);
            case 'axesproperties'
                ap=getPropertyValue(this,'AxesProperties');
                for idx=1:size(ap,2)

                    set(this.Axes(1,idx),'Color',ap(idx,1).Color);
                    set(this.Axes(1,idx),'XColor',ap(idx,1).XColor,...
                    'YColor',ap(idx,1).XColor,...
                    'ZColor',ap(idx,1).XColor);
                    set(get(this.Axes(1,idx),'XLabel'),'Color',ap(idx,1).XColor)
                    set(get(this.Axes(1,idx),'YLabel'),'Color',ap(idx,1).YColor)
                end

            case 'userdefinedchannelnames'
                updateChannelNames(this);
            end
        end

        function onResize(~)



        end

        function updateGrid(this)


            grid=uiservices.logicalToOnOff(getPropertyValue(this,'Grid'));

            hAxes=this.Axes;
            if ishghandle(hAxes)
                set(hAxes,'YGrid',grid,'XGrid',grid);
            end
        end

        function updateLegend(~)



        end

        function updateLineProperties(this)


            hLine=this.Lines;
            lineProperties=getPropertyValue(this,'LineProperties');

            if~isempty(lineProperties)
                lineProperties=rmfield(lineProperties,'DisplayName');
            end

            for indx=1:length(hLine)
                if indx<=numel(lineProperties)
                    props=lineProperties(indx);
                    set(hLine(indx),props);
                end
            end
        end

        function updateChannelNames(this)
            userChannelNames=getPropertyValue(this,'UserDefinedChannelNames');
            this.Plotter.UserDefinedChannelNames=userChannelNames;
        end

        function createAxesContextMenu(this)

            this.AxesContextMenu=uicontextmenu('Parent',this.Application.Parent,...
            'Callback',@(h,~)onAxesContextMenuOpening(this,h));
            set(this.Axes,'UIContextMenu',this.AxesContextMenu);
        end

        function onAxesContextMenuOpening(this,h)
            hStyleCM=findobj(h,'Tag','LineVisualDisplayStyle');
            if isempty(hStyleCM)

                uimenu(h,...
                'Label',uiscopes.message('DisplayPropertiesContextMenuLabel'),...
                'Tag','LineVisualOptions',...
                'Callback',@(hcbo,ev)editOptions(this));


                hStyleCM=uimenu(h,...
                'Label',[getString(message('Spcuilib:scopes:Style')),' ...'],...
                'Tag','LineVisualDisplayStyle',...
                'Callback',@(hcbo,ev)showStyleDialog(this));
            end
            set(hStyleCM,'Enable',uiservices.logicalToOnOff(~isempty(this.Lines)));
        end

        function editOptions(this)
            this.Application.ExtDriver.editOptions(this);
        end
    end

    methods(Static)
        function hPropDb=getPropertySet(varargin)
            hPropDb=matlabshared.scopes.visual.AxesVisual.getPropertySet(...
            'Grid','bool',true,...
            'Legend','bool',false,...
            'Compact','bool',false,...
            'AutoDisplayLimits','bool',true,...
            'MinXLim','string','0',...
            'MaxXLim','string','1',...
            'YLabel','string','Amplitude',...
            'MinYLim','string','-10',...
            'MaxYLim','string','10',...
            'UserDefinedChannelNames','mxArray',{''},...
            'LineProperties','mxArray',[],...
            varargin{:});
        end

        function defaultProps=getDefaultLineProperties


            defaultProps.DisplayName='';
            defaultProps.Color=get(0,'DefaultLineColor');
            defaultProps.LineStyle=get(0,'DefaultLineLineStyle');
            defaultProps.LineWidth=get(0,'DefaultLineLineWidth');
            defaultProps.Marker=get(0,'DefaultLineMarker');
            defaultProps.MarkerSize=get(0,'DefaultLineMarkerSize');
            defaultProps.MarkerEdgeColor=get(0,'DefaultLineMarkerEdgeColor');
            defaultProps.MarkerFaceColor=get(0,'DefaultLineMarkerFaceColor');
            defaultProps.Visible=get(0,'DefaultLineVisible');
        end
    end

    methods(Access=protected)
        function cleanup(this)


            cleanup@matlabshared.scopes.visual.AxesVisual(this);

            if ishghandle(this.AxesContextMenu)
                delete(this.AxesContextMenu);
            end


            delete(this.StyleDialog);
            this.StyleDialog=[];
        end

        function updateAxesLocation(this)

            newValue=getPropertyValue(this,'Compact');


            hMenu=findobj(this.AxesContextMenu,'Tag','LineVisualCompactDisplay');
            set(hMenu,'Checked',uiservices.logicalToOnOff(newValue));


            hGUI=getGUI(this.Application);
            hMenu=findwidget(hGUI,'Menus','View','LineVisual','Compact');
            set(hMenu,'Checked',uiservices.logicalToOnOff(newValue));


            onResize(this);

            if newValue
                positionProp='Position';
            else
                positionProp='OuterPosition';
            end

            set(this.Axes,'Units','Normalized',positionProp,[0,0,1,1]);
        end

        function onScopeVisibleChange(this)




            if strcmpi(get(this.Application.Parent,'Visible'),'off')
                if~isempty(this.StyleDialog)
                    this.StyleDialog.Visible=false;
                end
            end
        end
    end
end
