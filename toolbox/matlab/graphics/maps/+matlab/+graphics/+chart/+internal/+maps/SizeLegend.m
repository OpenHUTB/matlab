classdef SizeLegend<handle







    properties(Transient)
ColorList
SizeDataGreaterThanLimits
SizeDataLessThanLimits
SizeLimits
WidthRange
Alpha
LineWidth
TitleString
FontName
FontSize
        Visible='on'
PositionInPoints
Parent
        UpperRightMargin=[5,5]
    end

    properties(Access=?tSizeLegend,Hidden)
LegendAxes
    end

    properties(Access=private,Transient)
Axes
PlotBoxInPoints
TitleStringHandle
TitleLineHandle
    end

    properties(Access=private,Constant)
        FontSizeMultiplier=.9
    end

    methods
        function obj=SizeLegend(chartAxes)
            obj.Axes=chartAxes;
            ax=matlab.graphics.axis.Axes;
            ax.Visible='off';
            ax.HandleVisibility='off';
            ax.Tag='SizeLegend';
            ax.Units='normalized';
            ax.Position=[0,0,1,1];
            disableAxesBehavior(ax)
            obj.LegendAxes=ax;


            obj.FontName=get(groot,'FactoryAxesFontName');
            obj.FontSize=get(groot,'FactoryAxesFontSize');
        end


        function delete(obj)
            if isgraphics(obj.LegendAxes)&&isvalid(obj.LegendAxes)
                delete(obj.LegendAxes)
            end
        end


        function node=getNode(obj)

            node=obj.LegendAxes;
        end


        function resetLegend(obj)
            if isgraphics(obj.LegendAxes)
                delete(obj.LegendAxes.Children)
            end
            handleNames=["TitleStringHandle","TitleLineHandle"];
            for k=1:length(handleNames)
                obj.(handleNames{k})=[];
            end
        end


        function constructSizeLegend(obj,updateState)



            if nargin<2
                updateState=[];
            end
            if isempty(obj.Parent)&&isempty(updateState)
                obj.Parent=gcf;
            end


            updateLegend(obj,updateState);



            setLegendAxesVisibility(obj)
        end


        function updateLegend(obj,updateState)

            resetLegend(obj)

            if nargin<2
                updateState=[];
            end


            Font.Size=obj.FontSize;
            Font.Name=obj.FontName;
            handles=makeSizeLegend(...
            obj.LegendAxes,obj.SizeDataGreaterThanLimits,...
            obj.SizeDataLessThanLimits,obj.SizeLimits,...
            obj.WidthRange,obj.ColorList,obj.Alpha,obj.LineWidth,...
            obj.TitleString,Font,updateState);


            obj.TitleStringHandle=handles.TitleStringHandle;
            obj.TitleLineHandle=handles.TitleLineHandle;

        end


        function set.FontSize(obj,fontSize)
            fontSize=obj.FontSizeMultiplier*fontSize;
            obj.FontSize=fontSize;
        end


        function set.Parent(obj,parent)
            obj.LegendAxes.Parent=parent;%#ok<MCSUP>
        end


        function parent=get.Parent(obj)
            parent=obj.LegendAxes.Parent;
        end


        function set.PositionInPoints(obj,positionInPoints)


            setPlotBoxToPoints(obj);
            obj.LegendAxes.Position=positionInPoints;%#ok<MCSUP>
            obj.PositionInPoints=positionInPoints;
        end


        function set.TitleString(obj,title)
            obj.TitleString=title;
            if isgraphics(obj.TitleStringHandle)%#ok<MCSUP>
                obj.TitleStringHandle.String=title;%#ok<MCSUP>
                setTitleStringVisibility(obj);
            end
        end


        function set.Visible(obj,visible)
            obj.Visible=visible;
            setLegendAxesVisibility(obj);
        end


        function pbPoints=get.PlotBoxInPoints(obj)



            vp=setPlotBoxToPoints(obj);
            pbPoints=vp.Position;
        end


        function vp=setPlotBoxToPoints(obj)


            ax=obj.Axes;
            li=ax.GetLayoutInformation();
            vp=ax.Camera.Viewport;
            vp.Units='pixels';
            vp.Position=li.PlotBox;
            vp.Units='points';
        end


        function sz=getPreferredSize(obj)
            setPlotBoxToPoints(obj);
            pos=obj.LegendAxes.Position;
            sz=pos(3:4);
        end


        function updateSizeLegendObject(obj,prefSize)



            if strcmp(obj.Visible,'on')






                if isempty(obj.Parent)&&nargin<3
                    obj.Parent=gcf;
                end

                pbPoints=obj.PlotBoxInPoints;
                plotboxUpperRight=[pbPoints(1)+pbPoints(3),pbPoints(2)+pbPoints(4)];



                legUpperRight=plotboxUpperRight-obj.UpperRightMargin;
                legPrefSize=prefSize;
                legLowerLeft=[...
                legUpperRight(1)-legPrefSize(1),...
                legUpperRight(2)-legPrefSize(2)];
                legPosPoints=[legLowerLeft,legPrefSize];
                obj.PositionInPoints=legPosPoints;
            end
        end


        function prefSize=ensureTitleWithinLegend(obj,prefSize,updateState)



            t=obj.TitleStringHandle;
            if~isempty(t)
                try
                    titleExtent=getStringBounds(updateState,...
                    t.String,matlab.graphics.general.Font(...
                    'Name',t.FontName,...
                    'Size',t.FontSize/obj.FontSizeMultiplier,...
                    'Weight',t.FontWeight),...
                    t.Interpreter,t.FontSmoothing);
                catch e


                    interpreter='none';
                    if strcmp(e.identifier,'MATLAB:hg:textutils:StringSyntaxError')
                        titleExtent=getStringBounds(updateState,...
                        t.String,matlab.graphics.general.Font(...
                        'Name',t.FontName,...
                        'Size',t.FontSize/obj.FontSizeMultiplier,...
                        'Weight',t.FontWeight),...
                        interpreter,t.FontSmoothing);
                    end
                end

                if titleExtent(1)>prefSize(1)
                    prefSize(1)=titleExtent(1);
                end
            end
        end


        function pos=getPixelPosition(obj)
            pos=matlab.graphics.chart.internal.getOrangeChartChildPixelPosition(obj.LegendAxes);
        end
    end

    methods(Access=private)

        function setLegendAxesVisibility(obj)
            visible=obj.Visible;
            obj.LegendAxes.Visible=visible;
            children=obj.LegendAxes.Children;
            if isgraphics(children)
                set(children,'Visible',visible);
            end



            setTitleStringVisibility(obj)
        end

        function setTitleStringVisibility(obj)
            if isgraphics(obj.TitleStringHandle)
                title=obj.TitleStringHandle.String;
                if isempty(title)
                    visible='off';
                else
                    visible=obj.Visible;
                end
                obj.TitleStringHandle.Visible=visible;
                obj.TitleLineHandle.Visible=visible;
            end
        end

    end
end

function handles=makeSizeLegend(ax,sizeDataGreaterThanLimits,...
    sizeDataLessThanLimits,sizeLimits,widthRange,...
    colorList,colorAlpha,lineWidth,title,Font,updateState)

    colorList=colorList(1,:);
    diameters=linspace(widthRange(1),widthRange(2),4)';
    space=6;
    gap=2;

    x=space+0.5*diameters(4)+zeros(size(diameters));

    y=space+[
    [0.5,0,0,0]*diameters
    [1.0,0.5,0,0]*diameters+gap
    [1.0,1.0,0.5,0]*diameters+2*gap
    [1.0,1.0,1.0,0.5]*diameters+3*gap];

    sizeLimitsEqual=sizeLimits(1)==sizeLimits(2)|isnan(sizeLimits);
    needsGreaterOrLessThan=...
    sizeDataGreaterThanLimits|sizeDataLessThanLimits;
    if all([sizeLimitsEqual,~needsGreaterOrLessThan])
        diameters=sum(widthRange.*[13/15,2/15]);
        x=space+0.5*diameters;
        y=space+0.5*diameters;
    end

    sp=matlab.graphics.chart.primitive.Scatter('Parent',ax,...
    'XData',x,'YData',y,'SizeData',diameters.^2,...
    'CData',colorList);
    sp.MarkerFaceColor=colorList;
    sp.MarkerFaceAlpha=colorAlpha;
    sp.LineWidth=lineWidth;

    sp.MarkerEdgeColor=[.9999,.9999,.9999];
    sp.MarkerEdgeAlpha=1;

    lowerSizeLimit=formatSizeLegendLabel(sizeLimits(1));
    upperSizeLimit=formatSizeLegendLabel(sizeLimits(2));
    if sizeDataLessThanLimits
        leqchar='{\leq}';
        lowerSizeLimit=[leqchar,lowerSizeLimit];
    end
    if sizeDataGreaterThanLimits
        geqchar='{\geq}';
        upperSizeLimit=[geqchar,upperSizeLimit];
    end


    if~isempty(updateState)
        smoothing='on';
        interpreter='tex';
        lowerLimitTextSize=updateState.getStringBounds(...
        lowerSizeLimit,matlab.graphics.general.Font(...
        'Name',Font.Name,'Size',Font.Size),...
        interpreter,smoothing);
        upperLimitTextSize=updateState.getStringBounds(...
        upperSizeLimit,matlab.graphics.general.Font(...
        'Name',Font.Name,'Size',Font.Size),...
        interpreter,smoothing);

        xtextsize=max(lowerLimitTextSize(1),upperLimitTextSize(1));
        ytextsize=lowerLimitTextSize(2);
    else

        xtextsize=10;
        ytextsize=12;
    end









    if all([sizeLimitsEqual,~needsGreaterOrLessThan])

        ylimits=[0,2*space+diameters];
        yscale=ylimits+[space+diameters/2,-(space+diameters/2)];


        dscaling=max([widthRange(1)/80,0.20]);

        xscale=space+diameters+2*space*dscaling+[0,10*dscaling];
        xlimits=[0,2*space+diameters+xtextsize+diff(xscale)+gap];
    else

        ylimits=[0,2*space+3*gap+sum(diameters)];
        yscale=...
        ylimits+[space+diameters(1)/2,-(space+diameters(4)/2)];


        dscaling=max([widthRange(2)/80,0.20]);

        xscale=space+diameters(4)+2*space*dscaling+[0,10*dscaling];
        xlimits=...
        [0,2*space+diameters(4)+xtextsize+2*diff(xscale)+gap];
    end


    ylimits(1)=min(ylimits(1),yscale(1)-ytextsize/2);
    ylimits(2)=max(ylimits(2),yscale(2)+ytextsize/2);


    ax.Units='points';
    ax.Position=[1,1,diff(xlimits),diff(ylimits)];
    ax.XLim=xlimits;
    ax.YLim=ylimits;
    ax.Box='on';
    ax.XTick=[];
    ax.YTick=[];

    if any([~sizeLimitsEqual,needsGreaterOrLessThan])
        line(ax,xscale([2,1,1,2]),yscale([1,1,2,2]),...
        'Color',[128,128,128]/255,'LineWidth',1)
    end

    if all([sizeLimitsEqual,~needsGreaterOrLessThan])
        text(ax,space/2+xscale([1,1]),yscale,...
        {lowerSizeLimit},'FontName',Font.Name,'FontSize',Font.Size)
    else
        text(ax,space/2+xscale([2,2]),yscale,...
        {lowerSizeLimit,upperSizeLimit},'FontName',Font.Name,...
        'FontSize',Font.Size)
    end

    handles=makeSizeLegendTitle(ax,title,xlimits,ylimits,Font,updateState);
end


function handles=makeSizeLegendTitle(ax,title,xlimits,ylimits,Font,updateState)




    handles=struct(...
    'TitleStringHandle',[],...
    'TitleLineHandle',[]);


    if~isempty(title)

        if ischar(title)
            if isrow(title)
                numrows=1;
                showTitle=~isempty(strtrim(title));
            else

                title=cellstr(string(title));
                numrows=length(title);
                showTitle=any(cellfun(@(t)~isempty(strtrim(t)),title));
            end
        else

            numrows=length(title);
            showTitle=any(cellfun(@(t)~isempty(strtrim(t)),title));
        end
    else
        showTitle=false;
    end

    if showTitle

        if~isempty(updateState)
            smoothing='on';
            try
                interpreter='tex';
                titleExtent=getStringBounds(updateState,...
                title,matlab.graphics.general.Font(...
                'Name',Font.Name,'Size',Font.Size,'Weight','bold'),...
                interpreter,smoothing);
            catch e


                if strcmp(e.identifier,'MATLAB:hg:textutils:StringSyntaxError')
                    interpreter='none';
                    titleExtent=getStringBounds(updateState,...
                    title,matlab.graphics.general.Font(...
                    'Name',Font.Name,'Size',Font.Size,'Weight','bold'),...
                    interpreter,smoothing);
                end
            end
            vspace=titleExtent(2)+4/updateState.PixelsPerPoint;
        else
            vspace=20*(numrows+1.5)/2.5;
        end
        ax.Position(4)=ax.Position(4)+vspace;
        ax.Position(2)=ax.Position(2)-vspace;
        ax.YLim(2)=ax.YLim(2)+vspace;

        x=xlimits(2)/2;
        y=ylimits(2)+vspace/2;

        try
            handles.TitleStringHandle=text(ax,x,y,title,...
            'HorizontalAlignment','center','FontWeight','bold',...
            'FontSize',Font.Size,'FontName',Font.Name,...
            'Tag','SizeLegendTitle');
        catch e


            if strcmp(e.identifier,'MATLAB:hg:textutils:StringSyntaxError')
                handles.TitleStringHandle=text(ax,x,y,title,...
                'HorizontalAlignment','center','FontWeight','bold',...
                'FontSize',Font.Size,'FontName',Font.Name,...
                'Interpreter','none','Tag','SizeLegendTitle');
            end
        end


        x=xlimits;
        y=ylimits(2)+[0,0];
        handles.TitleLineHandle=line(ax,x,y,'Color','black');
    end
end


function label=formatSizeLegendLabel(sizeLimit)
    absSizeLimit=abs(sizeLimit);
    containsFloat=floor(sizeLimit)~=sizeLimit;
    if containsFloat
        needsExponent=(absSizeLimit>=10^4||absSizeLimit<10^-3)&&...
        isfinite(absSizeLimit)&&absSizeLimit~=0;
        if needsExponent
            label=strsplit(sprintf('%1.2e',sizeLimit),'e');
            label=...
            [label{1},'{\times}10^{',num2str(str2double(label{2})),'}'];
        else
            label=sprintf('%1.3f',sizeLimit);
        end
    else
        needsExponent=absSizeLimit>=10^6&&isfinite(absSizeLimit);
        if needsExponent
            label=strsplit(sprintf('%1.2e',sizeLimit),'e');
            label=...
            [label{1},'{\times}10^{',num2str(str2double(label{2})),'}'];
        else
            label=sprintf('%d',sizeLimit);
        end
    end
end


function disableAxesBehavior(ax)
    bh=hggetbehavior(ax,'brush');
    bh.Serialize=true;
    bh.Enable=false;
    mch=hggetbehavior(ax,'MCodeGeneration');
    mch.Enable=false;
    mch.MCodeIgnoreHandleFcn='true';

    matlab.graphics.interaction.disableDefaultAxesInteractions(ax)


    parts=findall(ax);
    set(ax,'Internal',true);
    set(parts,'Internal',true);
    set(parts,'PickableParts','none');
end
