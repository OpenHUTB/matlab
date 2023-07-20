function checkHalfDoubleConversions(this,callee,node)






    inType=this.getType(node.Right);
    outType=this.getType(node);



    isDouble2Half=inType.isDouble&&outType.isHalf();
    isHalf2Double=inType.isHalf&&outType.isDouble();
    if isDouble2Half||isHalf2Double
        unsupportedInType=inType.getMLName();

        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedFunctionCallWithType',...
        callee,...
        unsupportedInType);
    end
end
