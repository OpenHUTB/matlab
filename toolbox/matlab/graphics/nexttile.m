function axo=nexttile(varargin)



    [layout,tile,tilespan,tsdefflag]=nexttile_parse(varargin{:});


    if isempty(tile)

        tile=findnextavail(layout,tilespan);
        if~isempty(tile)

            ax=axes('Parent',layout);
            ax.Layout.Tile=tile;
            ax.Layout.TileSpan=tilespan;
        else
            error(message('MATLAB:tiledchartlayout:LayoutFull'));
        end
    else
        if isnumeric(tile)
            hOverlap=layout.computeObjectsInArea(tile,tilespan(1),tilespan(2));
            exactmatch=false(size(hOverlap));
            if~isempty(hOverlap)
                for i=1:numel(hOverlap)
                    if isequal(hOverlap(i).Layout.Tile,tile)&&...
                        (isequal(hOverlap(i).Layout.TileSpan,tilespan)||tsdefflag)&&...
                        (isa(hOverlap(i),'matlab.graphics.axis.AbstractAxes')||isa(hOverlap(i),'matlab.graphics.chart.Chart'))
                        exactmatch(i)=true;
                    end
                end
            end
        else
            hOverlap=layout.computeObjectsInOuterTile(tile);
            exactmatch=false(size(hOverlap));
            for i=1:numel(hOverlap)
                if isa(hOverlap(i),'matlab.graphics.axis.AbstractAxes')||...
                    isa(hOverlap(i),'matlab.graphics.chart.Chart')
                    exactmatch(i)=true;
                end
            end
        end

        if~any(exactmatch)
            delete(hOverlap);

            ax=axes('Parent',layout);
            ax.Layout.Tile=tile;
            ax.Layout.TileSpan=tilespan;
        else
            ax=hOverlap(exactmatch);
            ax=ax(end);
        end
    end


    fig=ancestor(ax,'Figure');
    currfig=get(0,'CurrentFigure');
    if~isempty(fig)
        if~isequal(currfig,fig)
            set(0,'CurrentFigure',fig)
        end
        set(fig,'CurrentAxes',ax)
    end

    if nargout==1
        axo=ax;
    end

end


function tile=findnextavail(layout,tilespan)

    firstempty=layout.computeFirstEmptyTile(tilespan(2),tilespan(1));
    if strcmp(layout.TileArrangement,'flow')||firstempty<=prod(layout.GridSize)
        tile=firstempty;
    else
        tile=[];
    end
end

function[layout,tile,tilespan,tsusingdefaults]=nexttile_parse(varargin)
    narginchk(0,3)
    args=varargin;

    if~isempty(args)&&isa(args{1},'matlab.graphics.layout.Layout')
        layout=args{1};
        args(1)=[];
    else
        layout=matlab.graphics.internal.getCurrentLayout;
    end

    if~isempty(args)&&isscalar(args{1})&&isnumeric(args{1})
        if floor(args{1})==args{1}&&isfinite(args{1})&&args{1}>0
            tile=args{1};
            args(1)=[];
            if tile>=intmax
                throwAsCaller(MException(message('MATLAB:datatypes:TileDataType:ValueNumber')));
            end
        else
            throwAsCaller(MException(message('MATLAB:datatypes:TileDataType:ValueNumber')));
        end
    elseif~isempty(args)&&matlab.graphics.internal.isCharOrString(args{1})
        if strcmpi(args{1},'north')||strcmpi(args{1},'east')||...
            strcmpi(args{1},'south')||strcmpi(args{1},'west')
            tile=args{1};
            args(1)=[];
        else
            throwAsCaller(MException(message('MATLAB:datatypes:TileDataType:ValueString')));
        end

    else
        tile=[];
    end

    if~isempty(args)&&numel(args{1})==2&&isnumeric(args{1})
        if isequal(round(args{1}),args{1})&&all(args{1}>0)&&all(args{1}<intmax)
            tilespan=args{1};
            tsusingdefaults=false;
            args(1)=[];
        else
            throwAsCaller(MException(message('MATLAB:hg:shaped_arrays:TiledGridSizePredicate')));
        end
    else
        tilespan=[1,1];
        tsusingdefaults=true;
    end

    if~isempty(args)
        throwAsCaller(MException(message('MATLAB:tiledchartlayout:InvalidArguments')));
    end

    if isempty(layout)
        layout=tiledlayout('flow');
    end

    if~isempty(tile)&&strcmp(layout.TileArrangement,'fixed')&&isnumeric(tile)

        if strcmpi(layout.TileIndexing,'columnmajor')
            [r,c]=ind2sub(layout.GridSize([1,2]),tile);
        else
            [c,r]=ind2sub(layout.GridSize([2,1]),tile);
        end

        if any(([r,c]+tilespan-1)>layout.GridSize)
            throwAsCaller(MException(message('MATLAB:tiledchartlayout:TileOutOfBounds')));
        end
    end

end

