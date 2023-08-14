function c=csf_obj_loop(varargin)










    pkgName='rptgen_sf';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
