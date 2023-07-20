function c=csl_ws_variable(varargin)





    pkgName='rptgen_sl';
    c=feval([pkgName,'.',mfilename]);
    c.init(varargin{:});

    c.filteredPropHash=containers.Map;