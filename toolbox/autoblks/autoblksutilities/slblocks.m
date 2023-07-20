function blkStruct = slblocks
% SLBLOCKS Defines the Simulink library block representation for the
% Powertrain Blockset.

% Copyright 2015-2018 The MathWorks, Inc.

% Name of the subsystem which will show up in the Simulink Blocksets
% and Toolboxes subsystem
blkStruct.Name = sprintf('Powertrain\nBlockset');
   
% Function that is run when user double clicks the mask
blkStruct.OpenFcn = 'autolib';

% The argument to be set as the Mask Display for the subsystem.
% Comment this line out if no specific mask is desired.
%blkStruct.MaskDisplay = 'disp(''AUTO'')';

% Specifying the entry for the Powertrain Blockset in the repository
Browser.Library  = 'autolib';
Browser.Name     = 'Powertrain Blockset';
%Browser.Type     = 'Palette';
Browser.IsFlat   = 0;
%Browser.Children = {''};
blkStruct.Browser = Browser;
% End of slblocks.m