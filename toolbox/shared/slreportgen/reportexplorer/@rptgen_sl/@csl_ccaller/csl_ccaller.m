function this=csl_ccaller(varargin)





    pkgName='rptgen_sl';
    this=feval([pkgName,'.',mfilename]);
    this.init(varargin{:});
