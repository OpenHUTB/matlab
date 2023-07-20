function assertType(arg,type)


    if~isa(arg,type)
        error(['Expected input is not of type ''',type,'''.']);
    end
    if isobject(arg)&&~arg.isvalid
        error(['Input argument of type ''',type,''' is not valid.']);
    end
    if~isobject(arg)&&isempty(arg)
        error(['Input argument of type ''',type,''' is empty.']);
    end
