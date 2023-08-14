function checkMathTrigOps(this,callee,node)





    if strcmp(kind(node),'CALL')

        arg1=node.Right;
        arg2=node.Right.Next;
    else

        arg1=node.Left;
        arg2=node.Right;
    end

    type1=this.getType(arg1);
    isConst1=this.isConst(arg1);


    if~isempty(arg2)
        type2=this.getType(arg2);
        isConst2=this.isConst(arg2);
    else
        type2=internal.mtree.type.UnknownType;
        isConst2=true;
    end


    if type1.isComplex||type2.isComplex
        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedFunctionCallWithComplexType',...
        callee,...
        type1.getMLName());
    end


    isValidSquareArgs=~isempty(arg2)&&isConst2&&all(this.getVarDesc(arg2).constVal{1}==2,'all')&&...
    (type2.isScalar||isequal(type1.Dimensions,type2.Dimensions));

    if isValidSquareArgs&&(any(strcmp(node.kind,{'EXP','DOTEXP'}))||...
        strcmp(callee,'power'))

    elseif(~isConst1&&~type1.isFloat)||(~isConst2&&~type2.isFloat)


        if~isConst1
            unsupportedType=type1.getMLName();
        else

            unsupportedType=type2.getMLName();
        end

        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedFunctionCallWithFixedType',...
        callee,...
        unsupportedType);
    end


    switch node.kind
    case{'EXP','DOTEXP'}


        if this.inNFPMode&&this.getType(node).isDouble&&~isValidSquareArgs
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:UnsupportedOperationWithDoubleTypes',...
            callee);
        elseif this.inNFPMode&&this.getType(node).isHalf&&~isValidSquareArgs
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:UnsupportedOperationWithHalfTypes',...
            callee);
        end
    case 'CALL'
        unsupported_double=...
        {'sin','cos','tan','asin','acos','atan','atan2',...
        'sinh','cosh','tanh','asinh','acosh','atanh',...
        'exp','log10','hypot','rem','mod'};
        unsupported_half={'sin','cos','tan','asin','acos','atan','atan2',...
        'sinh','cosh','tanh','asinh','acosh','atanh',...
        'exp','log','log10','hypot','rem','mod'};
        partialSupport='power';
        if this.inNFPMode&&this.getType(node).isDouble&&...
            (any(strcmp(callee,unsupported_double))||(strcmp(callee,partialSupport)&&~isValidSquareArgs))
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:UnsupportedOperationWithDoubleTypes',...
            callee);
        elseif this.inNFPMode&&this.getType(node).isHalf&&...
            (any(strcmp(callee,unsupported_half))||(strcmp(callee,partialSupport)&&~isValidSquareArgs))
            this.addMessage(node,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:UnsupportedOperationWithHalfTypes',...
            callee);
        end
    end


    if strcmp(node.kind,'EXP')&&~(type1.isScalar&&type2.isScalar)
        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedOperationWithNonscalarTypes',...
        callee);
    elseif~isempty(arg2)

        this.checkBinaryInputTypes(node);
    end
end
