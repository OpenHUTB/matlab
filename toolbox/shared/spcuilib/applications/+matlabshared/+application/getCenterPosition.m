function pos = getCenterPosition(size, parent)
%getCenterPosition  Return the position to center the window of a given size

%   Copyright 2017 The MathWorks, Inc.

if nargin < 2 || isempty(parent)
    parentPos = get(0, 'ScreenSize');
elseif ishghandle(parent)
    parentPos = getpixelposition(ancestor(parent, 'figure'));
elseif isnumeric(parent)
    parentPos = parent;
else
    if ischar(parent) || isstring(parent)
        % Parent is a toolgroup name.
        md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
        loc = md.getGroupLocation(parent);
        
        xy = loc.getFrameLocation;
        wh = loc.getFrameSize;
        x = xy.x;
        y = xy.y;
        w = wh.width;
        h = wh.height;
    else
        bounds = parent.WindowBounds;
        x = bounds(1);
        y = bounds(2);
        w = bounds(3);
        h = bounds(4);
    end
    ppss = get(0, 'ScreenSize');
    if ismac
        dpss = ppss;
    else
        dpss = matlab.ui.internal.PositionUtils.getDevicePixelScreenSize;
    end
    pixelRatio = dpss(4)/ppss(4);
    
    matlabY = (dpss(4) - y - h)/pixelRatio; % convert from Java
    
    % correct the x-coordinate in case the primary monitor is on
    % the right.
    monitorPositions = get(0, 'MonitorPositions');
    origin = min(monitorPositions(:, 1:2));
    
    parentPos = [x/pixelRatio+max(origin(1),0) matlabY w/pixelRatio h/pixelRatio];
end
pos = [parentPos(1)+(parentPos(3)-size(1))/2 parentPos(2)+(parentPos(4)-size(2))/2 size];


% [EOF]
