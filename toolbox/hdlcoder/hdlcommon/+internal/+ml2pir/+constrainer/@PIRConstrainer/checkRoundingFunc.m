function checkRoundingFunc(this,callee,node)




    arg=node.Right;
    type=this.getType(arg);


    if type.isHalf()

        this.addMessage(arg,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedOperationWithHalfTypes',...
        callee);
    end
end
