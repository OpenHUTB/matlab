function c=NoReqBlockLoop(varargin)







    pkgName='RptgenRMI';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
