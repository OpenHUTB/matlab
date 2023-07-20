function ret = iosource(hwObj,ioSourceName,varargin)
%SOC.IOSOURCE Create source object for specified input source on SoC
%hardware board
%
% availableSources = soc.iosource(hw) returns a list of input sources
% available for data logging on the SoC hardware board connected through
% hw. The hw input is a connection to an SoC hardware board, established
% using the socHardwareBoard function.
%
% src = soc.iosource(hw,inputsourceName) creates a source object
% corresponding to inputsourceName on the SoC hardware board connected
% through hw. The hw input is a connection to an SoC hardware board,
% established using the socHardwareBoard function.
%
% Input Arguments: 
%                hw - Connection to specific SoC hardware board
%                     soc.internal.zynq object | soc.internal.intelsoc object
%   inputsourceName - Name of available input source on SoC hardware board
%                     character vector
%
% Output Arguments:
%   availableSources - List of input data sources available for data logging
%                      cell array
%                src - Source object for specified input source
%                      soc.iosource.TCPRead object | soc.iosource.UDPRead object | soc.iosource.AXIRegisterRead object | soc.iosource.AXIStreamRead object
%
% Examples:
%
%   % Get the list of input sources available for data logging on the Xilinix Zynq ZC706 evaluation kit
%   hw = soc.device('Xilinx Zynq ZC706 evaluation kit','hostname','192.168.1.18','username','root','password','root');
%   availableSources = soc.iosource(hw)
%  
%      availableSources =
%        1×4 cell array
% 
%          {'UDP Receive'}    {'TCP Receive'}    {'AXI Stream Read'}    {'AXI Register Read'}
%
%   % Create a UDP (User Datagram Protocol) source object for data logging on the Xilinix Zynq ZC706 evaluation kit
%   hw = socHardwareBoard('Xilinx Zynq ZC706 evaluation kit','hostname','192.168.1.18','username','root','password','root');
%   udpSrc = soc.iosource(hw,'UDP Receive')
%   udpSrc = 
%      soc.iosource.UDPReceive with properties:
% 
%      Main
%                 LocalPort: 25000
%                DataLength: 1
%                  DataType: 'uint8'
%         ReceiveBufferSize: -1
%              BlockingTime: 0
%       OutputVarSizeSignal: false
%                SampleTime: 0.1000
%            HideEventLines: true
% 
%   Show all properties
%  

% Copyright 2019 The MathWorks, Inc.
if isa(hwObj,'ioplayback.hardware.Base') && ~isa(hwObj,'matlab.io.linux.BaseHardware')
    error(message('soc:utils:UnsupportedHardware'));
end
if ~isa(hwObj,'matlab.io.linux.BaseHardware')
    error(message('soc:utils:InvalidHardwareObject'));
end

if nargin == 1
    ret = listSources(hwObj);
else
    ret = createSource(hwObj,ioSourceName,varargin{:});
end
end
