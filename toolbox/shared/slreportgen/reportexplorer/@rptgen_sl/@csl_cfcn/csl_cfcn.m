function this=csl_cfcn(varargin)





    pkgName='rptgen_sl';
    this=feval([pkgName,'.',mfilename]);
    this.init(varargin{:});
