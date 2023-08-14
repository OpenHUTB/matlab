function ret=GetL5XTypeName(type)


    import plccore.visitor.L5XTypeVisitor;
    l5x_tv=L5XTypeVisitor;
    ret=type.accept(l5x_tv,[]);
end
