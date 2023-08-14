function c=csl_blk_toworkspace(varargin)










    pkgName='rptgen_sl';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});

    c.isCapture=false;
    c.isResizeFigure='manual';
    c.isInline=false;
