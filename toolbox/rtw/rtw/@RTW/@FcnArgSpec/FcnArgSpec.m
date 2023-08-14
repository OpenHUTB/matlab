function h=FcnArgSpec(varargin)






    h=RTW.FcnArgSpec;
    if nargin==8
        h.SLObjectName=varargin{1};
        h.SLObjectType=varargin{2};
        h.Category=varargin{3};
        h.ArgName=varargin{4};
        if strcmp(h.Category,'None')
            h.Position=99999999;
        else
            h.Position=varargin{5};
        end

        h.Qualifier=varargin{6};
        h.PortNum=varargin{7};
        h.RowID=varargin{8};
    end

