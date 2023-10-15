function parentContainer = getParentContainer( childElement, parentStaticMetaClassName )

arguments
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
