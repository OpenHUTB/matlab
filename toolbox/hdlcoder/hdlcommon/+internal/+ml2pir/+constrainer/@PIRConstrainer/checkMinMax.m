function checkMinMax(this,callee,node)





    arg1=node.Right;
    arg1Type=this.getType(arg1);
    arg2=arg1.Next;

    if~isempty(arg2)
        arg2Type=this.getType(arg2);
    else
        arg2Type=[];
    end
    outDesc=this.getVarDesc(node);

    if isa(outDesc,'internal.mtree.analysis.NodeDescriptor')

        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:MinMaxIndexUnsupported',...
        callee);
    end
    if(arg1Type.isNumeric&&arg1Type.Complex)||...
        (~isempty(arg2Type)&&arg2Type.isNumeric&&arg2Type.Complex)

        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:MinMaxNoComplexInputs',...
        callee);
    end
end
