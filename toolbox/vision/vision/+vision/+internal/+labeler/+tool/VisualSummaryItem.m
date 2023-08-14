






classdef VisualSummaryItem<vision.internal.labeler.tool.ListItem

    properties(Constant,Hidden)
        MinWidth=150;
        ROILineWidth=2;
        SceneLineWidth=2;
        SliderLineWidth=2;
        ButtonSize=15;

        ROITypeBtnYLocation=0.85;
        SceneTypeBtnYLocation=0.75;

        ROICompareBtnYLocation=0.92;

        NumXTicks=8;
        NumYTicks=4;
    end

    properties(Hidden)
LabelName
LabelType
FigureHandle
Panel
Index
CheckBox
PrevUnlabeledTypeBtn
NextUnlabeledTypeBtn
UnlabeledText
AxisHandle
PlotHandle
SliderLine
PanelHeight
SignalName

        SceneCompareBtnYLocation=0.74;

        Visible=true;
    end

    events
CheckBoxClicked
ButtonPressed
    end

    methods


        function this=VisualSummaryItem(parent,idx,data)


            this.LabelName=data.Name;
            this.LabelType=data.Type;

            this.FigureHandle=ancestor(parent,'Figure');
            containerW=getContainerWidth(this,parent.Parent);
            containerWInPixels=hgconvertunits(this.FigureHandle,[0,0,containerW,0],'normalized','pixels',parent.Parent);
            panelW=max(this.MinWidth,containerWInPixels(3));

            this.PanelHeight=data.ItemHeight;
            this.Panel=uipanel('Parent',parent,'Units','pixels','Position',...
            [0,0,panelW,this.PanelHeight],'BorderType','none','Tag',...
            ['Panel_',this.LabelName],'HandleVisibility','callback',...
            'HighlightColor',[0,0,0]);


            minData=min(double(data.Data));
            maxData=max(double(data.Data));
            spacing=ceil(maxData/this.NumYTicks);

            if(data.Type==labelType.Scene)||(data.ComparisonMode==2)
                yTickLabelInt=0:1;
                yTickLabelStr={'false','true'};
            else
                if spacing==0
                    yTickLabelInt=0:1;
                else
                    yTickLabelInt=minData:spacing:(maxData+spacing);
                end
                yTickLabelStr=string(yTickLabelInt);
            end




            this.AxisHandle=axes(this.Panel,'YTick',yTickLabelInt,'YTickLabel',...
            yTickLabelStr,'XMinorTick','on','NextPlot','add','Box','on',...
            'XGrid','on','FontSize',8.5,'YGrid','on','HandleVisibility','callback');



            if data.ComparisonMode==1

                if data.SignalType==vision.labeler.loading.SignalType.PointCloud
                    text=vision.getMessage('vision:labeler:CuboidLabels');
                else
                    if isa(data.Time(end),'duration')
                        text=vision.getMessage('vision:labeler:ShapeLabels');
                    else
                        text=vision.getMessage('vision:labeler:RectangleAndLineLabels');
                    end
                end

                this.CheckBox=uicontrol('Parent',this.Panel,'Style','text',...
                'String',text,'Units','normalized',...
                'Position',[0.03,this.ROICompareBtnYLocation,0.5,0.05],...
                'FontWeight','bold','HorizontalAlignment','left',...
                'HandleVisibility','callback');
                this.AxisHandle.Position=[0.03,0.13,0.95,0.75];

                if(data.Type==labelType.Rectangle)||...
                    (data.Type==labelType.Line)||...
                    (data.Type==labelType.Polygon)||...
                    (data.Type==labelType.ProjectedCuboid)
                    this.PlotHandle=stairs(this.AxisHandle,data.Time,data.Data,...
                    'Color',data.Color,'LineWidth',this.ROILineWidth,...
                    'DisplayName',this.LabelName,'Tag',['Plot_',this.LabelName],...
                    'HandleVisibility','callback');
                end

                btnTag='ROICompareBtn';
                if~buttonExists(this,btnTag)
                    [this.PrevUnlabeledTypeBtn,this.NextUnlabeledTypeBtn]=addButtons(this,btnTag);
                end

                this.Panel.BorderType='beveledout';

            elseif data.ComparisonMode==2


                if data.LastSceneItem



                    this.PanelHeight=this.PanelHeight+100;
                    axHeight=this.Panel.Position(4)/(this.PanelHeight);
                    this.Panel.Position(4)=this.PanelHeight;
                    axesPosition=[0.03,(1-axHeight),0.95,axHeight-0.16];
                    textPosition=[0.03,0.88,0.5,0.1];
                    this.SceneCompareBtnYLocation=0.88;
                else
                    axesPosition=[0.03,0.00095,0.95,0.6];
                    textPosition=[0.03,0.65,0.5,0.3];
                end

                this.CheckBox=uicontrol('Parent',this.Panel,'Style','text',...
                'String',this.LabelName,'Units','normalized','Position',...
                textPosition,'FontWeight','bold','HorizontalAlignment',...
                'left','HandleVisibility','callback');

                this.AxisHandle.Position=axesPosition;
                yticklabels(this.AxisHandle,[]);

                if(data.Type==labelType.Scene)
                    this.PlotHandle=stairs(this.AxisHandle,data.Time,data.Data,...
                    'Color',data.Color,'LineWidth',this.SceneLineWidth,...
                    'Tag',['Plot_',this.LabelName],'HandleVisibility','callback');
                end

                btnTag='SceneCompareBtn';
                if~buttonExists(this,btnTag)
                    [this.PrevUnlabeledTypeBtn,this.NextUnlabeledTypeBtn]=addButtons(this,btnTag);
                end

            elseif data.ComparisonMode==3

                this.CheckBox=uicontrol('Parent',this.Panel,'Style','text',...
                'String',vision.getMessage('vision:labeler:PixelLabels'),...
                'Units','normalized','Position',[0.03,this.ROICompareBtnYLocation,0.5,0.05],...
                'FontWeight','bold','HorizontalAlignment','left',...
                'HandleVisibility','callback');
                this.AxisHandle.Position=[0.03,0.13,0.95,0.75];

                if(data.Type==labelType.PixelLabel)
                    this.PlotHandle=bar(this.AxisHandle,data.Time,data.Data,...
                    'stacked','Tag',['Plot_',this.LabelName],'HandleVisibility','callback');
                end

                btnTag='ROICompareBtn';

                if~buttonExists(this,btnTag)
                    [this.PrevUnlabeledTypeBtn,this.NextUnlabeledTypeBtn]=addButtons(this,btnTag);
                end

                this.Panel.BorderType='beveledin';
            else

                if(data.Type==labelType.Scene)
                    this.AxisHandle.Position=[0.03,0.22,0.95,0.44];
                    checkBoxPosition=[0.03,0.75,0.4,0.15];
                    tag='Scene_Checkbox';
                else
                    this.AxisHandle.Position=[0.13,0.15,0.95,0.65];
                    checkBoxPosition=[0.03,0.85,0.4,0.1];
                    tag='ROI_Checkbox';
                end

                this.CheckBox=uicontrol('Parent',this.Panel,'Style','checkbox',...
                'String',this.LabelName,'callback',@(varargin)this.checkBoxClicked,...
                'Units','normalized','Position',checkBoxPosition,'FontWeight','bold',...
                'HorizontalAlignment','left','Tooltip',vision.getMessage('vision:labeler:CheckBoxTooltip'),...
                'HandleVisibility','callback','FontSize',9,'Tag',tag);


                if(data.Type==labelType.Scene)
                    this.PlotHandle=stairs(this.AxisHandle,data.Time,data.Data,...
                    'Color',data.Color,'LineWidth',this.SceneLineWidth,...
                    'Tag',['Plot_',this.LabelName],'HandleVisibility','callback');
                    btnTag=['SceneTypeBtn_',this.LabelName];
                elseif(data.Type==labelType.PixelLabel)
                    this.PlotHandle=bar(this.AxisHandle,data.Time,data.Data,...
                    'FaceColor',data.Color,'Tag',['Plot_',this.LabelName],...
                    'HandleVisibility','callback');
                    btnTag=['PixelTypeBtn_',this.LabelName];
                else
                    this.PlotHandle=stairs(this.AxisHandle,data.Time,data.Data,...
                    'Color',data.Color,'LineWidth',this.ROILineWidth,...
                    'DisplayName',this.LabelName,'Tag',['Plot_',this.LabelName],...
                    'HandleVisibility','callback');
                    btnTag=['ShapeTypeBtn_',this.LabelName];
                end

                [this.PrevUnlabeledTypeBtn,this.NextUnlabeledTypeBtn]=addButtons(this,btnTag);
            end


            hold(this.AxisHandle,'on');
            if(data.Type==labelType.PixelLabel)

                yLimit=[0,1];
            else

                yLimit=get(this.AxisHandle,'ylim');
            end
            this.SliderLine=plot(this.AxisHandle,[data.CurrTime,data.CurrTime],...
            yLimit,'Color','k','LineWidth',this.SliderLineWidth,...
            'Tag',['Slider_',this.LabelName],'HandleVisibility','callback');

            xlim(this.AxisHandle,[data.Time(1),data.Time(end)]);

            if isa(data.Time(end),'duration')
                if seconds(data.Time(end))>=3600
                    fmt='hh:mm:ss';
                elseif seconds(data.Time(end))>=60
                    fmt='mm:ss';
                else
                    fmt='mm:ss.SS';
                end

                xtickformat(this.AxisHandle,fmt);
            end

            this.Index=idx;

            if data.ComparisonMode==1
                this.adjustYLimits(1);
            elseif data.ComparisonMode==2
                this.adjustYLimits(0,[0,1],false);
            elseif data.ComparisonMode==3

            else
                if(data.Type==labelType.Rectangle)||...
                    (data.Type==labelType.Line)||...
                    (data.Type==labelType.Polygon)||...
                    (data.Type==labelType.ProjectedCuboid)
                    this.adjustYLimits(1);
                else
                    this.adjustYLimits(0);
                end
            end

            if(data.Type==labelType.PixelLabel)

                set(this.AxisHandle,'YLimMode','manual')
                set(this.AxisHandle,'YLim',[0,1])
                set(this.AxisHandle,'YTickMode','manual')
                set(this.AxisHandle,'YTick',[0,0.25,0.5,0.75,1])
                set(this.AxisHandle,'YTickLabelRotation',-45)
                set(this.AxisHandle,'YTickLabel',{'  0%',' 25%',' 50%',' 75%','100%'},'FontSize',8)
                set(this.AxisHandle,'YGrid','on')
            end
        end


        function adjustWidth(this,parentWidth)
            this.Panel.Position(3)=max(this.MinWidth,parentWidth);


            y=hgconvertunits(this.FigureHandle,[5,0,0,0],'char','normalized',this.FigureHandle);
            axesStartPos=y(1);
            axesWidth=1-y(1)-0.02;
            this.AxisHandle.Position(1)=axesStartPos;
            if axesWidth>0
                this.AxisHandle.Position(3)=axesWidth;
            end


            adjustXTicks(this);

            adjustButtons(this);
        end


        function adjustHeight(this,~)
            this.Panel.Position(4)=this.PanelHeight;

            adjustButtons(this);
        end


        function adjustYLimits(this,offset,varargin)

            runYTickAdjust=true;

            if nargin==2
                yMin=0;
                yMax=max(max(this.PlotHandle.YData),1);
            else
                yLimits=varargin{1};
                yMin=yLimits(1);
                yMax=yLimits(2);

                if nargin==4
                    runYTickAdjust=varargin{2};
                end
            end

            ylim(this.AxisHandle,[yMin,yMax+offset]);

            this.SliderLine.YData=[yMin,yMax+offset];

            if runYTickAdjust
                adjustYTicks(this,offset);
            end
        end


        function adjustYTicks(this,offset)

            if offset==0
                set(this.AxisHandle,'YTickMode','manual');
                set(this.AxisHandle,'YTick',[0,1]);
                set(this.AxisHandle,'YTickLabel',{'F','T'});
            else
                yLimits=this.AxisHandle.YLim;
                maxValue=max((yLimits(2)-offset),0);
                spacing=ceil(maxValue/4);

                yTickLabelInt=yLimits(1):spacing:(yLimits(2)+spacing);
                yTickLabelStr=string(yTickLabelInt);

                set(this.AxisHandle,'YTickMode','manual');
                set(this.AxisHandle,'YTick',yTickLabelInt);
                set(this.AxisHandle,'YTickLabel',yTickLabelStr);
            end
        end


        function adjustXTicks(this)

            xLimits=this.AxisHandle.XLim;
            spacing=(xLimits(2)-xLimits(1))/this.NumXTicks;
            if~isa(spacing,'duration')
                spacing=max(round(spacing),1);
            end
            xTickLabelInt=xLimits(1):spacing:xLimits(2);
            xticks(this.AxisHandle,xTickLabelInt);
        end


        function delete(this)
            delete(this.Panel);
        end


        function modifyData(this,data)
            if ischar(data)
                this.LabelName=data;
                this.CheckBox.String=data;

                if ishandle(this.Panel)
                    this.Panel.Tag=['Panel_',data];
                end

                if ishandle(this.PlotHandle)
                    this.PlotHandle.DisplayName=data;
                    this.PlotHandle.Tag=['Plot_',data];
                end
            else

                if isprop(this.PlotHandle,'Color')

                    this.PlotHandle.Color=data;
                elseif isprop(this.PlotHandle,'FaceColor')

                    this.PlotHandle.FaceColor=data;
                end
            end
        end


        function modify(this,data)


            if(data.Type==labelType.Rectangle)||...
                (data.Type==labelType.Line)||...
                (data.Type==labelType.Polygon)||...
                (data.Type==labelType.ProjectedCuboid)
                this.PlotHandle(end+1)=stairs(this.AxisHandle,data.Time,data.Data,...
                'Color',data.Color,'LineWidth',this.ROILineWidth,...
                'Tag',['Plot_',data.Name],'HandleVisibility','callback');
            elseif(data.Type==labelType.PixelLabel)
                this.PlotHandle(end+1)=bar(this.AxisHandle,data.Time,data.Data,...
                'FaceColor',data.Color,'Tag',['Plot_',data.Name],...
                'HandleVisibility','callback');
            end
        end


        function unselect(~)
        end


        function select(~)
        end
    end

    methods(Access=private)


        function checkBoxClicked(this)

            data=vision.internal.labeler.tool.VisualSummaryEvent(this.CheckBox.Tag,this.CheckBox.Value,this.Index);
            notify(this,'CheckBoxClicked',data);
        end


        function[prevButton,nextButton]=addButtons(this,btnTag)

            if contains(btnTag,'SceneTypeBtn')
                yLocation=this.SceneTypeBtnYLocation;
                tooltipText=this.LabelName;
            elseif contains(btnTag,'ROICompareBtn')
                yLocation=this.ROICompareBtnYLocation;
                tooltipText=vision.getMessage('vision:labeler:ROI');
            elseif contains(btnTag,'SceneCompareBtn')
                yLocation=this.SceneCompareBtnYLocation;
                tooltipText=vision.getMessage('vision:labeler:Scene');
            else
                yLocation=this.ROITypeBtnYLocation;
                tooltipText=this.LabelName;
            end


            iconLocation=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+videoLabeler','+tool');
            prevUnlabeledIcon=fullfile(iconLocation,'topreviousframe.png');
            btnCData=imread(prevUnlabeledIcon);


            btnLocPixel=hgconvertunits(this.FigureHandle,[0.47,yLocation,0,0],'normalized','pixels',this.Panel);
            prevUnlabeledTypeBtnPos=[btnLocPixel(1),btnLocPixel(2),this.ButtonSize,this.ButtonSize];

            prevButton=uicontrol('parent',this.Panel,...
            'Style','pushbutton','String','',...
            'Units','pixels','Position',prevUnlabeledTypeBtnPos,...
            'callback',@(varargin)this.buttonPressCallback(true),...
            'Tooltip',vision.getMessage('vision:labeler:PrevUnlabeledLabelName',tooltipText),...
            'HandleVisibility','callback','CData',btnCData,'Tag',[btnTag,'_left']);


            nextUnlabeledIcon=fullfile(iconLocation,'tonextframe.png');
            btnCData=imread(nextUnlabeledIcon);

            nextUnlabeledTypeBtnPos=[btnLocPixel(1)+20,btnLocPixel(2),this.ButtonSize,this.ButtonSize];

            nextButton=uicontrol('parent',this.Panel,...
            'Style','pushbutton','String','',...
            'Units','pixels','Position',nextUnlabeledTypeBtnPos,...
            'callback',@(varargin)this.buttonPressCallback(false),...
            'Tooltip',vision.getMessage('vision:labeler:NextUnlabeledLabelName',tooltipText),...
            'HandleVisibility','callback','CData',btnCData,'Tag',[btnTag,'_right']);
        end


        function adjustButtons(this)


            if~isempty(this.PrevUnlabeledTypeBtn)
                btnTag=this.PrevUnlabeledTypeBtn.Tag;
                if contains(btnTag,'SceneTypeBtn')
                    yLocation=this.SceneTypeBtnYLocation;
                elseif contains(btnTag,'ROICompareBtn')
                    yLocation=this.ROICompareBtnYLocation;
                elseif contains(btnTag,'SceneCompareBtn')
                    yLocation=this.SceneCompareBtnYLocation;
                else
                    yLocation=this.ROITypeBtnYLocation;
                end

                btnLocPixel=hgconvertunits(this.FigureHandle,[0.47,yLocation,0,0],'normalized','pixels',this.Panel);
                prevUnlabeledTypeBtnPos=[btnLocPixel(1),btnLocPixel(2),this.ButtonSize,this.ButtonSize];
                nextUnlabeledTypeBtnPos=[btnLocPixel(1)+20,btnLocPixel(2),this.ButtonSize,this.ButtonSize];
                this.PrevUnlabeledTypeBtn.Position=prevUnlabeledTypeBtnPos;
                this.NextUnlabeledTypeBtn.Position=nextUnlabeledTypeBtnPos;

            end
        end


        function TF=buttonExists(this,btnTag)
            TF=~isempty(findall(this.FigureHandle,'Tag',[btnTag,'_left']));
        end


        function buttonPressCallback(this,isLeftBtnPressed)
            isCompareBtn=contains(this.PrevUnlabeledTypeBtn.Tag,'Compare');
            data=vision.internal.labeler.tool.VisualSummaryButtonPressEvent(isLeftBtnPressed,isCompareBtn,false,this.LabelType,this.LabelName,this.SignalName);
            notify(this,'ButtonPressed',data);
        end


        function containerW=getContainerWidth(this,parent)
            containerW=parent.Position(3);
        end
    end
end