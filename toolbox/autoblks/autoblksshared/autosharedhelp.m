function autosharedhelp(fileStr)
% AUTOSHAREDHELP.M Shared on-line help function.
%   Points Web browser to the help page corresponding to the correct product.
%   Typical usage:
%      set_param(gcb,'MaskHelp','eval(''asbhelp'');');

% Copyright 2018-2020 The MathWorks, Inc.

narginchk(0,1);

   if nargin < 1
      % Derive help file name from mask type:
      doc_tag = getblock_help_file(gcb);
   else
      % Derive help file name from fileStr argument:
      doc_tag = getblock_help_file(gcb, fileStr);
   end
   
   docType = autosharedtest(gcb);
   switch docType
       case '1'
           mapfile_location = fullfile(docroot,'autoblks','helptargets.map'); % PTBS 
       case '2'
           mapfile_location = fullfile(docroot,'vdynblks','helptargets.map'); % VDBS 
       case '3'
           mapfile_location = fullfile(docroot,'driving','helptargets.map'); % ADST  
       case '5'
           mapfile_location = fullfile(docroot,'mcb','mcb.map'); % MCB
       otherwise
           mapfile_location = fullfile(docroot,'autoblks','helptargets.map'); % PTBS 
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
%% We don't need this now but potentially could use a similar scheme later
% % Version 3.17 libraries: (This line should be changed every time the
% % library is updated with new blocks or blocks are obsoleted in
% % aeroliblist).
% s = aeroliblist;
% libsv = s.aero317;
% 
% refBlock = get_param(blk,'ReferenceBlock'); 
% maskType = get_param(blk,'MaskType');
% if ~isempty(refBlock) 
%     sys = fileparts(refBlock);
% else
%    % This case is for whenever the block links have been broken.
%    sys = get_param(blk,'Parent');
% end 
% 
% if ~any(strncmp(sys,libsv,length(sys))) || ~any(length(sys) == cellfun('length',libsv(strncmp(sys,libsv,length(sys)))))
%     % Not a mask help supported block, no online help is available.
%     errordlg(getString(message('aeroblks:asbhelp:noDoc')),...
%              getString(message('aeroblks:asbhelp:noDocTitle')));
%     
%     fileStr = 'aeroblks_compatibility';
% end

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

% [EOF] asbhelp.m
