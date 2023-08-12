function [ SBSigSuite, throwWarning ] = update_sbobj( blockH, varargin )






noUpdate = 0;
if nargin == 2
noUpdate = varargin{ 1 };
end 


throwWarning = 0;

if ~noUpdate


fromWsH = find_system( blockH, 'FollowLinks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'LookUnderMasks', 'all', 'BlockType', 'FromWorkspace' );
savedUD = get_param( fromWsH, 'SigBuilderData' );

if ~isfield( savedUD, 'sbobj' )

SBSigSuite = SigSuite( savedUD );
savedUD.sbobj = SBSigSuite;
set_param( fromWsH, 'SigBuilderData', savedUD );
throwWarning = 1;
else 

if ~isempty( savedUD.sbobj ) && iscell( savedUD.sbobj.Groups )
SBSigSuite = convertFrom2008a( savedUD );
savedUD.sbobj = SBSigSuite;
set_param( fromWsH, 'SigBuilderData', savedUD );
throwWarning = 1;

elseif ~isempty( savedUD.sbobj )






[ SBSigSuite, modified ] = update_sbobj_fields( savedUD );
if modified
throwWarning = 1;
end 
else 
SBSigSuite = [  ];
throwWarning = 0;
end 
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp2Rzp84.p.
% Please follow local copyright laws when handling this file.

