classdef Bubble<handle




















































































    properties
        XData=[];
        YData=[];
    end

    properties(Dependent)
SizeData
ColorData
SizeLimits
    end

    properties(Dependent)
BubbleWidthRange
    end

    properties(Dependent)
BubbleColorList
    end

    properties(Dependent)
BubbleLineWidth
    end

    properties(Dependent,SetAccess=private)
DefaultBubbleWidthRange
DefaultMarkerEdgeColor
DefaultMarkerFaceAlpha
DefaultMarkerEdgeAlpha
DefaultLineWidth
DefaultSizeLegendBubbleFaceColor
    end

    properties(Hidden)
        ManualSizeLimits=false;
        ManualBubbleWidthRange=false;
    end

    properties(SetAccess=private)
        SizeIndex=[];
    end

    properties(SetAccess=private,Transient)
        ScatterPrimitive=gobjects(0);
    end

    properties(Constant,Access=private)
        pDefaultBubbleWidthRange=[5,20];
        pDefaultBubbleWidthWeights=[13/15,2/15];
        pDefaultMarkerEdgeColor=[255,255,255]/255;
        pDefaultMarkerFaceAlpha=0.8;
        pDefaultMarkerEdgeAlpha=0.6;
        pDefaultLineWidth=1;
        pDefaultSizeLegendBubbleFaceColor=[0.7,0.7,0.7];
    end

    properties(Access=private)
        pSizeData=[];
        pColorData=[];
        pSizeLimits=[];
        pBubbleWidthRange=[];
        pBubbleColorList=[];
        pBubbleLineWidth=[];

        Axes=gobjects(0);
    end

    methods
        function obj=Bubble(ax)
            if nargin<1
                ax=gca;
            end
            obj.Axes=ax;
            diameter=defaultBubbleDiameter(obj);
            obj.pBubbleWidthRange=[diameter,diameter];
            obj.ScatterPrimitive=matlab.graphics.chart.primitive.Scatter(...
            'Parent',ax,'DeleteFcn',@(~,~)scatterDeleteFcn(obj),...
            'Tag','Bubbles','CDataMode','manual');
            obj.pBubbleColorList=...
            matlab.graphics.chart.internal.maps.colorOrderColors(1,obj);
            obj.BubbleLineWidth=obj.DefaultLineWidth;



            set(obj.ScatterPrimitive.MarkerHandle,...
            'Clipping','on','AnchorPointClipping','off')
        end


        function delete(obj)
            sp=obj.ScatterPrimitive;
            if~isempty(sp)&&isvalid(sp)
                delete(sp)
            end
        end

        function update(obj)






            x=obj.XData(:);
            y=obj.YData(:);

            if isempty(obj.SizeData)
                a=defaultBubbleArea(obj);
                n=length(x);
                obj.SizeIndex=(1:n);
            else
                a=scaledBubbleArea(obj);
                [a,index]=sort(a,1,'descend');
                x=x(index);
                y=y(index);
                obj.SizeIndex=index;
                a=max(a,minBubbleArea(obj),'includenan');
                a=min(a,maxBubbleArea(obj),'includenan');
            end

            if isempty(obj.ColorData)
                c=obj.BubbleColorList;
                c=c(1,:);
            elseif iscategorical(obj.ColorData)
                c=categoriesToColors(obj);
            end

            if~isempty(obj.SizeIndex)&&size(c,1)>1
                c=c(obj.SizeIndex,:);
            end

            sp=obj.ScatterPrimitive;
            set(sp,'XData',x,'YData',y,'CData',c,'SizeData',a);
            setFaceEdgeProperties(obj,sp)
        end


        function updateBubblePositions(obj)

            if isempty(obj.SizeIndex)
                n=length(obj.XData);
                obj.SizeIndex=(1:n);
            end
            x=obj.XData(obj.SizeIndex);
            y=obj.YData(obj.SizeIndex);
            sp=obj.ScatterPrimitive;
            set(sp,'XData',x,'YData',y);
        end
    end



    methods
        function set.XData(obj,xdata)
            obj.XData=xdata;
        end


        function set.YData(obj,ydata)
            obj.YData=ydata;
        end


        function set.SizeData(obj,sizedata)
            obj.pSizeData=sizedata;

            if~obj.ManualSizeLimits
                if any(isfinite(sizedata))
                    obj.pSizeLimits=...
                    [min(sizedata(isfinite(sizedata(:))))...
                    ,max(sizedata(isfinite(sizedata(:))))];
                elseif isempty(sizedata)
                    obj.pSizeLimits=[];
                else

                    obj.pSizeLimits=[0,1];
                end
            end

            if~obj.ManualBubbleWidthRange
                if diff(obj.pSizeLimits)~=0
                    obj.pBubbleWidthRange=obj.DefaultBubbleWidthRange;
                else
                    diameter=defaultBubbleDiameter(obj);
                    obj.pBubbleWidthRange=[diameter,diameter];
                end
            end
        end

        function set.ColorData(obj,colordata)
            colors=matlab.graphics.chart.internal.maps.colorOrderColors([],obj);
            usingDefault=all(ismember(obj.pBubbleColorList,colors,'rows'));
            if usingDefault&&~isempty(colordata)
                numberOfCategories=length(categories(colordata));
                if any(isundefined(colordata))
                    numberOfCategories=numberOfCategories+1;
                end
                obj.pBubbleColorList=...
                matlab.graphics.chart.internal.maps.colorOrderColors(numberOfCategories,obj);
            elseif usingDefault
                obj.pBubbleColorList=...
                matlab.graphics.chart.internal.maps.colorOrderColors(1,obj);
            end

            obj.pColorData=colordata;
        end


        function set.SizeLimits(obj,sizeLimits)
            if isempty(sizeLimits)
                obj.ManualSizeLimits=false;
                sizedata=obj.pSizeData;
                if any(isfinite(sizedata))
                    obj.pSizeLimits=...
                    [min(sizedata(isfinite(sizedata(:))))...
                    ,max(sizedata(isfinite(sizedata(:))))];
                elseif isempty(sizedata)
                    obj.pSizeLimits=[];
                else

                    obj.pSizeLimits=[0,1];
                end
                if~obj.ManualBubbleWidthRange&&...
                    (isempty(obj.pSizeLimits)||diff(obj.pSizeLimits)==0)
                    diameter=defaultBubbleDiameter(obj);
                    obj.pBubbleWidthRange=[diameter,diameter];
                end
            else
                sizeLimitsEqual=(sizeLimits(1)==sizeLimits(2));
                sizeDataUniform=isequal(min(obj.pSizeData,[],'includenan'),...
                max(obj.pSizeData,[],'includenan'));
                limitsMatchData=isequal(sizeLimits(1),...
                max(obj.pSizeData,[],'includenan'));
                if sizeLimitsEqual&&sizeDataUniform&&limitsMatchData
                    obj.pSizeLimits=sizeLimits;
                    obj.ManualSizeLimits=false;
                    if~obj.ManualBubbleWidthRange
                        diameter=defaultBubbleDiameter(obj);
                        obj.pBubbleWidthRange=[diameter,diameter];
                    end
                else
                    try
                        validateattributes(sizeLimits,{'numeric'},...
                        {'increasing'},'','SizeLimits')
                    catch e
                        throwAsCaller(e);
                    end
                    obj.pSizeLimits=sizeLimits;
                    obj.ManualSizeLimits=true;
                    if~obj.ManualBubbleWidthRange
                        obj.pBubbleWidthRange=obj.DefaultBubbleWidthRange;
                    end
                end
            end

            sp=obj.ScatterPrimitive;
            if~isempty(sp)&&~isempty(sp.SizeData)...
                &&isequal(numel(sp.SizeData),numel(obj.SizeData))

                a=scaledBubbleArea(obj);
                if~isempty(obj.SizeIndex)
                    a=a(obj.SizeIndex);
                end
                a=max(a,minBubbleArea(obj),'includenan');
                sp.SizeData=min(a,maxBubbleArea(obj),'includenan');
            end
        end


        function set.BubbleWidthRange(obj,bubbleWidthRange)
            if isempty(bubbleWidthRange)
                obj.ManualBubbleWidthRange=false;
                if isequal(obj.SizeLimits,unique(obj.SizeLimits))&&...
                    ~isempty(obj.SizeData)
                    obj.pBubbleWidthRange=obj.DefaultBubbleWidthRange;
                else
                    diameter=defaultBubbleDiameter(obj);
                    obj.pBubbleWidthRange=[diameter,diameter];
                end
            else
                if isscalar(bubbleWidthRange)
                    bubbleWidthRange=[bubbleWidthRange,bubbleWidthRange];
                end
                obj.pBubbleWidthRange=bubbleWidthRange;
                obj.ManualBubbleWidthRange=true;
            end

            sp=obj.ScatterPrimitive;
            if~isempty(sp)&&~isempty(sp.SizeData)

                a=scaledBubbleArea(obj);
                if~isempty(obj.SizeIndex)
                    a=a(obj.SizeIndex);
                end
                a=max(a,minBubbleArea(obj),'includenan');
                sp.SizeData=min(a,maxBubbleArea(obj),'includenan');
            end
        end


        function set.BubbleColorList(obj,colors)
            colordata=obj.ColorData;
            if isempty(colors)
                if~isempty(colordata)&&iscategorical(colordata)
                    numberOfCategories=length(categories(colordata));
                    if any(isundefined(colordata))
                        numberOfCategories=numberOfCategories+1;
                    end
                    obj.pBubbleColorList=...
                    matlab.graphics.chart.internal.maps.colorOrderColors(numberOfCategories,obj);
                else
                    obj.pBubbleColorList=...
                    matlab.graphics.chart.internal.maps.colorOrderColors(1,obj);
                end
            else
                obj.pBubbleColorList=colors;
            end

            sp=obj.ScatterPrimitive;
            if~isempty(sp)&&~isempty(sp.CData)...
                &&iscategorical(obj.ColorData)...
                &&isequal(size(sp.CData,1),length(obj.ColorData))


                c=categoriesToColors(obj);
                if~isempty(obj.SizeIndex)
                    c=c(obj.SizeIndex,:);
                end
                sp.CData=c;
            end
        end


        function set.BubbleLineWidth(obj,linewidth)
            sp=obj.ScatterPrimitive;
            if isempty(obj.pBubbleLineWidth)||isempty(linewidth)
                obj.pBubbleLineWidth=obj.DefaultLineWidth;
                sp.LineWidth=obj.DefaultLineWidth;
            else
                obj.pBubbleLineWidth=linewidth;
                sp.LineWidth=linewidth;
            end
        end

    end



    methods
        function sizedata=get.SizeData(obj)
            sizedata=obj.pSizeData;
        end

        function colordata=get.ColorData(obj)
            colordata=obj.pColorData;
        end

        function limits=get.SizeLimits(obj)
            limits=obj.pSizeLimits;
        end

        function width=get.BubbleWidthRange(obj)
            width=obj.pBubbleWidthRange;
        end

        function colors=get.BubbleColorList(obj)
            colors=obj.pBubbleColorList;
        end

        function linewidth=get.BubbleLineWidth(obj)
            linewidth=obj.pBubbleLineWidth;
        end
    end



    methods
        function limits=get.DefaultBubbleWidthRange(obj)
            if isappdata(groot,'DefaultBubbleWidthRange')
                limits=getappdata(groot,'DefaultBubbleWidthRange');
            else
                limits=obj.pDefaultBubbleWidthRange;
            end
        end

        function color=get.DefaultMarkerEdgeColor(obj)
            if isappdata(groot,'DefaultBubbleEdgeColor')
                color=getappdata(groot,'DefaultBubbleEdgeColor');
            else
                color=obj.pDefaultMarkerEdgeColor;
            end
        end

        function alpha=get.DefaultMarkerFaceAlpha(obj)
            if isappdata(groot,'DefaultBubbleFaceAlpha')
                alpha=getappdata(groot,'DefaultBubbleFaceAlpha');
            else
                alpha=obj.pDefaultMarkerFaceAlpha;
            end
        end

        function alpha=get.DefaultMarkerEdgeAlpha(obj)
            if isappdata(groot,'DefaultBubbleEdgeAlpha')
                alpha=getappdata(groot,'DefaultBubbleEdgeAlpha');
            else
                alpha=obj.pDefaultMarkerEdgeAlpha;
            end
        end

        function width=get.DefaultLineWidth(obj)
            if isappdata(groot,'DefaultBubbleLineWidth')
                width=getappdata(groot,'DefaultBubbleLineWidth');
            else
                width=obj.pDefaultLineWidth;
            end
        end

        function color=get.DefaultSizeLegendBubbleFaceColor(obj)
            if isappdata(groot,'DefaultSizeLegendBubbleFaceColor')
                color=getappdata(groot,'DefaultSizeLegendBubbleFaceColor');
            else
                color=obj.pDefaultSizeLegendBubbleFaceColor;
            end
        end
    end



    methods(Access=private)

        function A=scaledBubbleArea(obj)


            if diff(obj.SizeLimits)~=0
                bubbleAreaLimits=(obj.BubbleWidthRange).^2;
                sizedata=singleIfNotFloat(obj.SizeData);
                sizelimits=singleIfNotFloat(obj.pSizeLimits);
                A=bubbleAreaLimits(1)...
                +(sizedata(:)-sizelimits(1))...
                *diff(bubbleAreaLimits)/diff(sizelimits);
            else

                A=defaultBubbleArea(obj)+zeros(numel(obj.XData),1);
                A(isnan(obj.SizeData))=NaN;
            end
        end


        function A=defaultBubbleArea(obj)
            bwr=obj.BubbleWidthRange;
            if~isempty(bwr)



                bwr(bwr==1)=eps+1;
                A=(sum(bwr.*obj.pDefaultBubbleWidthWeights))^2;
            else


                A=(defaultBubbleDiameter(obj))^2;
            end
        end


        function A=minBubbleArea(obj)
            bwr1=obj.BubbleWidthRange(1);
            if bwr1==1



                bwr1=eps+1;
            end
            A=(bwr1)^2;
        end


        function A=maxBubbleArea(obj)
            bwr2=obj.BubbleWidthRange(2);
            if bwr2==1



                bwr2=eps+1;
            end
            A=(bwr2)^2;
        end


        function diameter=defaultBubbleDiameter(obj)
            diameter=sum(...
            obj.DefaultBubbleWidthRange...
            .*obj.pDefaultBubbleWidthWeights);
        end

        function cdata=categoriesToColors(obj)



            colordata=obj.ColorData;
            assert(iscategorical(colordata),...
            'MATLAB:maps:geobubble:expectedCategorical',...
            'Internal error: This method should only be invoked when obj.ColorData is categorical.')
            cats=categories(colordata);
            cats=categorical(cats,cats,'Ordinal',isordinal(colordata));
            categoryIndex=arrayfun(@(c)...
            indexColorDataCategories(cats,c),colordata);
            categoryIndex(categoryIndex==0)=length(cats)+1;
            cdata=categoryColor(obj,categoryIndex);
        end


        function setFaceEdgeProperties(obj,sp)
            sp.MarkerFaceColor='flat';
            sp.MarkerFaceAlpha=obj.DefaultMarkerFaceAlpha;
            sp.MarkerEdgeColor=obj.DefaultMarkerEdgeColor;
            sp.MarkerEdgeAlpha=obj.DefaultMarkerEdgeAlpha;
            sp.LineWidth=obj.BubbleLineWidth;
        end


        function rgb=categoryColor(obj,categoryIndex)






            colors=obj.pBubbleColorList;
            m=1+mod(categoryIndex-1,size(colors,1));
            rgb=colors(m,:);
        end
    end
end


function scatterDeleteFcn(obj)

    if isvalid(obj)
        obj.ScatterPrimitive=gobjects(0);
    end
end


function floatdata=singleIfNotFloat(data)





    if~isfloat(data)
        floatdata=single(data);
    else
        floatdata=data;
    end
end


function categoryIndex=indexColorDataCategories(categories,colordata)
    categoryIndex=find(colordata==categories,1);
    if isempty(categoryIndex)
        categoryIndex=0;
    end
end
