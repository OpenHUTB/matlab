function hideDeferredAnalysisNotifications( this, viewer )




R36
this
viewer = [  ];
end 
if isempty( viewer )
allViewers = this.getAllViewers;
else 
allViewers = { viewer };
end 
for i = 1:length( allViewers )
cView = allViewers{ i };
if isvalid( cView )
cView.removeNotificationBanner( this.DEFER_DATA_REFRESH_NOTIFICATION_ID );
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnUQ3ZE.p.
% Please follow local copyright laws when handling this file.

