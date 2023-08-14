function showSidePanel(divFigure,panelId,title,region,createPanelCollapsed,parentFigure,parentNodeId,doAdd)

%    This function decides whether to add figure tool to the side panel
%    or just update the right context based on the figure tools' contextid

%    divFigure: div figure containing the figure tool
%    panelId: Should be unique to a particular figure tool e.g. inspector
%    title: Title of the panel e.g. 'Property Inspector'
%    region: Region of the container where the panel should show e.g.
%    'right'
%    parentFigure: Used for getting the unique channel id and publishing
%    message to the client using channelId so side panel shows up for the
%    right figure
%    createPanelCollapsed: Should the panel be created as collapsed (true)
%    or expanded (false).
%    parentNodeId: ID associated to the parent dom node used for creating
%    client-side panel.
%    doAdd: true when panel needs to be added. false when panel exists, but
%    context is not active

%    FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%    and is intended for use only with the scope of function in the MATLAB
%    Engine APIs.  Its behavior may change, or the function itself may be
%    removed in a future release.

% Copyright 2021 The MathWorks, Inc.

if doAdd
    matlab.graphics.internal.sidepanel.addSidePanel(divFigure, ...
        panelId, ...
        title, ...
        region, ...
        createPanelCollapsed, ...
        parentFigure, ...
        parentNodeId);
else
    matlab.graphics.internal.sidepanel.activateSidePanelContext(divFigure, ...
        panelId, ...
        title, ...
        region, ...
        parentFigure, ...
        parentNodeId);
end
end