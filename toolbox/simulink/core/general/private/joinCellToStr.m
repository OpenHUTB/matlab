function jointStr = joinCellToStr( inpCell, joinExpr )





jointStr = '';

if isempty( inpCell )
return ;
end 

if ischar( inpCell )
jointStr = inpCell;
elseif iscell( inpCell )
jointStr = char( inpCell{ 1 } );
for idx = 2:length( inpCell )
jointStr = [ jointStr, joinExpr, char( inpCell{ idx } ) ];
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpn5j_MC.p.
% Please follow local copyright laws when handling this file.

