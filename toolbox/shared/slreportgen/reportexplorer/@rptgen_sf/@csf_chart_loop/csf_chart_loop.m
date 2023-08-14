function c=csf_chart_loop(varargin)










    pkgName='rptgen_sf';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
