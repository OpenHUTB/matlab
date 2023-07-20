function uavAddons
%uavAddons Install add-ons for UAV Toolbox
%   This function allows you to download and install add-ons for
%   UAV Toolbox.

%   Copyright 2020 The MathWorks, Inc.

% Bring up Add-On Explorer to show all add-ons for UAV Toolbox.

matlab.addons.supportpackage.internal.explorer.showSupportPackagesForBaseProducts('UV', 'tripwire');

end
