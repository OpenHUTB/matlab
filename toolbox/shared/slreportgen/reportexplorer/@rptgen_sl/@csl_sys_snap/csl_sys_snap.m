function this=csl_sys_snap(varargin)







    pkgName='rptgen_sl';
    this=feval([pkgName,'.',mfilename]);
    this.init(varargin{:});
