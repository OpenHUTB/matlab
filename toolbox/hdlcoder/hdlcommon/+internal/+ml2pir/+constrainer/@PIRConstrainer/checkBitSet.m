function checkBitSet(this,node)




    bitToSet=node.Right.Next;

    if~this.isConst(bitToSet)
        this.addMessage(bitToSet,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:BitsetNonConstSel');
    end

end
