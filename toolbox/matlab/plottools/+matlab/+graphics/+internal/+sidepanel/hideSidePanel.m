function hideSidePanel(panelId, parentFigure)
% Hide side panel is used to deactivate the context of the side panel
% DO NOT REMOVE - Used by Codegen Widget as it provides option to user to
% opt in to the widget and opt out of it.

% Copyright 2021 The MathWorks, Inc.

channel = "/figure/sidePanel/hidePanel";
if isprop(parentFigure, 'FigureChannelId')
    channelID = get(parentFigure, 'FigureChannelId');
else
    channelID = matlab.ui.internal.FigureServices.getUniqueChannelId(parentFigure);
end
channel = channel+channelID;

% Add other properties used for showing the tool in the side panel
data.FigureId = channelID;
% Context id for the figure tool
data.ContextId = strcat("sidepanel/",panelId,"/",channelID);

% Send the data to front end.
message.publish(channel,data);
end