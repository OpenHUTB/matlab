function varargout=customLayerPredict(layer,isInputFormatted,inputDlarrayFormat,states,...
    shouldPreserveFunctionInterface,varargin)













%#codegen



    coder.inline('always');
    coder.allowpcode('plain');

    inC=cell(1,layer.NumInputs);

    coder.internal.prefer_const(inputDlarrayFormat,isInputFormatted,shouldPreserveFunctionInterface);


    if coder.const(isInputFormatted)
        for inIdx=1:layer.NumInputs
            inC{inIdx}=dlarray(varargin{inIdx},inputDlarrayFormat{inIdx});
        end
    else
        for inIdx=1:layer.NumInputs
            inC{inIdx}=dlarray(varargin{inIdx});
        end
    end



    out=cell(1,nargout);

    if coder.const(shouldPreserveFunctionInterface)



        if coder.const(isempty(states))
            [out{:}]=coder.internal.callPreservePrototype(@predict,layer,inC{:});
        else
            [out{:}]=coder.internal.callPreservePrototype(@predict,layer,inC{:},states{:});
        end
    else

        if coder.const(isempty(states))
            [out{:}]=predict(layer,inC{:});
        else
            [out{:}]=predict(layer,inC{:},states{:});
        end
    end


    for outIdx=1:nargout
        if coder.const(isdlarray(out{outIdx}))
            varargout{outIdx}=extractdata(out{outIdx});
        else
            varargout{outIdx}=out{outIdx};
        end
    end

end