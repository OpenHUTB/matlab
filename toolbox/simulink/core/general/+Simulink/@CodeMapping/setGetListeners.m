function out = setGetListeners( listeners )




persistent mappingListeners;
if isempty( mappingListeners )
mappingListeners = { [  ], [  ], {  }, [  ] };
end 
if ( nargin )
mappingListeners = listeners;
end 
out = mappingListeners;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp5MI6_s.p.
% Please follow local copyright laws when handling this file.

