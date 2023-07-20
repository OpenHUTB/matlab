function c=csf_obj_name(varargin)










    pkgName='RptSldv';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
