function checkIsEqual(this,callee,node)





    in1=node.Right;
    in2=node.Right.Next;

    inType1=this.getType(in1);
    inType2=this.getType(in2);



    if inType1.isLogical&&inType2.isFloat||inType1.isFloat&&inType2.isLogical||...
        inType1.isInt&&inType2.isFloat||inType1.isFloat&&inType2.isInt||...
        inType1.isFi&&inType2.isFloat||inType1.isFloat&&inType2.isFi

        this.addMessage(node.Left,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedOperationWithMixedTypes',...
        callee,...
        inType1.getMLName,...
        inType2.getMLName);
    end

end
