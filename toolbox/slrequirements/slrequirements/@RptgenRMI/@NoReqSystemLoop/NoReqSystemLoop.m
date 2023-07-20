function c=NoReqSystemLoop(varargin)







    pkgName='RptgenRMI';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
