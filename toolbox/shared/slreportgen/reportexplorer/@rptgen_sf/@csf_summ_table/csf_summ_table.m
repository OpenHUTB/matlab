function c=csf_summ_table(varargin)




    pkgName='rptgen_sf';



    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
