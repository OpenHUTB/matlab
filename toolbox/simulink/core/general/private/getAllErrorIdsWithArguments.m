function [ errids, errmsgs ] = getAllErrorIdsWithArguments( e, varargin )


















[ errids, errmsgs ] = recursiveHelper( e );


function [ ids, args ] = recursiveHelper( e )



args = {  };
ids = {  };

if isempty( e )
return ;
end 

causes = e.cause;

for n = 1:length( causes )
[ cause_ids, cause_args ] = recursiveHelper( causes{ n } );
ids = cat( 2, ids, cause_ids );
args = cat( 2, args, cause_args );
end 

if ~strcmp( e.identifier, 'MATLAB:MException:MultipleErrors' )
args = cat( 2, { e.arguments }, args );
ids = cat( 2, { e.identifier }, ids );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFh_fuG.p.
% Please follow local copyright laws when handling this file.

