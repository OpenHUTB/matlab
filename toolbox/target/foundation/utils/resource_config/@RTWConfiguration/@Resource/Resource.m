function h=Resource(varargin)

















    h=RTWConfiguration.Resource;


    h.allocations=RTWConfiguration.Terminator;
    switch nargin
    case 0

    case 1

        h.resource=varargin{1};

    otherwise
        TargetCommon.ProductInfo.warning('common','NumInputArgsInvalid')
    end
