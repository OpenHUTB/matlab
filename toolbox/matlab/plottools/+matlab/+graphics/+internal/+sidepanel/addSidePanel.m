function addSidePanel(divFigure,panelId,title,region,createPanelCollapsed,parentFigure,parentNodeId)

%    This function publishes a message to client (SidePanelManager.js) to
%    add side panel to the figure's uicontainer. 

%    divFigure: div figure containing the figure tool
%    panelId: Should be unique to a particular figure tool e.g. inspector
%    title: Title of the panel e.g. 'Property Inspector'
%    region: Region of the container where the panel should show e.g.
%    'right'
%    createPanelCollapsed: Should the panel be created as collapsed (true)
%    or expanded (false).
%    parentFigure: Used for getting the unique channel id and publishing
%    message to the client using channelId so side panel shows up for the
%    right figure
%    parentNodeId: ID associated to the parent dom node used for creating
%    client-side panel.

%    FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%    and is intended for use only with the scope of function in the MATLAB
%    Engine APIs.  Its behavior may change, or the function itself may be
%    removed in a future release.

% Copyright 2021 The MathWorks, Inc.

% Channel subscription used in SidePanelManager.js
channel = "/figure/sidePanel/addPanel";

if isprop(parentFigure, 'FigureChannelId')
    channelID = get(parentFigure, 'FigureChannelId');
else
    channelID = matlab.ui.internal.FigureServices.getUniqueChannelId(parentFigure);
end

try
    % Get the figure packet from the figure service. This will
    % be forwarded to the client.
    data.FigureData = {};
    if ~isempty(divFigure)
        figureData = matlab.ui.internal.FigureServices.getDivFigurePacket(divFigure);
        data.FigureData = figureData;
    end
catch ME
    data.ErrorMessage = ME.message;
    data.FigureData = {};
end

% Add other properties used for showing the tool in the side panel
data.FigureId = channelID;
% Create a unique id for the figure tool in side panel (should be unique
% for figure id)
data.PanelId = strcat(panelId,"/",channelID);
% Context id for the figure tool
data.ContextId = strcat("sidepanel/",data.PanelId);
data.ChannelId = channelID;
data.Title = title;
data.Region = region;
data.CreatePanelCollapsed = createPanelCollapsed;
data.ParentNodeId = parentNodeId;
message.publish(channel,data);
end