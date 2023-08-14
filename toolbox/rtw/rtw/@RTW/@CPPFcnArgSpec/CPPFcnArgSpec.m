function h=CPPFcnArgSpec(varargin)






    h=RTW.CPPFcnArgSpec;
    if nargin==8
        h.SLObjectName=varargin{1};
        h.SLObjectType=varargin{2};
        h.Category=varargin{3};
        h.ArgName=varargin{4};
        h.Position=varargin{5};
        h.Qualifier=varargin{6};
        h.PortNum=varargin{7};
        h.RowID=varargin{8};
    end

