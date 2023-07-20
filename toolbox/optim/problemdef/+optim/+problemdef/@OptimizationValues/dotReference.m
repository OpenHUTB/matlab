function varargout=dotReference(obj,indexOp)









    thisProperty=indexOp(1).Name;


    try
        optim.internal.problemdef.mustBeCharVectorOrString(thisProperty,'Property name');
    catch ME
        throwAsCaller(ME);
    end


    if~any(strcmp(thisProperty,properties(obj)))
        error(message('MATLAB:noSuchMethodOrField',thisProperty,class(obj)));
    end


    out=obj.Values.(thisProperty);


    if numel(indexOp)>1
        [varargout{1:nargout}]=out.(indexOp(2:end));
    else
        varargout{1}=out;
    end

end
