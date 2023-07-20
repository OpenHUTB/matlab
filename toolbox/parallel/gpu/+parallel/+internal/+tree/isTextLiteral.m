function isLiteral=isTextLiteral(node)





















    k=kind(node);

    isLiteral=strcmp(k,'CHARVECTOR')...
    ||strcmp(k,'STRING')...
    ||(strcmp(k,'FIELD')&&strcmp(kind(Parent(node)),'NAMEVALUE'));
end
