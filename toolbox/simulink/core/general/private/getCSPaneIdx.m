function indices = getCSPaneIdx( tree, matchPanes )
len_tree = length( tree );
t = 1:len_tree;

indices = [  ];
lenOfAllMatches = length( matchPanes );
for i = 1:lenOfAllMatches
key = matchPanes{ i };
index = int16( sum( strcmp( tree, key ) .* t ) );

if index == 0
[ main, sub ] = strtok( key, '/' );
sub = strrep( sub, '/', '' );
index = sum( strcmp( tree, main ) .* t );

subtree = tree{ index + 1 };
len_subtree = length( subtree );
t_subtree = 1:len_subtree;
subindex = sum( strcmp( subtree, sub ) .* t_subtree ) / 100;
index = index + subindex;
end 

indices( end  + 1 ) = index;%#ok
end 

indices = sort( indices );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpH1vyyZ.p.
% Please follow local copyright laws when handling this file.

