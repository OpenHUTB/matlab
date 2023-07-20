classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Sealed)WordCloudChart<matlab.graphics.chart.internal.UndecoratedTitledChart




    properties(Dependent)
        SourceTable;
        WordVariable;
        SizeVariable;
    end
    properties(AffectsObject,Access=private)
        SourceTable_I tabular=table.empty();
        WordVariable_I='';
        SizeVariable_I='';
    end


    properties(Dependent,AffectsObject)
        Title matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
        MaxDisplayWords;
        Shape;
        LayoutNum;
        SizePower;
        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName;
        WordData;
        Color;
        SizeData matlab.internal.datatype.matlab.graphics.datatype.VectorData;
    end

    properties(AffectsObject)
        HighlightColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[217,83,25]/255;
        Box matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
        TitleFontName matlab.internal.datatype.matlab.graphics.datatype.FontName=get(groot,'FactoryAxesFontName');
    end

    properties(Hidden,GetAccess=?tWordCloudChart,SetAccess=private)
        DataCache=[];
    end
    properties(Hidden,GetAccess=?tWordCloudChart,SetAccess=private,Transient)
        ShapeCache=[];
        LayoutCache=[];
        EnableRecompute=true;
    end
    properties(Hidden,Access=private,Transient)
        UseNewLayout=feature('webui')
    end

    properties(Hidden,AbortSet)
        TitleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end
    properties(Access=private)
        Title_I='';
        Shape_I='oval';
        MaxDisplayWords_I=100;
        LayoutNum_I=1;
        SizePower_I=0.5;
        FontName_I=get(groot,'FactoryAxesFontName');
        PositionStorage;
    end

    properties(Access={?matlab.graphics.chart.Chart},Transient,NonCopyable)
        Axes;
        Text;
        AxTitle;
    end

    properties(Transient,Hidden=true,GetAccess=public,SetAccess=protected,NonCopyable)
        Type='wordcloud';
    end

    properties(Access=private)
        WordData_I=strings(1,0);
        SizeData_I=zeros(1,0);
        Color_I matlab.internal.datatype.matlab.graphics.datatype.ColorMap=[64,64,64]/255;


        WordVariableName char='';
        SizeVariableName char='';
        DataMode='unset';




        RampSize=100;
    end

    properties(Access=private)

        RecomputeShapeAndRedraw;
    end

    methods
        function obj=WordCloudChart(varargin)
            obj.EnableRecompute=false;

            ax=matlab.graphics.axis.Axes('Visible','off');
            ax.PositionConstraint='outerposition';
            ax.LooseInset=[0,0,0,0];
            ax.XTick=[];
            ax.YTick=[];
            ax.XAxis.Color='none';
            ax.YAxis.Color='none';
            if~isempty(ax.Toolbar)
                ax.Toolbar.Visible='off';
            end

            obj.Axes=ax;
            obj.AxTitle=ax.Title;
            obj.addNode(ax);


            obj.addDependencyConsumed({'ref_frame','resolution'});

            try

                matlab.graphics.chart.internal.ctorHelper(obj,varargin);
            catch e

                obj.Parent=[];
                throwAsCaller(e);
            end

            obj.EnableRecompute=true;
            obj.RecomputeShapeAndRedraw=1;
            ax.Visible='on';

            createPostSetListenerForAxesTitle(obj);
        end



        function set.PositionStorage(hObj,data)



            if~any(isfield(data,{'PositionConstraint','ActivePositionProperty'}))
                return
            end






            if~isfield(data,'PositionConstraint')
                if strcmpi(data.ActivePositionProperty,'outerposition')
                    data.PositionConstraint='outerposition';
                else
                    data.PositionConstraint='innerposition';
                end
            end

            hObj.Axes.Units=data.Units;%#ok<MCSUP>

            if strcmpi(data.PositionConstraint,'outerposition')
                hObj.Axes.PositionConstraint=data.PositionConstraint;%#ok<MCSUP>
                hObj.Axes.OuterPosition=data.OuterPosition;%#ok<MCSUP>
            else
                hObj.Axes.PositionConstraint=data.PositionConstraint;%#ok<MCSUP>
                hObj.Axes.InnerPosition=data.InnerPosition;%#ok<MCSUP>
            end
        end

        function data=get.PositionStorage(hObj)



            data.Units=hObj.Axes.Units;
            data.ActivePositionProperty=hObj.Axes.ActivePositionProperty;
            data.PositionConstraint=hObj.Axes.PositionConstraint;
            data.InnerPosition=hObj.Axes.Position;
            data.OuterPosition=hObj.Axes.OuterPosition;
        end

        function val=get.Title(obj)
            val=obj.Title_I;
        end
        function set.Title(obj,val)
            obj.Axes.Title.String_I=val;
            obj.TitleMode='manual';
            obj.Title_I=obj.Axes.Title.String;
        end

        function val=get.MaxDisplayWords(obj)
            val=obj.MaxDisplayWords_I;
        end
        function set.MaxDisplayWords(obj,val)
            validateattributes(val,{'numeric'},{'scalar','positive','nonnan'});
            if isfinite(val)
                validateattributes(val,{'numeric'},{'integer'});
            end
            obj.MaxDisplayWords_I=double(val);
            recomputeShapeCache(obj);
            MarkDirty(obj,'all');
        end

        function val=get.LayoutNum(obj)
            val=obj.LayoutNum_I;
        end
        function set.LayoutNum(obj,val)
            validateattributes(val,{'numeric'},{'scalar','nonnegative','integer'});
            obj.LayoutNum_I=double(val);
            obj.LayoutCache=[];
        end

        function val=get.SizePower(obj)
            val=obj.SizePower_I;
        end
        function set.SizePower(obj,val)
            validateattributes(val,{'numeric'},{'scalar','positive','finite'});
            obj.SizePower_I=double(val);
            recomputeShapeCache(obj);
            MarkDirty(obj,'all');
        end

        function val=get.Shape(obj)
            val=obj.Shape_I;
        end
        function set.Shape(obj,val)
            val=validatestring(val,...
            {'oval','rectangle'},'','Shape');
            obj.Shape_I=val;
            recomputeShapeCache(obj);
            MarkDirty(obj,'all');
        end

        function val=get.FontName(obj)
            val=obj.FontName_I;
        end
        function set.FontName(obj,val)
            obj.FontName_I=val;
            recomputeShapeCache(obj);
            MarkDirty(obj,'all');
        end

        function val=get.WordData(obj)
            val=obj.WordData_I;
        end
        function set.WordData(obj,val)


            if strcmp(obj.DataMode,'table')
                error(message('MATLAB:graphics:wordcloud:TableWorkflow','WordData'));
            end
            [val,msg]=validateWordData(val);
            if~isempty(msg)
                throwAsCaller(MException(message(msg)));
            end
            obj.DataMode='matrix';

            obj.WordData_I=val;
            recomputeDataCache(obj);
            recomputeShapeCache(obj);
            MarkDirty(obj,'all');
        end

        function val=get.SizeData(obj)
            val=obj.SizeData_I;
        end
        function set.SizeData(obj,val)


            if strcmp(obj.DataMode,'table')
                error(message('MATLAB:graphics:wordcloud:TableWorkflow','SizeData'));
            end

            [val,msg]=validateSizeData(val);
            if~isempty(msg)
                throwAsCaller(MException(message(msg)));
            end
            obj.DataMode='matrix';

            obj.SizeData_I=val;
            recomputeDataCache(obj);
            recomputeShapeCache(obj);
            MarkDirty(obj,'all');
        end

        function val=get.Color(obj)
            val=obj.Color_I;
        end
        function set.Color(obj,val)
            if~isnumeric(val)
                try

                    obj.Axes.ZColor=val;
                    val=obj.Axes.ZColor;
                catch
                    error(message('MATLAB:graphics:wordcloud:InvalidColor'));
                end
            end
            try
                obj.Color_I=val;
            catch
                error(message('MATLAB:graphics:wordcloud:InvalidColor'));
            end
            obj.Color_I=full(double(val));
        end


        function set.SourceTable(obj,tbl)
            import matlab.graphics.chart.internal.validateTableSubscript



            if strcmp(obj.DataMode,'matrix')
                error(message('MATLAB:graphics:wordcloud:MatrixWorkflow','SourceTable'));
            end


            if~isa(tbl,'tabular')
                error(message('MATLAB:graphics:wordcloud:InvalidSourceTable'));
            end


            [wordVarName,~,errWord]=validateTableSubscript(...
            tbl,obj.WordVariable_I,'WordVariable');
            [sizeVarName,~,errSize]=validateTableSubscript(...
            tbl,obj.SizeVariable_I,'SizeVariable');



            if~isempty(errWord)
                throwAsCaller(errWord);
            end
            if~isempty(errSize)
                throwAsCaller(errSize);
            end
            if~isempty(wordVarName)
                [wordval,msg]=validateWordData(tbl.(wordVarName));
                if~isempty(msg)
                    throwAsCaller(MException(message(msg)));
                end
            end
            if~isempty(sizeVarName)
                [sizeval,msg]=validateSizeData(tbl.(sizeVarName));
                if~isempty(msg)
                    throwAsCaller(MException(message(msg)));
                end
            end


            obj.SourceTable_I=tbl;
            obj.DataMode='table';

            if~isempty(sizeVarName)&&~isempty(wordVarName)

                obj.WordVariableName=wordVarName;
                obj.SizeVariableName=sizeVarName;

                obj.WordData_I=wordval;
                obj.SizeData_I=sizeval;

                recomputeDataCache(obj);
                recomputeShapeCache(obj);
                MarkDirty(obj,'all');
            end
        end

        function tbl=get.SourceTable(obj)
            tbl=obj.SourceTable_I;
        end

        function set.WordVariable(obj,var)


            if strcmp(obj.DataMode,'matrix')
                error(message('MATLAB:graphics:wordcloud:MatrixWorkflow','WordVariable'));
            end
            tbl=obj.SourceTable_I;
            if strcmp(obj.DataMode,'unset')||width(tbl)==0
                error(message('MATLAB:graphics:wordcloud:NoTable'));
            end


            import matlab.graphics.chart.internal.validateTableSubscript
            [varName,var,err]=validateTableSubscript(tbl,var,'WordVariable');
            if~isempty(err)
                throwAsCaller(err);
            end
            [val,msg]=validateWordData(tbl.(varName));
            if~isempty(msg)
                throwAsCaller(MException(message(msg)));
            end

            obj.WordVariableName=varName;
            obj.WordVariable_I=var;

            obj.WordData_I=val;
            recomputeDataCache(obj);
            recomputeShapeCache(obj);
            MarkDirty(obj,'all');
        end

        function var=get.WordVariable(obj)
            var=obj.WordVariable_I;
        end

        function set.SizeVariable(obj,var)


            if strcmp(obj.DataMode,'matrix')
                error(message('MATLAB:graphics:wordcloud:MatrixWorkflow','SizeVariable'));
            end
            tbl=obj.SourceTable_I;
            if strcmp(obj.DataMode,'unset')||width(tbl)==0
                error(message('MATLAB:graphics:wordcloud:NoTable'));
            end


            import matlab.graphics.chart.internal.validateTableSubscript
            [varName,var,err]=validateTableSubscript(tbl,var,'SizeVariable');
            if~isempty(err)
                throwAsCaller(err);
            end
            [val,msg]=validateSizeData(tbl.(varName));
            if~isempty(msg)
                throwAsCaller(MException(message(msg)));
            end

            obj.SizeVariableName=varName;
            obj.SizeVariable_I=var;

            if strcmp(obj.TitleMode,'auto')
                obj.AxTitle.String_I=varName;
                obj.AxTitle.Interpreter='none';
                obj.Title_I=obj.AxTitle.String;
            end

            obj.SizeData_I=val;
            recomputeDataCache(obj);
            recomputeShapeCache(obj);
            MarkDirty(obj,'all');
        end

        function var=get.SizeVariable(obj)
            var=obj.SizeVariable_I;
        end

        function set.RecomputeShapeAndRedraw(obj,~)
            recomputeShapeCache(obj);
            MarkDirty(obj,'all');
        end
    end

    methods(Hidden,Access={?tWordCloudChart})
        function obj=getInternalChildren(this)
            obj.ax=this.Axes;
            obj.axTitle=this.AxTitle;
            txt=this.Text;
            if isempty(txt)
                obj.txt=txt;
            else
                obj.txt=txt(string({txt.Visible})=="on");
            end
        end
    end


    methods(Hidden)
        function c=internalCaches(obj,c)
            if nargin==2
                obj.ShapeCache=c.ShapeCache;
                obj.LayoutCache=c.LayoutCache;
                obj.DataCache=c.DataCache;
                MarkDirty(obj,'all');
            else
                c.ShapeCache=obj.ShapeCache;
                c.LayoutCache=obj.LayoutCache;
                c.DataCache=obj.DataCache;
            end
        end

        function useNewLayout(obj,on)

            obj.UseNewLayout=on;
            c=internalCaches(obj);
            c.ShapeCache=[];
            c.LayoutCache=[];
            internalCaches(obj,c);
            if~on
                recomputeShapeCache(obj);
                MarkDirty(obj,'all');
            end
        end
    end

    methods(Hidden)
        function recomputeDataCache(obj)
            if~obj.EnableRecompute
                return;
            end
            obj.DataCache=[];
            obj.ShapeCache=[];
            obj.LayoutCache=[];
            args.words=obj.WordData_I(:);
            args.weights=obj.SizeData_I(:);
            [sortedData,invalidData]=matlab.graphics.chart.internal.wordcloud.prepareData(args);
            if~invalidData
                obj.DataCache=sortedData;
            end
        end

        function recomputeShapeCache(obj)
            if~obj.EnableRecompute
                return;
            end
            obj.ShapeCache=[];
            obj.LayoutCache=[];
            if isempty(obj.DataCache)
                recomputeDataCache(obj);
            end
            fig=ancestor(obj,'figure');
            if~isempty(obj.DataCache)

                [width,height]=computeReferenceRectangle(obj,fig);
                axesratio=height/width;

                args=obj.DataCache;
                args.MaxDisplayWords=obj.MaxDisplayWords_I;
                rampSize=obj.RampSize;
                shape=obj.Shape_I;
                power=obj.SizePower;
                args=matlab.graphics.chart.internal.wordcloud.computeFontSizes(args,axesratio,rampSize,shape,power);

                if obj.UseNewLayout
                    shape=[];
                    refHeight=height;
                else
                    props=getTextProperties([],obj.FontName);

                    cleanup=onCleanup(@()set(obj,'EnableRecompute',true));
                    obj.EnableRecompute=false;
                    [shape,refHeight]=matlab.graphics.chart.internal.wordcloud.wordshape(args.words,args.fontsize,height,props);
                    clear cleanup;
                end

                cache.shape=shape;
                cache.args=args;


                if isempty(args.fontsize)
                    cache.maxFontSizePixels=1;
                else
                    cache.maxFontSizePixels=refHeight*args.fontsize(1);
                end
                obj.ShapeCache=cache;
            end
        end

        function recomputeDynamicShapeCache(obj,axsize,updateState)



            if isempty(obj.ShapeCache)
                recomputeShapeCache(obj);
            end
            fsize=obj.ShapeCache.args.fontsize.*axsize(2);
            words=obj.ShapeCache.args.words;
            shapes=matlab.graphics.chart.internal.wordcloud.computeDynamicWordShapes(words,...
            fsize,obj.FontName,updateState);
            obj.ShapeCache.shape=shapes;
            if isempty(fsize)
                obj.ShapeCache.maxFontSizePixels=1;
            else
                obj.ShapeCache.maxFontSizePixels=fsize(1);
            end
        end

        function recomputeLayoutCache(obj,axsize)
            if~obj.EnableRecompute
                return;
            end
            obj.LayoutCache=[];
            if isempty(obj.ShapeCache)
                recomputeShapeCache(obj);
            end
            if~isempty(obj.ShapeCache)
                args=obj.DataCache;
                args.MaxDisplayWords=obj.MaxDisplayWords_I;
                args.LayoutNum=obj.LayoutNum;
                layoutSize=max(axsize-axesSizeTolerance,minAxesSize);
                w=layoutSize(1);
                h=layoutSize(2);
                axesratio=h/w;
                rampSize=obj.RampSize;
                shape=obj.Shape_I;
                power=obj.SizePower;
                args=matlab.graphics.chart.internal.wordcloud.computeFontSizes(args,axesratio,rampSize,shape,power);
                args.Layout=obj.Shape;
                shapes=obj.ShapeCache.shape;
                args.maxFontSizePixels=obj.ShapeCache.maxFontSizePixels;
                obj.LayoutCache=matlab.graphics.chart.internal.wordcloud.layout(w,h,shapes,args,@sample);
                obj.LayoutCache.axsize=axsize;
                obj.LayoutCache.args=args;
            end
        end

        function doUpdate(obj,updateState)
            if~obj.EnableRecompute
                return;
            end
            hAx=obj.Axes;

            th=obj.Text;
            if isempty(th)
                th=allchild(hAx);
            end
            if~isempty(th)
                set(th,'Visible','off');
            end

            checkDataSizes(obj);

            setAxesProps(obj);

            computeSubplotInfo(obj,updateState)

            axsize=hAx.GetLayoutInformation.Position(3:4);
            needsLayout=isempty(obj.LayoutCache)||~eqWithinTolerance(obj.LayoutCache.axsize,axsize);
            if obj.UseNewLayout&&(isempty(obj.ShapeCache)||isempty(obj.ShapeCache.shape)||needsLayout)
                recomputeDynamicShapeCache(obj,axsize,updateState);
            end
            if needsLayout
                recomputeLayoutCache(obj,axsize);
            end
            if~isempty(obj.LayoutCache)&&all(axsize>minAxesSize)
                updateFromLayout(obj)
            end


            outerPos=obj.OuterPosition_I;
            units=obj.Units_I;
            positionConstraint=string(obj.ActivePositionProperty);
            vp=hAx.Camera.Viewport;
            outerPosPixels=matlab.graphics.chart.Chart.convertUnits(vp,'pixels',units,outerPos);
            obj.setState(outerPosPixels,...
            "doUpdate",...
            positionConstraint);

        end

        function setAxesProps(obj)
            obj.Axes.HitTest='on';
            obj.Axes.HandleVisibility='off';
            obj.Axes.Box=obj.Box;
            if strcmp(obj.Box,'off')
                obj.Axes.XAxis.Color='none';
                obj.Axes.YAxis.Color='none';
            else
                obj.Axes.XAxis.Color='k';
                obj.Axes.YAxis.Color='k';
            end
            obj.AxTitle.String_I=obj.Title_I;
            obj.AxTitle.FontName=obj.TitleFontName;
        end

        function computeSubplotInfo(obj,updateState)
            vp=obj.Axes.Camera.Viewport;
            ti=getTightInsetPoints(obj,updateState);
            obj.ChartDecorationInset_I=...
            matlab.graphics.chart.Chart.convertDistances(vp,obj.Units_I,'points',ti);
        end

        function checkDataSizes(obj)
            nwd=length(obj.WordData_I);
            nsd=length(obj.SizeData_I);
            ok=nwd==nsd;
            if vectorizedColor(obj.Color_I)
                ncd=size(obj.Color_I,1);
                ok=ok&&ncd==nwd;
            end
            if~ok
                error(message('MATLAB:graphics:wordcloud:DataSizeMismatch'));
            end
        end

        function updateFromLayout(obj)
            ax=obj.Axes;
            args=obj.ShapeCache.args;
            layArgs=obj.LayoutCache.args;
            props=getTextProperties(ax,obj.FontName);
            weights=layArgs.weights;
            rampSize=obj.RampSize;
            if~vectorizedColor(obj.Color_I)
                args.colorData=matlab.graphics.chart.internal.wordcloud.computeAutoColorData(weights,...
                obj.Color_I,obj.HighlightColor,rampSize);
            else
                args.colorData=sortColors(obj.DataCache,obj.Color_I);
            end
            th=matlab.graphics.chart.internal.wordcloud.plot(ax,obj.LayoutCache,args,props,obj.Text);
            obj.Text=th;
        end

        function createPostSetListenerForAxesTitle(obj)


            ax=obj.Axes;
            addlistener(ax.Title,'String','PostSet',...
            @(~,~)set(obj,'Title',ax.Title.String_I));
        end

    end

    methods(Access='protected',Hidden)
        function label=getDescriptiveLabelForDisplay(obj)
            label=obj.Title;
        end
        function groups=getPropertyGroups(obj)
            if strcmp(obj.DataMode,'table')
                props={'SourceTable','WordVariable','SizeVariable','MaxDisplayWords'};
            else
                props={'WordData','SizeData','MaxDisplayWords'};
            end
            groups=matlab.mixin.util.PropertyGroup(props);
        end
    end
end

function props=getTextProperties(ax,fontName)
    none=1e-10;
    props.Interpreter='none';
    props.HorizontalAlignment='center';
    props.VerticalAlignment='middle';
    props.Clipping='on';
    props.Margin=none;
    props.Parent=ax;
    props.FontName=fontName;
    props.HitTest='off';
end

function[x,y]=sample(width,height,w,h)




    h=h+2;
    w=w+2;

    x1=rand;
    y1=rand;

    x=(width-w)*x1+w/2;
    y=(height-h)*y1+h/2;
end

function[w,h]=computeReferenceRectangle(obj,fig)

    if isempty(fig)
        w=560;
        h=420;
    else
        defaultPosition=get(groot,'DefaultFigurePosition');
        defaultUnits=get(groot,'DefaultFigureUnits');
        pixPos=hgconvertunits(fig,defaultPosition,defaultUnits,'pixels',groot);
        defaultHeight=pixPos(4);
        axPosition=obj.InnerPosition_I;
        axUnits=obj.Units;

        hPar=ancestor(obj,'matlab.ui.internal.mixin.CanvasHostMixin','node');
        pixPos=hgconvertunits(fig,axPosition,axUnits,'pixels',hPar);
        axHeight=pixPos(4);
        h=max(max(defaultHeight,axHeight),420);



        r=max(1e-3,min(1e3,pixPos(3)/pixPos(4)));
        w=r*h;
    end
end

function data=sortColors(dataCache,colorData)
    colorData(dataCache.ignored,:)=[];
    data=colorData(dataCache.inds,:);
    wd=dataCache.words;
    data=data(1:size(wd,1),:);
end

function y=vectorizedColor(c)
    y=size(c,1)~=1;
end

function[val,msg]=validateWordData(val)
    msg='';
    if(isstring(val)||iscellstr(val))&&...
        isvector(val)&&...
        ~any(ismissing(string(val)))
        val=string(val);
        val=reshape(val,1,[]);
        if~isempty(val)&&(max(strlength(val))>1000||...
            any(contains(val,newline)))
            msg='MATLAB:graphics:wordcloud:WordContent';
        end
    else
        msg='MATLAB:graphics:wordcloud:WordData';
    end
end

function[val,msg]=validateSizeData(val)
    msg='';
    if isnumeric(val)&&(isempty(val)||isvector(val))&&all(val>=0)
        val=double(val(:));
    else
        msg='MATLAB:graphics:wordcloud:SizeData';
    end
end

function tf=eqWithinTolerance(oldsize,newsize)
    tf=max(abs(oldsize-newsize))<=axesSizeTolerance;
end

function tol=axesSizeTolerance
    tol=3;
end

function val=minAxesSize
    val=10;
end
