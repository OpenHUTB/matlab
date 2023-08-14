function c=csl_obj_fun_var(varargin)










    pkgName='rptgen_sl';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
