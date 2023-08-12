function [ UD ] = trimDataPoints( UD )






if isfield( UD, 'current' )

oldIdx = UD.current.channel;
uiOpen = true;
else 

uiOpen = false;
UD.numChannels = length( UD.channels );
UD.current.dataSetIdx = UD.dataSetIdx;
end 


UD.current.channel = 0;


UD = remove_all_unneeded_points( UD );

if uiOpen

UD.current.channel = oldIdx;
else 
UD = rmfield( UD, { 'current', 'numChannels' } );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpLLZp6o.p.
% Please follow local copyright laws when handling this file.

