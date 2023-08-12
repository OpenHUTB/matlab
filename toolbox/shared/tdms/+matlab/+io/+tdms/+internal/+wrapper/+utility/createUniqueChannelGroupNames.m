function [ channelGroupNames ] = createUniqueChannelGroupNames( count, existingChannelGroupNames )



R36
count( 1, 1 )double
existingChannelGroupNames( 1, : )string = string.empty
end 
channelGroupNames = strings( 1, count );
counter( 0 );
for k = 1:count
name = "ChannelGroup" + counter(  );
while any( existingChannelGroupNames == name )
name = "ChannelGroup" + counter(  );
end 
channelGroupNames( k ) = name;
end 
end 


function count = counter( initialize )
persistent currentCount;
if nargin == 1
currentCount = initialize;
else 
currentCount = currentCount + 1;
end 
count = currentCount;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfbXjsR.p.
% Please follow local copyright laws when handling this file.

