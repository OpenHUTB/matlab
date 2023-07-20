function h=SLDataClassDesign_PackageDefn_Constructor(h,varargin)















    nargin=length(varargin);


    switch nargin
    case 0
    case 3
        h.PackageName=varargin{1};
        h.PackageDir=varargin{2};
        h.CSCHandlingMode=varargin{3};
    otherwise
        DAStudio.error('Simulink:dialog:DCDInvalidNumberofArgs');
    end






