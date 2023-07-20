function tf=isaSupportedVoidPtrArg(arg,conceptualIOType)





    tf=false;

    if isa(arg,'coder.parser.Argument')
        tf=(isequal(arg.qualifier,coder.parser.Qualifier.Const)&&strcmpi(conceptualIOType,'RTW_IO_INPUT'))||...
        (isequal(arg.qualifier,coder.parser.Qualifier.None)&&strcmpi(conceptualIOType,'RTW_IO_OUTPUT'));
        tf=tf&&...
        isequal(arg.passBy,coder.parser.PassByEnum.Pointer)&&...
        strcmpi(arg.dataTypeString,'void');
    end

end
