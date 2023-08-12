function is_commented_out = isCommentedOut( blockH )


is_commented_out = false;

if ( isempty( blockH ) )
return ;
end 
if ( strcmp( get_param( blockH, 'Commented' ), 'on' ) )
is_commented_out = true;
else 

parent = get_param( blockH, 'Parent' );
while ( ~strcmp( get_param( parent, 'Type' ), 'block_diagram' ) )

if ( strcmp( get_param( parent, 'Commented' ), 'on' ) )
is_commented_out = true;
break ;
else 
parent = get_param( parent, 'Parent' );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpuUaFMi.p.
% Please follow local copyright laws when handling this file.

