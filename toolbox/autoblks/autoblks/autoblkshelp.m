function autoblkshelp(fileStr)
% AUTOBLKSHELP Powertrain Blockset on-line help function.
%   Points Web browser to the help page corresponding to this
%   Automotive Blockset block.  The current block is queried for its MaskType.
%
%   Typical usage:
%      set_param(gcb,'MaskHelp','eval(''asbhelp'');');

% Copyright 2015-2018 The MathWorks, Inc.

narginchk(0,1);

mapfile_location = fullfile(docroot,'autoblks','helptargets.map');

   if nargin < 1
      % Derive help file name from mask type:
      doc_tag = getblock_help_file(gcb);
   else
      % Derive help file name from fileStr argument:
      doc_tag = getblock_help_file(gcb, fileStr);
   end

   helpview(mapfile_location, doc_tag);
return

% --------------------------------------------------------
function help_file = getblock_help_file(blk, varargin)

if nargin > 1
    fileStr = varargin{1};
else
    % Only masked Aerospace Blockset blocks call asbhelp, so if
    % we get here, we know we can get the MaskType string.
    fileStr = get_param(blk,'MaskType');
end

help_file = help_name(fileStr);

return

% ---------------------------------------------------------
function y = help_name(x)
% Returns proper help-file name
%
% Invoke same naming convention as used with the auto-generated help
% conversions for the blockset on-line manuals.
%
% - only allow a-z, 0-9, underscore, and '.'
% - truncate to 55 chars max

if isempty(x), x='default'; end
y = lower(x);

y(isspace(y)) = '_';
dash_idx = ( y == '-' );
y(dash_idx)  = '_';

digit_idx = ( y >= '0' & y <= '9' );
underscore_idx = ( y == '_' );
period_idx = ( y == '.' );

valid_char_idx = isletter(y) | digit_idx | underscore_idx | period_idx ;

y = y(valid_char_idx);  % Remove invalid characters

return

% [EOF] AUTOBLKSHELP.M
