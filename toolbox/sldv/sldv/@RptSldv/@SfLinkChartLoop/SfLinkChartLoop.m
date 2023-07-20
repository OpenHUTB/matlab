function c=SfLinkChartLoop(varargin)










    pkgName='RptSldv';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});
