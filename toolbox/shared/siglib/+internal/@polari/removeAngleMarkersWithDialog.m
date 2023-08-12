function proceed = removeAngleMarkersWithDialog( p )




if ~isempty( p.hCursorAngleMarkers ) || ~isempty( p.hPeakAngleMarkers )


Title = 'Polar Markers';
Quest = 'Existing markers will be removed.';
Btn1 = 'Remove';
Btn2 = 'Cancel';
Default = 'Remove';

try 
s = settings;
if s.matlab.ui.internal.uicontrol.UseRedirect.TemporaryValue
a = uiconfirm( p.Parent, Quest, Title, 'Options', { Btn1, Btn2 }, 'DefaultOption', 1 );
else 
a = questdlg( Quest, Title, Btn1, Btn2, Default );
end 
catch 
a = questdlg( Quest, Title, Btn1, Btn2, Default );
end 
proceed = strcmpi( a, Btn1 );
if proceed
removeAngleMarkers( p );
end 
else 
proceed = true;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLnLvG3.p.
% Please follow local copyright laws when handling this file.

