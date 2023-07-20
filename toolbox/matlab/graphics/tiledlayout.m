function hh=tiledlayout(varargin)



    [parent,flow,nr,nc,nvpairs,explicitparent]=tiledlayout_parse(varargin{:});
    if isempty(parent)
        parent=figure;
    else
        parent=observeFigureNextplot(parent,explicitparent);
    end

    h=matlab.graphics.layout.TiledChartLayout('Parent',parent);
    if(flow)
        h.TileArrangementInternal='flow';
    else
        h.TileArrangementInternal='fixed';
        h.GridSize=[nr,nc];
    end

    if~isempty(nvpairs)
        set(h,nvpairs{:});
    end

    deleteOverlapObjects(h);

    if nargout>0
        hh=h;
    end
end

function parent=observeFigureNextplot(parent,isexplicit)
    fig=ancestor(parent,'figure');
    if~isempty(fig)&&isprop(fig,'NextPlot')
        switch fig.NextPlot
        case 'new'
            if~isexplicit
                parent=figure;
            end
        case 'replace'
            clf(fig,'reset');
        case 'replacechildren'
            clf(fig);
            fig.NextPlot='add';
        end
    end
end

function deleteOverlapObjects(lay)
    if isa(lay.Parent,'matlab.graphics.layout.Layout')

        return
    end

    hContainer=ancestor(lay.Parent,'matlab.ui.internal.mixin.CanvasHostMixin','node');
    objs=findall(hContainer,'-depth',1,...
    {'-isa','matlab.graphics.axis.AbstractAxes','-or',...
    '-isa','matlab.graphics.chart.Chart','-or',...
    '-isa','matlab.graphics.layout.Layout'},'-or',...
    '-isa','matlab.graphics.illustration.subplot.Text');


    objs=objs(objs~=lay&objs~=lay.Parent);

    if isempty(objs)
        return
    end

    eps=1;


    hFig=ancestor(lay.Parent,'figure');
    layPos=hgconvertunits(hFig,lay.OuterPosition,lay.Units,'pixels',hContainer);
    laybb=[layPos(1:2),layPos(1:2)+layPos(3:4)];

    needsDelete=false(numel(objs),1);
    for i=1:numel(objs)
        if isa(objs(i),'matlab.graphics.illustration.subplot.Text')||...
            isappdata(objs(i),'SubplotPosition')

            needsDelete(i)=true;
        else


            objPos=hgconvertunits(hFig,objs(i).OuterPosition,objs(i).Units,'pixels',hContainer);
            objbb=[objPos(1:2),objPos(1:2)+objPos(3:4)];


            if all([laybb(3:4)-objbb(1:2),objbb(3:4)-laybb(1:2)]>eps)
                needsDelete(i)=true;
            end
        end
    end

    if any(needsDelete)


        matlab.graphics.internal.clearNotify(hFig,[])
        delete(objs(needsDelete))
    end
end

function[parent,flow,nr,nc,nvpairs,explicitparent]=tiledlayout_parse(varargin)
    if nargin==0
        throwAsCaller(MException(message('MATLAB:tiledchartlayout:NotEnoughArugments')));
    end

    cp=matlab.graphics.chart.ChartInputParser('ChartClassName',...
    'matlab.graphics.layout.TiledChartLayout');
    nvpairs=cp.parseNameValue(varargin{:});
    [hasParent,parent]=cp.parseInitialParent;
    args=cp.getRemainingArgs;

    flow=false;
    nr=1;
    nc=1;

    if numel(args)<1||numel(args)>2
        throwAsCaller(MException(message('MATLAB:tiledchartlayout:InvalidArguments')));
    end

    if~isempty(parent)&&...
        ((~isa(parent,'matlab.ui.internal.mixin.CanvasHostMixin')&&...
        ~isa(parent,'matlab.graphics.layout.Layout')&&...
        ~isa(parent,'matlab.graphics.chartcontainer.ChartContainer')))
        throwAsCaller(MException(message('MATLAB:hg:InvalidParent',...
        'TiledChartLayout',fliplr(strtok(fliplr(class(parent)),'.')))));
    elseif~isempty(parent)&&~isvalid(parent)
        throwAsCaller(MException(message('MATLAB:class:InvalidHandle')));
    end

    if numel(args)==1&&startsWith('flow',string(args{1}),'IgnoreCase',true)

        flow=true;
    elseif numel(args)==2

        nr=args{1};
        nc=args{2};
        if~isnumeric(nr)||~isnumeric(nc)||...
            ~isreal(nr)||~isreal(nc)||...
            nr~=floor(nr)||nc~=floor(nc)||...
            ~isfinite(nr)||~isfinite(nc)||...
            nr<1||nc<1
            throwAsCaller(MException(message('MATLAB:tiledchartlayout:InvalidGridSize')));
        end
        nr=double(nr);
        nc=double(nc);

        if nr>intmax('int16')||nc>intmax('int16')
            throwAsCaller(MException(message('MATLAB:tiledchartlayout:InvalidGridSize')));
        end
    else
        throwAsCaller(MException(message('MATLAB:tiledchartlayout:InvalidArguments')));
    end

    explicitparent=false;
    if~hasParent
        parent=findParent;
    else
        explicitparent=true;
    end

end

function parent=findParent
    layout=matlab.graphics.internal.getCurrentLayout;
    if~isempty(layout)
        parent=ancestor(layout.Parent,'matlab.ui.internal.mixin.CanvasHostMixin');
    else
        parent=get(groot,'CurrentFigure');
        if~isempty(parent)
            cax=parent.CurrentAxes;
            if~isempty(cax)
                parent=ancestor(cax,'matlab.ui.internal.mixin.CanvasHostMixin');
            end
        end
    end
end
