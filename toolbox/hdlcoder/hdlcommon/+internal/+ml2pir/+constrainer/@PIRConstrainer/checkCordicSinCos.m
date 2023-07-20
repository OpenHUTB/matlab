function checkCordicSinCos(this,callee,node)





    arg=node.Right;
    type=this.getType(arg);

    isFixedPoint=type.isInt||type.isFi;

    if~(isFixedPoint&&type.isSigned)
        unsupportedType=type.getMLName();

        if isFixedPoint&&~type.isSigned
            errID='hdlcommon:matlab2dataflow:UnsupportedFunctionCallWithUnsignedType';
        elseif type.isFloat
            errID='hdlcommon:matlab2dataflow:UnsupportedFunctionCallWithFloatType';
        else

            errID='hdlcommon:matlab2dataflow:UnsupportedFunctionCallWithType';
        end

        this.addMessage(arg,...
        internal.mtree.MessageType.Error,...
        errID,...
        callee,...
        unsupportedType);
    end
end


