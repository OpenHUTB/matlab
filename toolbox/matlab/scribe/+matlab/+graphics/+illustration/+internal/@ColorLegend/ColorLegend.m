classdef ColorLegend<handle








    properties(Transient)
ColorList
        MarkerList="square"
        MarkerFilled="on"
        MarkerAlpha=1
        LineStyleList="-"
        LineWidthList=1
        LineAlphaList=0.7
        IsLine=false
Categories
TitleString
FontName
FontSize
        Visible='on'
PositionInPoints
Parent
        UpperRightMargin=[5,5]
    end

    properties(SetAccess=private)
Legend
    end

    properties(Access=private,Transient)
Axes
HiddenColorSquares
PlotBoxInPoints
    end

    properties(Access=private,Constant)
        FontSizeMultiplier=.9
    end

    methods
        function obj=ColorLegend(ax)
            obj.Axes=ax;
            leg=matlab.graphics.illustration.Legend;
            leg.standalone='on';
            leg.Units='points';
            leg.Visible='off';
            obj.Legend=leg;


            obj.FontName=get(groot,'FactoryAxesFontName');
            obj.FontSize=get(groot,'FactoryAxesFontSize');
        end

        function delete(obj)
            if~isempty(obj.HiddenColorSquares)&&all(isvalid(obj.HiddenColorSquares))
                delete(obj.HiddenColorSquares)
            end
            if~isempty(obj.Legend)&&isvalid(obj.Legend)
                delete(obj.Legend)
            end
        end

        function node=getNode(obj)

            node=obj.Legend;
        end


        function categoricalLegend(obj)

            cats=string(obj.Categories);





            if~isempty(obj.HiddenColorSquares)
                delete(obj.HiddenColorSquares)
            end

            if obj.IsLine
                obj.HiddenColorSquares=createColorLines(obj,cats);
            else
                obj.HiddenColorSquares=createColorSquares(obj,cats);
            end


            leg=obj.Legend;
            leg.PlotChildren=obj.HiddenColorSquares;
            if strcmp(obj.Visible,'on')
                leg.Visible='on';
            end
        end


        function set.FontName(obj,fontName)
            obj.FontName=fontName;
            obj.Legend.FontName=fontName;%#ok<MCSUP>
        end

        function set.FontSize(obj,fontSize)
            scaledFontSize=fontSize*obj.FontSizeMultiplier;
            obj.FontSize=scaledFontSize;
            obj.Legend.FontSize=scaledFontSize;%#ok<MCSUP>
        end

        function set.Parent(obj,parent)
            obj.Legend.Parent=parent;%#ok<MCSUP>
            obj.Parent=parent;
        end


        function set.PositionInPoints(obj,positionInPoints)


            setPlotBoxToPoints(obj);
            obj.Legend.Position=positionInPoints;%#ok<MCSUP>
            obj.PositionInPoints=positionInPoints;
        end


        function set.TitleString(obj,title)
            obj.Legend.Title.String=title;%#ok<MCSUP>
            obj.TitleString=title;
        end


        function set.Visible(obj,visible)
            obj.Legend.Visible=visible;%#ok<MCSUP>
            obj.Visible=visible;
            if strcmp(visible,'off')&&isempty(obj.Categories)...
                &&~isempty(obj.HiddenColorSquares)...
                &&all(isvalid(obj.HiddenColorSquares))%#ok<MCSUP>
                delete(obj.HiddenColorSquares)%#ok<MCSUP>
            end
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


        function sz=getPreferredSize(obj,updateState)
            if nargin==1
                sz=[50,50];
            else
                sz=obj.Legend.getPreferredSize(updateState);
            end
        end


        function updateColorLegendObject(obj,prefSize)



            if strcmp(obj.Visible,'on')






                if isempty(obj.Parent)&&nargin<2
                    obj.Parent=gcf;
                    legPrefSize=[50,50];
                else
                    legPrefSize=prefSize;
                end

                pbPoints=obj.PlotBoxInPoints;
                plotboxUpperRight=[pbPoints(1)+pbPoints(3),pbPoints(2)+pbPoints(4)];



                legUpperRight=plotboxUpperRight-obj.UpperRightMargin;

                legLowerLeft=[...
                legUpperRight(1)-legPrefSize(1),...
                legUpperRight(2)-legPrefSize(2)];
                legPosPoints=[legLowerLeft,legPrefSize];
                obj.PositionInPoints=legPosPoints;
            end
        end
    end

    methods(Access=private)
        function rgb=categoryColor(obj,categoryIndex)







            colors=obj.ColorList;
            m=1+mod(categoryIndex-1,size(colors,1));
            rgb=colors(m,:);
            rgb(categoryIndex==0,:)=-1;
        end

        function colorSquares=createColorSquares(obj,dispNames)















            colorSquares=gobjects(numel(dispNames),1);
            obj.Legend.ItemTokenSize=[12,18];
            mrk=obj.MarkerList(:);
            if length(obj.MarkerList)~=numel(dispNames)
                mrk=repmat(mrk,numel(dispNames),1);
            end
            mrkAlpha=obj.MarkerAlpha(:);
            if length(obj.MarkerAlpha)~=numel(dispNames)
                mrkAlpha=repmat(mrkAlpha,numel(dispNames),1);
            end
            for k=1:numel(dispNames)
                sp=matlab.graphics.chart.primitive.Scatter('Parent',obj.Axes);
                rgb=categoryColor(obj,k);
                set(sp,'XData',NaN,'YData',NaN,'SizeData',NaN,'CData',rgb)
                sp.Marker=mrk(k);
                sp.MarkerFaceAlpha=mrkAlpha(k);
                sp.MarkerEdgeAlpha=mrkAlpha(k);
                if strcmp(obj.MarkerFilled,'on')
                    sp.MarkerFaceColor='flat';
                    if strcmp(mrk(k),'square')
                        sp.MarkerEdgeColor='none';
                    end
                end
                sp.DisplayName=dispNames{k};
                sp.Tag='HiddenSquare';
                colorSquares(k)=sp;
            end

























        end

        function colorLines=createColorLines(obj,dispNames)















            colorLines=gobjects(numel(dispNames),1);
            obj.Legend.ItemTokenSize=[12,18];
            linS=obj.LineStyleList(:);
            linW=obj.LineWidthList(:);
            linA=obj.LineAlphaList(:);
            if length(obj.LineStyleList)~=numel(dispNames)
                linS=repmat(linS,numel(dispNames),1);
                linW=repmat(linW,numel(dispNames),1);
                linA=repmat(linA,numel(dispNames),1);
            end


            for k=1:numel(dispNames)
                sp=matlab.graphics.chart.primitive.Line('Parent',obj.Axes);
                rgb=categoryColor(obj,k);
                set(sp,'XData',NaN,'YData',NaN,'Color',rgb)
                sp.LineStyle=linS(k);
                sp.LineWidth=linW(k);
                sp.Color(4)=linA(k);

                sp.DisplayName=dispNames{k};
                sp.Tag='HiddenLine';
                colorLines(k)=sp;
            end
        end
    end
end
