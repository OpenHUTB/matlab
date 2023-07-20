classdef IntensityVisual<matlabshared.scopes.visual.AxesVisual




    properties
        DialogMgr=[];
        hImage=[]
        hColorBar=[];
Menus
    end
    properties(Access=protected)
SourceListeners
ViewerListeners
    end

    properties(Access=private)
        pLastTime;
        pAutoScaled=true;
        YAxisMultiplier=1;
        YAxisUnits='s';
    end




    properties(SetAccess=protected,SetObservable)
        Lines;
    end

    events





        DisplayUpdated;




        DisplayShowContentUpdated;
    end

    methods

        function this=IntensityVisual(varargin)

            this@matlabshared.scopes.visual.AxesVisual(varargin{:});
            hApp=this.Application;

            this.SourceListeners=...
            event.listener(hApp,'SourceRun',@this.onSourceRun);

        end




        function ret=isCCDFMode(~)
            ret=false;
        end

        function ret=hasValidAxes(~)
            ret=true;
        end
        function ret=isSpectrogramMode(~)
            ret=true;
        end
        function definition=getZDefinition(~)



            definition.Type='Power';
            definition.Units='W';
            definition.Multiplier=1;
        end

        function definition=getYDefinition(this)

            definition.Type='Time';
            definition.Units=this.YAxisUnits;
            definition.Multiplier=this.YAxisMultiplier;
        end

        function definition=getXDefinition(~)

            definition.Type='X';
            definition.Units='';
            definition.Multiplier=1;
        end

        function[xData,yData,zData]=getSpectrogramData(this)





            xData=[];
            yData=[];
            zData=[];

            img=this.hImage;
            if~isempty(img)&&ishghandle(img)
                xData=get(img,'XData');
                yData=get(img,'YData');
                zData=get(img,'CData');
            end

        end
        function color=getSpectrogramColor(this,cDataValue)




            colorMap=colormap(this.Axes);
            nColors=size(colorMap,1);
            cLim=get(this.Axes,'CLim');
            iColor=floor(((cDataValue-cLim(1))/diff(cLim))*nColors)+1;
            iColor=min(nColors,max(iColor,1));
            color=colorMap(iColor,:);

        end
        function color=getSpectrogramContrastColor(this)




            hsv=rgb2hsv(colormap(this.Axes));

            threshold=mean(hsv(:,3));
            if threshold<.9
                color=[1,1,1];
            else
                color=[0,0,0];
            end

        end



        function update(this)


            src=this.Application.DataSource;



            currentTime=src.getTimeOfDisplayData;


            dims=getMaxDimensions(src);
            st=getSampleTimes(src);
            beginTime=this.pLastTime+st;

            dataSt=getData(src,beginTime,currentTime,1);
            data=dataSt.values;
            if isempty(data)
                return;
            end



            bufferedInputs=size(data,2);


            numOfNewFrames=dims(2)*bufferedInputs;
            data=fliplr(data);
            data=reshape(data,dims(1),numOfNewFrames);

            cdt=this.hImage.CData;
            maxNumOfFrames=size(cdt,1);
            if numOfNewFrames<maxNumOfFrames
                cdt=[data.';cdt(1:end-numOfNewFrames,:)];
            else
                cdt=data(:,1:maxNumOfFrames).';
            end


            this.hImage.CData=cdt;

            if(this.pLastTime==-st)



                this.Axes.CLim;
                this.Axes.CLimMode='manual';
            end
            this.pLastTime=currentTime;
        end


    end

    methods(Static)
        function hSet=getPropertySet
            hSet=matlabshared.scopes.visual.AxesVisual.getPropertySet(...
            'TimeResolution','string','10e-4',...
            'HistoryDepth','string','.01',...
            'Title','string','',...
            'YLabel','string','Time History (%ss)  \\rightarrow',...
            'XLabel','string','',...
            'XData','string','1:10',...
            'IntensityUnit','string','dB',...
...
            'Grid','bool',true,...
...
            'ColorMap','string','parula(256)',...
            'MaxColorLim','string','20',...
            'MinColorLim','string','-80'...
            );
        end
    end

    methods(Hidden)
        function renderWidgets(this)
            hScope=this.Application;

            setup(this,getVisualizationParent(hScope));

        end

        function propertyChanged(this,eventData)
            if~ischar(eventData)
                eventData=get(eventData.AffectedObject,'Name');
            end
            switch eventData
            case 'Title'
                this.Axes.Title.String=getPropertyValue(this,'Title');
            case 'IntensityUnit'
                if~isempty(this.hColorBar)
                    this.hColorBar.Title.String=getPropertyValue(this,'IntensityUnit');
                end
            case 'XLabel'
                xLabel=getPropertyValue(this,'XLabel');
                if isempty(xLabel)
                    xLabel=' ';
                end
                this.Axes.XLabel.String=xLabel;
            case 'Grid'
                grid=uiservices.logicalToOnOff(getPropertyValue(this,'Grid'));
                set(this.Axes,'YGrid',grid,'XGrid',grid);
            case 'ColorMap'



                if~isempty(this.hColorBar)
                    value=evalPropertyValue(this,'ColorMap');
                    set(ancestor(this.Axes,'figure'),'ColorMap',value);
                    this.hColorBar.Title.Color=...
                    uiservices.getContrastColor(value(end,:));
                end

            case{'MinColorLim','MaxColorLim'}
                if~isempty(this.hColorBar)
                    colorLim=[evalPropertyValue(this,'MinColorLim'),...
                    evalPropertyValue(this,'MaxColorLim')];
                    set(this.Axes,'CLim',[colorLim(1),colorLim(2)]);
                end

            end
        end
        function setup(this,hVisParent)
            setup@matlabshared.scopes.visual.AxesVisual(this,hVisParent);
        end
        function b=showScreenMessageForEmptyData(~)
            b=true;
        end
        function setupAxis(this)
            source=this.Application.DataSource;
            if isempty(source)||source.State.isInRapidAcceleratorAndNotRunning||isDataEmpty(source)
                return
            end
            st=getSampleTimes(source);
            timeResolution=evalPropertyValue(this,'TimeResolution');
            this.pLastTime=-st;
            historyDepth=evalPropertyValue(this,'HistoryDepth');

            xData=evalPropertyValue(this,'XData');
            yData=0:timeResolution:historyDepth;

            ax=this.Axes;
            if~isempty(this.hImage)
                set(this.hImage,'XData',xData,'YData',yData,'CData',nan(length(yData),length(xData)));
                halfDeltaX=(xData(2)-xData(1))/2;
                ax.XLim=[xData(1)-halfDeltaX,xData(end)+halfDeltaX];
                halfDeltaY=(yData(2)-yData(1))/2;
                ax.YLim=[yData(1)-halfDeltaY,yData(end)+halfDeltaY];
                return;
            end



            hParent=get(ax,'Parent');



            ax.NextPlot='replace';
            axRot=ax;
            this.hImage=...
            imagesc(xData,yData,...
            nan(size(yData,2),size(xData,2)),...
            'Parent',axRot);

            axesProps=getPropertyValue(this,'AxesProperties');



            if~isempty(axesProps)
                xLabel=getPropertyValue(this,'XLabel');
                yLabel=getPropertyValue(this,'YLabel');

                if isempty(xLabel)
                    xLabel=' ';
                end

                xlabel(ax,xLabel,'Color',axesProps.XColor);
                ylabel(ax,yLabel,'Color',axesProps.XColor);
                zlabel(ax,axesProps.ZLabel,'Color',axesProps.XColor);

                title(ax,'','Color',axesProps.XColor);
                if isfield(axesProps,'YTickLabel')

                    axesProps=rmfield(axesProps,...
                    {'YTickLabelMode','YTickLabel'});
                end
                set(ax,rmfield(axesProps,{'XLabel','YLabel','ZLabel',...
                'Title','FontName'}));
            end

            map=evalPropertyValue(this,'ColorMap');
            set(ancestor(this.Axes,'figure'),'ColorMap',map);
            if strcmp(this.Axes.CLimMode,'manual')
                colorLim=[evalPropertyValue(this,'MinColorLim'),...
                evalPropertyValue(this,'MaxColorLim')];
                set(this.Axes,'CLim',[colorLim(1),colorLim(2)]);
            end


            if~isempty(this.hColorBar)
                return;
            end

            c=colorbar(ax,...
            'location','northoutside','tag','MViewerColorBar');
            set(c,'XAxisLocation','top');
            set(c,'UIContextMenu',[]);
            this.hColorBar=c;


            txtColor=get(get(ax,'XLabel'),'Color');
            set(c,'XColor',txtColor);
            fs=get(ax,'FontSize');
            set(c,'FontSize',fs);
            set(c,'FontName',get(c,'FontName'));
            this.hColorBar=c;
            set(ax,'Units','pixels');
            set(c,'Units','pixels');
            ti=get(ax,'TightInset');
            ti(3)=ti(1);
            set(ax,'LooseInset',ti*1.1);
            aPos=ax.Position;
            c.Position(4)=c.Position(4)/1.5;
            aPos(4)=ax.Position(4)-aPos(2)-20;
            ax.Position=aPos;
            set(ax.Title,'Units','pixels');


            titleColor=map(end,:);
            titleColor=uiservices.getContrastColor(titleColor);
            tit=c.Title;
            tit.Color=titleColor;
            tit.String=getPropertyValue(this,'IntensityUnit');
            tit.Units='pixels';
            tit.VerticalAlignment='middle';
            tit.HorizontalAlignment='right';
            tit.Position=[c.Position(3),c.Position(4)/2];
            tit.Units='normalized';



            parentPosition=getpixelposition(hParent);
            ti=get(ax,'TightInset');leftInset=ti(1);

            axisDeltaDims=parentPosition(3:4)-ax.Position(3:4)-[leftInset,0];
            cbarDeltaDims=parentPosition(3:4)-c.Position([3,2]);
            szChangedFcn={@onResize,ax,c,axisDeltaDims,cbarDeltaDims};
            hParent.SizeChangedFcn=szChangedFcn;

            leftPos=ax.Position(1)-leftInset;
            onUpdateYTickLabels(this,leftPos);
            this.ViewerListeners=...
            [addlistener(ax,'SizeChanged',@(~,~)onUpdateYTickLabels(this,leftPos)),...
            addlistener(ax,'YLim','PostSet',@(~,~)onUpdateYTickLabels(this,leftPos)),...
            addlistener(ax,'Parent','PostSet',@(~,~)onUpdateAxesParent(this,szChangedFcn))];


            ax.Title.String=getPropertyValue(this,'Title');
        end
        function reset(this)
            this.pLastTime=-getSampleTimes(this.Application.DataSource);
            this.hImage.CData=nan(size(this.hImage.CData));
        end

        function b=shouldFlushBuffer(~)
            b=true;
        end
        function extents=getDataExtents(this,~)
            if~isempty(this.hImage)
                this.pAutoScaled=true;
                extents.C=[min(this.hImage.CData(:)),max(this.hImage.CData(:))];
            else
                extents.C=[nan,nan];
            end
        end
        function[pAxes,sAxes]=getPlotNavigationAxes(~)
            pAxes='C';
            sAxes='';
        end

        function onSourceRun(this,~,~)

            setupAxis(this);

        end
        function onUpdateAxesParent(this,szChangedFcn)





            if strcmp(this.Axes.Parent.Tag,'DPVerticalPanel_hBodyPanel')
                this.Axes.Parent.Parent.Parent.Parent.SizeChangedFcn='';
            end
            this.Axes.Parent.SizeChangedFcn=szChangedFcn;
        end
        function onUpdateYTickLabels(this,leftPos)
            label='Y';
            ax=this.Axes;
            [~,tickMultiplier,unitsDisplay]=engunits(ax.([label,'Lim']),'unicode');
            this.YAxisMultiplier=tickMultiplier;
            this.YAxisUnits=sprintf('%ss',unitsDisplay);
            ticks=ax.([label,'Tick'])*tickMultiplier;
            tickLabels=num2str(ticks',4);
            [this.ViewerListeners.Enabled]=deal(false);
            ax.([label,'TickLabel'])=tickLabels;
            labelStr=getPropertyValue(this,'YLabel');
            ax.([label,'Label']).String=sprintf(labelStr,unitsDisplay);

            ti=get(ax,'TightInset');
            newPos=leftPos+ti(1);

            ax.Position(3)=ax.Position(3)-(newPos-ax.Position(1));

            ax.Position(1)=newPos;
            this.hColorBar.Position([1,3])=ax.Position([1,3]);
            [this.ViewerListeners.Enabled]=deal(true);
        end
        function renderMenus(this)
            if~isempty(this.Menus)
                return;
            end

            h=this.Application.Handles;

            this.Menus.properties=uimenu(h.viewMenu,...
            'Tag','uimgr.uimenu_Properties',...
            'Position',1,...
            'Label',uiscopes.message('DisplayPropertiesLabel'),...
            'Callback',@(~,~)onEditOptions(this));
        end
        function onEditOptions(this)


            if this.pAutoScaled
                this.pAutoScaled=false;

                newCLim=get(this.Axes,'CLim');
                setPropertyValue(this,'MinColorLim',sprintf('%.5g',newCLim(1)),...
                'MaxColorLim',sprintf('%.5g',newCLim(2)),true);
            end
            editOptions(this.Application.ExtDriver,this);
        end
        function optionsDialogTitle=getOptionsDialogTitle(~,~)

            optionsDialogTitle=getString(message('phased:scopes:ConfigurationDialogTitle'));
        end

        function propsSchema=getPropsSchema(this,~)



            hCfg=this.Config;
            [title_lbl,title]=uiscopes.getWidgetSchema(hCfg,'Title','edit',1,1);



            grid=uiscopes.getWidgetSchema(hCfg,'Grid','checkbox',2,1);
            [xlbl_lbl,xlbl]=uiscopes.getWidgetSchema(hCfg,'XLabel','edit',3,1);
            ilabel=getString(message('phased:scopes:IntensityUnitLabel'));
            [ilbl_lbl,ilbl]=extmgr.getWidgetSchema(hCfg,'IntensityUnit',ilabel,'edit',4,1);

            [cm_lbl,cm]=uiscopes.getWidgetSchema(hCfg,'ColorMap','combobox',5,1);
            cm.Entries={'parula(256)','jet(256)','hot(256)','bone(256)','cool(256)','copper(256)','gray(256)'};

            [minClim_lbl,minClim]=uiscopes.getWidgetSchema(hCfg,'MinColorLim','edit',6,1);
            [maxClim_lbl,maxClim]=uiscopes.getWidgetSchema(hCfg,'MaxColorLim','edit',7,1);


            propsSchema.Type='group';
            propsSchema.Items={...
            title_lbl,title,...
            grid,...
            xlbl_lbl,xlbl,...
            ilbl_lbl,ilbl,...
            cm_lbl,cm,...
            minClim_lbl,minClim,...
            maxClim_lbl,maxClim};


            propsSchema.LayoutGrid=[5,2];
            propsSchema.RowStretch=[zeros(1,4),1];
            propsSchema.Name=uiscopes.message('DisplayPropertiesTabLabel');
        end
        function varargout=validate(this,hDlg)

            b=true;
            exception=MException.empty;
            [b,exception]=validateDisplayProps(this,hDlg,b,exception);
            if nargout
                varargout={b,exception};
            elseif~b
                rethrow(exception);
            end
        end
    end

end

function onResize(hfig,~,a,c,axisDeltaDims,cbarDeltaDims)

    parentPosition=getpixelposition(hfig);
    ti=get(a,'TightInset');
    figWH=parentPosition(3:4);
    axisWH=figWH-axisDeltaDims-[ti(1),0];



    cbarWH=figWH-cbarDeltaDims;
    if any(axisWH<0)
        a.Visible='off';
        c.Visible='off';
    else
        a.Visible='on';
        c.Visible='on';
        a.Position(3:4)=axisWH;

        c.Position([3,2])=[axisWH(1),cbarWH(2)];
        map=colormap(a);
        titleColor=map(end,:);
        titleColor=uiservices.getContrastColor(titleColor);
        c.Title.Color=titleColor;
        a.Title.Position=[a.Position(3)/2,c.Position(2),a.Title.Position(3)];
    end

end


function[b,exception]=validateDisplayProps(this,hDlg,b,exception)


    cb=matlabshared.scopes.Validator.Limit;

    if b

        [b,exception,minColorLim]=validateLimWidgetValue(this,hDlg,'MinColorLim','MinColorLim',cb);
    end
    if b

        [b,exception,maxColorLim]=validateLimWidgetValue(this,hDlg,'MaxColorLim','MaxColorLim',cb);
    end

    if b&&(minColorLim>=maxColorLim)
        b=false;
        [msg,id]=uiscopes.message('InvalidCLim');
        exception=MException(id,msg);
    end
end


function[b,exception,val]=validateLimWidgetValue(this,hDlg,tag,messageTag,validator)



    fulltag=[hDlg.getSource.Register.Name,tag];
    variable=hDlg.getWidgetValue(fulltag);

    [val,errid,errmsg]=evaluateVariable(this.Application,variable);

    if~isempty(errid)
        b=false;
        exception=MException(errid,errmsg);
    elseif~validator(val)

        b=false;
        [msg,id]=uiscopes.message(['Invalid',messageTag]);
        exception=MException(id,msg);
    else
        b=true;
        exception=MException.empty;
    end
end
