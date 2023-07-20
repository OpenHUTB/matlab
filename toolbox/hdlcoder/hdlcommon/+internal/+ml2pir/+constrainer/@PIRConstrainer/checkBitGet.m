function checkBitGet(this,callee,node)




    inputArg=node.Right;
    selectArg=inputArg.Next;


    inputType=this.getType(inputArg);

    if~(inputType.isFi||inputType.isInt)
        unsupportedType=inputType.getMLName();
        this.addMessage(inputArg,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:BitOpUnsupportedDataType',...
        callee,...
        unsupportedType);
    end

    if~inputType.isScalar&&~this.isConst(selectArg)


        this.addMessage(inputArg,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:BitgetUnsupportedInputDim');
    end
end
