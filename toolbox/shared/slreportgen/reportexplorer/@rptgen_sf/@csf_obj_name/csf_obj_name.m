function c=csf_obj_name(varargin)










    pkgName='rptgen_sf';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
