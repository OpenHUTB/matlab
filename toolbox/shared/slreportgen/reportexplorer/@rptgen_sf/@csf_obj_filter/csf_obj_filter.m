function c=csf_obj_filter(varargin)







    pkgName='rptgen_sf';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
