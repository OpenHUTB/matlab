function c=CBlockLoop(varargin)







    pkgName='RptgenRMI';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
