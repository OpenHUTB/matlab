function checkBitShift(this,callee,node)





    inputArg=node.Right;
    shiftArg=node.Right.Next;

    isShiftConst=this.isConst(shiftArg);


    inputType=this.getType(inputArg);

    if inputType.isFloat
        unsupportedType=inputType.getMLName();
        this.addMessage(shiftArg,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:BitOpUnsupportedDataType',...
        callee,...
        unsupportedType);
    end


    if~isShiftConst
        shiftType=this.getType(shiftArg);

        if strcmp(callee,'bitsrl')&&inputType.isSigned
            this.addMessage(shiftArg,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:BitsrlUnsupportedShiftType');
        end

        if shiftType.isFloat
            unsupportedType=shiftType.getMLName();
            this.addMessage(shiftArg,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:BitshiftUnsupportedShiftType',...
            callee,...
            unsupportedType);
        end
    end
end
