function checkBitRotate(this,callee,node)




    rotateArg=node.Right.Next;

    isRotateConst=this.isConst(rotateArg);


    if~isRotateConst
        this.addMessage(rotateArg,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:BitrotateUnsupportedRotateType',...
        callee);
    end
end


