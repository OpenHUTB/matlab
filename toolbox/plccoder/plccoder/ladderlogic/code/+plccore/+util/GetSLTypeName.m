function ret=GetSLTypeName(type)




    import plccore.visitor.SLTypeVisitor;
    sltv=SLTypeVisitor;
    ret=type.accept(sltv,[]);
end
