function this=cfp_summ_table(varargin)






    pkgName='rptgen_fp';
    this=feval([pkgName,'.',mfilename]);
    this.init(varargin{:});
