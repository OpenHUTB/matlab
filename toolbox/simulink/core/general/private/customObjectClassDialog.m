function customObjectClassDialog( varargin )




if nargin == 0
dlgSrc = Simulink.data.CustomObjectClassDDG;
else 
parentDialog = varargin{ 1 };
dlgSrc = Simulink.data.CustomObjectClassDDG( parentDialog );
end 
DAStudio.Dialog( dlgSrc, '', 'DLG_STANDALONE' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZu4X_s.p.
% Please follow local copyright laws when handling this file.

