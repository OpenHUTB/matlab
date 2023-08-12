function [ indexedItems, layout ] = getIndexedGroupItems( N, items )






















if ~isnumeric( N ) || N <= 0
DAStudio.error( 'Simulink:tools:indexedGroupItems_InvalidN' );
end 

nItems = length( items );
nStretch = 0;
for i = 1:nItems
if ischar( items{ i } )
nStretch = nStretch + 1;
end 
end 

indexedItems = cell( 1, nItems - nStretch );

i = 1;
j = 1;
l = 1;

for k = 1:nItems

item = items{ k };

if ischar( item )

switch item
case 'blank'

if i == N
j = j + 1;
i = 1;
else 
i = i + 1;
end 

case 'stretch'

if i == 1
DAStudio.error( 'Simulink:tools:indexedGroupItems_InvalidStretch' );
end 

i = indexedItems{ l - 1 }.ColSpan( 2 ) + 1;
indexedItems{ l - 1 }.ColSpan( 2 ) = i;

if i == N
j = j + 1;
i = 1;
end 

otherwise 
DAStudio.error( 'Simulink:tools:indexedGroupItems_InvalidOpt' );
end 

continue ;
end 

item.RowSpan = [ j, j ];
item.ColSpan = [ i, i ];
indexedItems{ l } = item;

if i == N
i = 1;
j = j + 1;
else 
i = i + 1;
end 

l = l + 1;

end 

layout = [ j, N ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzQ6AN6.p.
% Please follow local copyright laws when handling this file.

