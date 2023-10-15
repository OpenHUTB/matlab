function hideDeferredAnalysisNotifications( this, viewer )

arguments
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
