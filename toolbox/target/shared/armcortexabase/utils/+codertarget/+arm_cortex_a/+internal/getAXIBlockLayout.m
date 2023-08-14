function [blockPosition, dtcPosition] = getAXIBlockLayout(portType, xportPosition)
% GETBLOCKLAYOUT Get layout of data-type converter block and AXI Interface
% blocks based on the port position.
% 
% Example:
%   [axiBlockPos, dataTypeConvPos] =  getBlockLayout('Inport', [100 100 150 130])


%%
% Block Position:
%  pos = get_param(blk, 'Position');
%  L = pos(1); % LEFT                 +-- TOP ---+
%  R = pos(2); % TOP                  |          |
%  B = pos(3); % RIGHT              LEFT       RIGHT
%  T = pos(4); % BOTTOM               |          |
%                                     +- BOTTOM -+
%
%
% For input port:
%
%                         dtcBlkHeight--+          blkHeight--+
%                                       |                     |
%                                       |       +--blkTop-+-- |
%   +--------+        +-dtcBlkTop-+ <---+       |         |   | 
%   | INPORT |=======>| DTC BLK   |============>| AXI BLK | <-+ 
%   +--------+        +-----------+             |         |
%     dtcBlkLeft----->|<--------->|             +---------+--
%                       dtcBlkWidth  blkLeft--->|<------->|
%                                                blkWidth
%
% For output port:
%
%  
%   +---blkHeight     
%   |--+--blkTop-+                             
%   |  |         |      +-dtcBlkTop-+          +---------+
%   +->| AXI BLK +=====>| DTC BLK   +=========>| OUTPORT |
%      |         |      +-----------+          +---------+
%    --+---------+      |<--------->|
%      |<------->|       dtcBlkWidth
%        blkWidth
%   

%  Copyright 2015 The MathWorks, Inc.

% Height and Width of DTC Blocks
dtcBlkHeight = 15;
dtcBlkWidth = 24;

blkHeight = 20;
blkWidth = 48;
% Height and Width of Input and output ports
portHeight = xportPosition(4)-xportPosition(2);
portWidth = xportPosition(3)-xportPosition(1);

if isequal(portType, 'Inport')
    startLeftInport = xportPosition(3);
    startTopInport = xportPosition(2);
    
    % Data type conversion block
    dtcBlkLeft = startLeftInport + portWidth;
    dtcBlkTop = startTopInport  - ((dtcBlkHeight - portHeight)/2);
    dtcPosition = [dtcBlkLeft dtcBlkTop dtcBlkLeft+dtcBlkWidth dtcBlkTop+dtcBlkHeight];
    
    % AXI4 Write block
    blkLeft = dtcBlkLeft + dtcBlkWidth + portWidth;
    blkTop = startTopInport  - ((blkHeight - portHeight)/2);
    blockPosition = [blkLeft blkTop blkLeft+blkWidth blkTop+blkHeight];
else
    startLeftInport = xportPosition(1);
    startTopInport = xportPosition(2);
    
    % Data type conversion block
    dtcBlkLeft = startLeftInport - portWidth - dtcBlkWidth;
    dtcBlkTop = startTopInport  - ((dtcBlkHeight - portHeight)/2);
    dtcPosition =   [dtcBlkLeft dtcBlkTop dtcBlkLeft+dtcBlkWidth dtcBlkTop+dtcBlkHeight];
    
    % AXI4 Read block
    blkLeft = dtcBlkLeft - dtcBlkWidth - 2*portWidth;
    blkTop = startTopInport  - ((blkHeight - portHeight)/2);
    blockPosition =   [blkLeft blkTop blkLeft+blkWidth blkTop+blkHeight];
end
end