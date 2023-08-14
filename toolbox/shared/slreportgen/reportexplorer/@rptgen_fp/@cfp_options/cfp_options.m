function this=cfp_options(varargin)







    pkgName='rptgen_fp';
    this=feval([pkgName,'.',mfilename]);
    this.init(varargin{:});
