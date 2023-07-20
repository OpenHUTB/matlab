function h=SLDataClassDesign_ClassDefn_Constructor(h,varargin)















    nargin=length(varargin);


    switch nargin
    case 0
    case 4
        h.ClassName=varargin{1};
        h.DeriveFromPackage=varargin{2};
        h.DeriveFromClass=varargin{3};
        h.Initialization=varargin{4};
    otherwise
        DAStudio.error('Simulink:dialog:DCDInvalidNumberofArgs');
    end






