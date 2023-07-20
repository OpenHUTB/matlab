function c=cfp_blk_loop(varargin)







    pkgName='rptgen_fp';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
