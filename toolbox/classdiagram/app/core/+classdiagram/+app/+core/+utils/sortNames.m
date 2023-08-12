function sorted = sortNames( names, direction )
R36
names( 1, : )string;
direction( 1, : )char{ mustBeMember( direction, { 'ascend', 'descend' } ) } = 'ascend';
end 
namesMatrix = sortrows( [ upper( names );names ]', direction );
sorted = namesMatrix( :, 2 )';
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYIAiVj.p.
% Please follow local copyright laws when handling this file.

