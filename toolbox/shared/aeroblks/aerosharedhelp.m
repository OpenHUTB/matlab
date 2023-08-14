function aerosharedhelp(fileStr)
% AEROSHAREDHELP Shared Aerospace Blockset on-line help function.
%   Points Web browser to the help page corresponding to this
%   Shared Aerospace Blockset block.  The current block is queried for its 
%   MaskType.
%
%   Typical usage:
%      set_param(gcb,'MaskHelp','eval(''asbhelp'');');

% Copyright 2015-2018 The MathWorks, Inc.

narginchk(0,1);

% Note that we don't check for existence of map files. On Japanese
% Windows, the actual file does not exist, but helpview properly falls
% back to the English map file. 

   if nargin < 1
      % Derive help file name from mask type:
      doc_tag = getblock_help_file(gcb);
   else
      % Derive help file name from fileStr argument:
      doc_tag = getblock_help_file(gcb, fileStr);
   end
   % To open the aero help it is needed that a license for aero is
   % available and that the help target exists. This is becuase a customer
   % can have the license for both but only install the shared component.
   if license('test','Aerospace_Blockset') && ...
      exist(fullfile(docroot,'aeroblks','aeroblks.map'),'file')
       mapfile_location = fullfile(docroot,'toolbox','aeroblks','aeroblks.map');
       helpview(mapfile_location, doc_tag);
   else
       helpview(fullfile(docroot,'toolbox','simulink','helptargets.map'),'collection')
   end
   
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

% Version 3.19 libraries: (This line should be changed every time the
% library is updated with new blocks or blocks are obsoleted in
% aerosharedliblist).
s = aerosharedliblist;
libsv = s.aero319;

refBlock = get_param(blk,'ReferenceBlock'); 
maskType = get_param(blk,'MaskType');
if ~isempty(refBlock) 
    sys = fileparts(refBlock);
else
   % This case is for whenever the block links have been broken.
   sys = get_param(blk,'Parent');
end 

if ~any(strncmp(sys,libsv,length(sys))) || ~any(length(sys) == cellfun('length',libsv(strncmp(sys,libsv,length(sys)))))
    % Not a mask help supported block, no online help is available.
    errordlg(getString(message('shared_aeroblks:sharedasbhelp:noDoc')),...
             getString(message('shared_aeroblks:sharedasbhelp:noDocTitle')));
    
    fileStr = 'aeroblks_compatibility';
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

% [EOF] aerosharedhelp.m
