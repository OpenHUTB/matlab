function [ errids, errmsgs ] = getAllErrorIdsAndMsgs( e, varargin )




























[ errids, errmsgs ] = recursiveHelper( e );

concatIdsMsgs = false;
if ~isempty( varargin )
for n = 1:2:length( varargin )
option = varargin{ n };
switch option
case 'concatenateIdsAndMsgs'
concatIdsMsgs = varargin{ n + 1 };
otherwise 
error( 'MATLAB:UNDEFINED_OPTION', 'Unknown option specified' );
end 
end 
end 

if concatIdsMsgs
id = '';
msg = '';
if length( errids ) > 1
for idx = 1:length( errids )
id = [ errids{ idx }, sprintf( '\n' ), id ];%#ok
msg = [ errmsgs{ idx }, sprintf( '\n' ), msg ];%#ok
end 
errids = id;
errmsgs = msg;
elseif length( errids ) == 1
errids = errids{ 1 };
errmsgs = errmsgs{ 1 };
end 
end 

function [ ids, msgs ] = recursiveHelper( e )



msgs = {  };
ids = {  };

if isempty( e )
return ;
end 

causes = e.cause;

for n = 1:length( causes )
[ cause_ids, cause_msgs ] = recursiveHelper( causes{ n } );
ids = cat( 2, ids, cause_ids );
msgs = cat( 2, msgs, cause_msgs );
end 

if ~strcmp( e.identifier, 'MATLAB:MException:MultipleErrors' )
msgs = cat( 2, { e.message }, msgs );
ids = cat( 2, { e.identifier }, ids );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqBgZSZ.p.
% Please follow local copyright laws when handling this file.

