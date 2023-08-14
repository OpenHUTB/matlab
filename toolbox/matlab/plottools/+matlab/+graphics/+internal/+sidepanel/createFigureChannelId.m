function createFigureChannelId(channelId)

%    This function stores the channelId for the current figure for publishing
%    messages to the client (called from SidePanelManager.js)

%    FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%    and is intended for use only with the scope of function in the MATLAB
%    Engine APIs.  Its behavior may change, or the function itself may be
%    removed in a future release.

% Copyright 2021 The MathWorks, Inc.

hFig = get(groot,'CurrentFigure');
if isempty(hFig)
    return
end

if ~isprop(hFig,'FigureChannelId')
    pFigChannelId = addprop(hFig,'FigureChannelId');
    pFigChannelId.Transient = true;
    pFigChannelId.Hidden = true;
end

hFig.FigureChannelId = channelId;
end