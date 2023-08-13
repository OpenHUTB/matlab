function response=fevalMatlab(functionName,args,numberOfOutputs)

    args=mls.internal.fromJSON(args);

    if~iscell(args)
        args={args};
    end

    try
        connector.ensureServiceOn;
    catch ignore
    end

    if numberOfOutputs==0
        feval(functionName,args{:});
        response='[]';
    else
        response=cell(numberOfOutputs,1);
        [response{:}]=feval(functionName,args{:});
    end

end
