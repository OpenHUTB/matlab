function c=csf_property(varargin)










    pkgName='rptgen_sf';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
