function h=SLDataClassDesign_PropertyDefn_Constructor(h,varargin)















    nargin=length(varargin);


    switch nargin
    case 0
    case 3
        h.PropertyName=varargin{1};
        h.PropertyType=varargin{2};
        h.FactoryValue=varargin{3};
    otherwise
        DAStudio.error('Simulink:dialog:DCDInvalidNumberofArgs');
    end






