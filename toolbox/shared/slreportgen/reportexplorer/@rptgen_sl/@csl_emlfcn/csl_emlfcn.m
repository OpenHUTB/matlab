function this=csl_emlfcn(varargin)





    pkgName='rptgen_sl';
    this=feval([pkgName,'.',mfilename]);
    this.init(varargin{:});
