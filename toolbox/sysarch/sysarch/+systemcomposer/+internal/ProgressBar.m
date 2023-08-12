classdef ProgressBar < systemcomposer.internal.mixin.CenterDialog




properties ( Access = private )
progressBar = [  ]
end 

methods 
function obj = ProgressBar( title, parentDlg, isCircular, minVal, maxVal )
R36
title string
parentDlg
isCircular logical = true;
minVal int32 = 0;
maxVal int32 = 100;
end 

try 

obj.progressBar = DAStudio.WaitBar;


obj.progressBar.setLabelText( char( title ) );
obj.progressBar.setCircularProgressBar( isCircular );
obj.progressBar.setAlwaysOnTop( false );

if ~isCircular
obj.progressBar.setMinimum( minVal );
obj.progressBar.setMaximum( maxVal );
end 


if ~isempty( parentDlg )
obj.positionDialog( obj.progressBar, parentDlg );
end 


obj.progressBar.show(  );

catch Mex %#ok<NASGU>
obj.progressBar = [  ];
end 
end 

function setStatus( obj, title )
obj.progressBar.setLabelText( title );
end 

function setValue( obj, value )
if value < 1
value = int32( value * 100 );
end 
obj.progressBar.setValue( value );
end 

function show( obj )
obj.progressBar.show(  );
end 
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpUm53A5.p.
% Please follow local copyright laws when handling this file.

