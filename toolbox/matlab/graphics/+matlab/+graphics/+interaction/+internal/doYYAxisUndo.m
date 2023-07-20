function doYYAxisUndo(undofcn,hFig,proxyVal,origside,varargin)
    hAxes=plotedit({'getHandleFromProxyValue',hFig,proxyVal});
    side_enum={'left','right'};
    if strcmp(side_enum{hAxes.ActiveDataSpaceIndex},origside)
        undofcn(hFig,proxyVal,varargin{:});
    elseif strcmp(origside,'left')
        yyaxis(hAxes,'left');
        undofcn(hFig,proxyVal,varargin{:});
        yyaxis(hAxes,'right');
    else
        yyaxis(hAxes,'right');
        undofcn(hFig,proxyVal,varargin{:});
        yyaxis(hAxes,'left');
    end