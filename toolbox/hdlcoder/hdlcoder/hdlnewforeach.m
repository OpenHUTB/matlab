function [ctrlstmt, implchoices, implparams] = hdlnewforeach(block)
% Warning! This function is DEPRECATED for external use.
%
% Please use hdlset_param interface to set model and block properties in
% HDL Coder

%   Copyright 2006-2021 The MathWorks, Inc.
%     

if nargin < 1
    block = local_gsb;
end

[ctrlstmt, implchoices, implparams] = privhdlnewforeach(block);


% ----------------------------------------------------------------
function h = local_gsb(sys,depth)

if nargin<1, sys=gcs; end
if nargin<2, depth=inf; end
wstate=warning; warning('off'); %#ok
try
    % Could fail if no simulink models/libraries loaded
    % @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
    % instead use the post-compile filter activeVariants() - g2603139
    h = find_system(sys, ...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,... % look only inside active choice of VSS
        'SearchDepth',   depth, ...
        'FollowLinks',   'on', ...
        'LookUnderMasks','all', ...
        'type',          'block', ...
        'selected',      'on');
    
    % Remove sys itself from the search results
    % We only want to return what's "under" sys,
    % one level or more (depending on depth), but
    % not sys itself.
    h = setdiff(h,sys);
    
catch me
    h = [];  % no systems loaded
end
warning(wstate);


    
% [EOF]

