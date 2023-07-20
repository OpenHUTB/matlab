function checkComplexFunc(this,callee,node)




    arg=node.Right;

    if count(arg.List)~=2
        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:FunctionCallWithUnsupportedNumArgs',...
        node.tree2str,...
        callee,...
        count(arg.List),...
        '2');
        return
    end

    type1=this.getType(arg);
    type2=this.getType(arg.Next);


    if(type1.isFloat||type2.isFloat)&&~type1.isTypeEqual(type2)
        this.addMessage(arg,...
        internal.mtree.MessageType.Error,...
        'hdlcoder:validate:RealImag2ComplexMixedType');
    end

    if~type1.isDimensionsEqual(type2)
        this.addMessage(arg,...
        internal.mtree.MessageType.Error,...
        'hdlcoder:validate:RealImag2ComplexMixedDimensions');
    end
end
