function popups = maskpopups( block, newPopups )

















if nargin > 1, 
LocalSetMaskPopups( block, newPopups );
else 
popups = LocalGetMaskPopups( block );
end 



function LocalSetMaskPopups( block, popups )




maskStyles = get_param( block, 'MaskStyles' );
pops = strncmp( maskStyles, 'popup', 5 );

for i = 1:length( maskStyles ), 
if pops( i ), 
style = popups{ i };
style( 2, : ) = { '|' };
style = [ style{ : } ];
style( end  ) = '';
maskStyles{ i } = [ 'popup(', style, ')' ];
end 
end 

set_param( block, 'MaskStyles', maskStyles );



function popups = LocalGetMaskPopups( block )





maskStyles = get_param( block, 'MaskStyles' );
pops = strncmp( maskStyles, 'popup', 5 );

popups = cell( size( maskStyles ) );





for i = 1:length( maskStyles ), 
if pops( i ), 
popStr = maskStyles{ i };
lParen = find( popStr == '(' );
rParen = find( popStr == ')' );
popStr( [ 1:lParen( 1 ), rParen( end  ):end  ] ) = '';
popups{ i } = popup( popStr );
end 
end 



function pops = popup( popupStr )









popupStr = [ '{''', strrep( popupStr, '|', ''',''' ), '''}' ];
pops = eval( popupStr );



% Decoded using De-pcode utility v1.2 from file /tmp/tmpG5UfcK.p.
% Please follow local copyright laws when handling this file.

