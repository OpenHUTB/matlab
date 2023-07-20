function h=SLDataClassDesign_CustomStorageClassDefn_Constructor(h,varargin)















    nargin=length(varargin);


    switch nargin
    case 0
    case 3
        h.CustomStorageClassName=varargin{1};
        h.TLCFileToUse=varargin{2};
        h.AttributesClass=varargin{3};
    otherwise
        DAStudio.error('Simulink:dialog:DCDInvalidNumberofArgs');
    end






