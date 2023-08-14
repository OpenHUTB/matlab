function h=CPPFcnVoidArgSpec(varargin)






    h=RTW.CPPFcnVoidArgSpec;
    if nargin==3
        h.SLObjectName=varargin{1};
        h.SLObjectType=varargin{2};
        h.Category='None';
        h.ArgName='';
        h.Position=99999999;
        h.Qualifier='none';
        h.PortNum=varargin{3};
    end
