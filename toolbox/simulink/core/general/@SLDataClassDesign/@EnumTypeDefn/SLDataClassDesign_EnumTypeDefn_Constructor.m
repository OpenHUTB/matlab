function h=SLDataClassDesign_EnumTypeDefn_Constructor(h,varargin)















    nargin=length(varargin);


    switch nargin
    case 0
    case 2
        h.EnumTypeName=varargin{1};
        h.EnumStrings=varargin{2};
    otherwise
        DAStudio.error('Simulink:dialog:DCDInvalidNumberofArgs');
    end






