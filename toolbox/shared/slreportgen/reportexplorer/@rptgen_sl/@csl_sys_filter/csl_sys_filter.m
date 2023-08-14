function this=csl_sys_filter(varargin)







    pkgName='rptgen_sl';
    this=feval([pkgName,'.',mfilename]);
    this.init(varargin{:});
