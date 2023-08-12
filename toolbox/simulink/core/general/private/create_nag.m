function oNags = create_nag( iComp, iNagType, iMsgType, iMsgs, iIDs, iSrc )


















if ishandle( iSrc )
sourceName = get_param( iSrc, 'Name' );
sourceFullName = getfullname( iSrc );
else 
sourceName = iSrc;
sourceFullName = iSrc;
end 

nag = {  };
nag.component = iComp;
nag.type = iNagType;
nag.msg.type = iMsgType;
nag.sourceName = sourceName;
nag.sourceFullName = sourceFullName;

if iscell( iMsgs ), 
nag = repmat( nag, size( iMsgs ) );
n = length( nag( : ) );
for i = 1:n, 
nag( i ).msg.details = iMsgs{ i };
nag( i ).msg.summary = iMsgs{ i };
if isempty( iIDs{ i } )
iIDs{ i } = 'SL_SERVICES:utils:UNDEFINED_ID';
end 
nag( i ).msg.identifier = iIDs{ i };
end 
else 
nag.msg.details = iMsgs;
nag.msg.summary = iMsgs;
if isempty( iIDs )
iIDs = 'SL_SERVICES:utils:UNDEFINED_ID';
end 
nag.msg.identifier = iIDs;
end 
oNags = nag;





% Decoded using De-pcode utility v1.2 from file /tmp/tmpmNvuwx.p.
% Please follow local copyright laws when handling this file.

