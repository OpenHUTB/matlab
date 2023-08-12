function slprofile_unhilite_system( varargin )













if nargin == 1 && ischar( varargin{ 1 } )
sysStr = varargin{ 1 };
else 
DAStudio.error( 'Simulink:tools:slprof_unhilite_usage' );
end 





slashes = findstr( '/', sysStr );




slashesLen = length( slashes );
rmSlashes = [  ];

i = 1;
while i < slashesLen
if slashes( i ) == slashes( i + 1 ) - 1
rmSlashes( end  + 1:end  + 2 ) = [ i, i + 1 ];
i = i + 2;
else 
i = i + 1;
end 
end 

slashes( rmSlashes ) = [  ];

if ~isempty( slashes )
model = sysStr( 1:slashes( 1 ) - 1 );
else 
model = sysStr;
end 




if ~bdIsLoaded( model )
load_system( model );
end 







objs = find_system( model, 'LookUnderMasks', 'all', 'FollowLinks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'FindAll', 'on', 'HiliteAncestors', 'default' );
for i = 1:length( objs )
if strcmp( get_param( get_param( objs( i ), 'Parent' ), 'Open' ), 'on' )
hilite_system( objs( i ), 'none' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnrh62B.p.
% Please follow local copyright laws when handling this file.

