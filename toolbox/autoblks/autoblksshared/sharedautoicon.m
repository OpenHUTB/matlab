function varargout=sharedautoicon(varargin)
% SHAREDAUTOICON Gateway function to the shared blocks in the Powertrain
% Blockset

%   Copyright 2018 The MathWorks, Inc.

if nargin==0
    error(message('autoblks:autoerrAutoIcon:invalidUsage'));
end
action = varargin{1};
varargout = cell(nargout,1);

switch action
    % Icons for aerolib blocks:
    case {'shared3dofbody','shared6dofbody','sharedang2dcm','sharedang2quat',...
            'shareddcm2ang','sharedquat2ang','shared'}
        if (length(varargin) < 2)
            aerosharedicon(varargin{:});
        else
            varargout{1} = aerosharedicon(varargin{:});
        end
otherwise
    error(message('autoblks:autoerrAutoIcon:invalidBlock'));
end
