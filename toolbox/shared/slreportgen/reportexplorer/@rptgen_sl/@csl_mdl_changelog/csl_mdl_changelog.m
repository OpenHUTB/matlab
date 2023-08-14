function c=csl_mdl_changelog(varargin)










    pkgName='rptgen_sl';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
