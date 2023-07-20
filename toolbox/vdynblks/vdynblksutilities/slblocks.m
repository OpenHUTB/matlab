function blkStruct = slblocks
% SLBLOCKS Defines the Simulink library block representation for the
% Vehicle Dynamics Blockset.

% Copyright 2016-2018 The MathWorks, Inc.

% Name of the subsystem which will show up in the Simulink Blocksets
% and Toolboxes subsystem
blkStruct.Name = sprintf('Vehicle Dynamics\nBlockset');
   
% Function that is run when user double clicks the mask
blkStruct.OpenFcn = 'vdynlib';

% The argument to be set as the Mask Display for the subsystem.  You
% may comment this line out if no specific mask is desired.
% Example:  blkStruct.MaskDisplay = 'plot([0:2*pi],sin([0:2*pi]));';
%
%blkStruct.MaskDisplay = 'disp(''AUTO'')';

% Specifying the entry for 'Simscape' in the LB repository
Browser.Library  = 'vdynlib';
Browser.Name     = 'Vehicle Dynamics Blockset';
%Browser.Type     = 'Palette';
Browser.IsFlat   = 0;
%Browser.Children = {''};
blkStruct.Browser = Browser;
% End of slblocks.m