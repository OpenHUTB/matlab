function out=compare(varargin)











    if strcmp(mls.internal.feature('slcomparison4'),'off')
        invoker=@slxmlcomp.internal.compare;
    else
        invoker=@sldiff.compare;
    end

    if nargout==0
        invoker(varargin{:});
    else
        out=invoker(varargin{:});
    end
end
