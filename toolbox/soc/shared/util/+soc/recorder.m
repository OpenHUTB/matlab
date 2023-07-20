function dr = recorder(hwObj,varargin)
%SOC.RECORDER Create data recording session for specified SoC hardware board
%
% dr = soc.recorder(hw) creates a data recording session, dr on the SoC
% hardware board connected through hw. The hw input is a connection to an
% SoC hardware board, established using the socHardwareBoard function. The
% data recording session is a DataRecorder object. hw is an
% soc.internal.zynq or soc.internal.intelsoc object created using the
% socHardwareBoard function.
%
% Input Arguments:
%   hw - Connection to specific SoC hardware board
%        soc.internal.zynq object | soc.internal.intelsoc object
%
% Output Arguments:
%   dr - Data recording session for specified SoC hardware board
%        DataRecorder object
%
% Examples:
%
%   % Create a data recording session on the SoC hardware board by using the soc.internal.zynq object
%   hw = socHardwareBoard('Xilinx Zynq ZC706 evaluation kit','hostname','192.168.1.18','username','root','password','root');
%   dr = soc.recorder(hw)
%   
%   dr = 
%      DataRecorder with properties:
% 
%           HardwareName: 'Xilinx Zynq ZC706 evaluation kit'
%                Sources: {}                            
%              Recording: false    

% Copyright 2019 The MathWorks, Inc.
if isa(hwObj,'ioplayback.hardware.Base') && ~isa(hwObj,'matlab.io.linux.BaseHardware')
    error(message('soc:utils:UnsupportedHardware'));
end
if ~isa(hwObj,'matlab.io.linux.BaseHardware')
    error(message('soc:utils:InvalidHardwareObject'));
end

dr = getDataRecorderObject(hwObj,varargin{:});
end

