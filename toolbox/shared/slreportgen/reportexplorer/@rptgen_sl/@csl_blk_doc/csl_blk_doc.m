function c=csl_blk_doc(varargin)







    pkgName='rptgen_sl';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
