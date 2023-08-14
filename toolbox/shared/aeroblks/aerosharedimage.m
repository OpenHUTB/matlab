function out=aerosharedimage(varargin)
%AEROSHAREDIMAGE function for the icon images of Shared Aerospace Blockset.
%

%   Copyright 2015-2019 The MathWorks, Inc.

% Error in case of less than 1 input or when there are too many inputs
narginchk(1,4);
action = varargin{1};
blk = varargin{2};

pos = get_param(blk,'Position');
lenx = pos(3)-pos(1);
leny = pos(4)-pos(2);

sfx = 1.0;
sfy = 1.0;

if (lenx < leny)
    sfy = lenx/leny;
elseif ( leny < lenx)
    sfx = leny/lenx;
end

switch action
    % Icons for aerolib blocks:
    
    case 'inertia'
        [xp, yp, xp2, yp2] = inertiaimage(sfx, sfy);
        
        if (lenx < 80) || (leny < 45)
            [xp,yp,xp2,yp2 ] = deal( NaN );
        end
        out.xp = xp;
        out.yp = yp;
        out.xp2 = xp2;
        out.yp2 = yp2;
        
    otherwise
        error(message('shared_aeroblks:sharedaeroimage:invalidBlock'));  
end
end
%-----------------------------------------------------------------
function [xp, yp, xp2, yp2] = inertiaimage(sfx, sfy)
persistent inertia_xp2 inertia_yp2 inertia_xp inertia_yp

if isempty(inertia_xp)
    % create vector arrow
    inertia_xp2 = [0.35 0.65 0.55 0.57 0.35 0.35];
    inertia_yp2 = [0.7  0.7  0.85 0.75 0.75 0.7];
    % create letter I
    inertia_xp = [0.35 0.65 0.65 0.55 0.55 0.65 0.65 0.35 0.35 0.45 ...
        0.45 0.35 0.35];
    inertia_yp = [0.3  0.3  0.35 0.35 0.6  0.6  0.65 0.65 0.6  0.6  ...
        0.35 0.35 0.3];
end
xp2 = scaleimage( inertia_xp2, -0.5, sfx, 0.5);
yp2 = scaleimage( inertia_yp2, -0.5, sfy, 0.5);
xp = scaleimage( inertia_xp, -0.5, sfx, 0.5);
yp = scaleimage( inertia_yp, -0.5, sfy, 0.5);
end
%-----------------------------------------------------------------
function out = scaleimage(in, offset, gain, bias)
out = gain*(in + offset) + bias;
end
