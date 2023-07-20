function makeInfo=rtwmakecfg()
%RTWMAKECFG adds include and source directories to the generated makefiles.
%   For details refer to documentation on the rtwmakecfg API.

% Copyright 1994-2022 The MathWorks, Inc.

% CAN blocks rely on the CAN_DATATYPE struct defined in can_message.h
makeInfo.includePath{1} = fullfile(matlabroot,'toolbox','shared','can','src',...
		                    'scanutil');
