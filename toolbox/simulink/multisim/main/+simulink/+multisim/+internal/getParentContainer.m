function parentContainer = getParentContainer( childElement, parentStaticMetaClassName )





R36
childElement
parentStaticMetaClassName( 1, 1 )string
end 

tempContainer = childElement;
parentContainer = [  ];

while ~isempty( tempContainer )
if strcmp( parentStaticMetaClassName, tempContainer.StaticMetaClass.name )
parentContainer = tempContainer;
break ;
end 
tempContainer = tempContainer.Container;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpI6MvCu.p.
% Please follow local copyright laws when handling this file.

