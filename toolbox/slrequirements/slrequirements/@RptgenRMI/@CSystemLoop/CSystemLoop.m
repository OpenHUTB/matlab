function c=CSystemLoop(varargin)







    pkgName='RptgenRMI';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
