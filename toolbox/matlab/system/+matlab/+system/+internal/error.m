function error(msgID,varargin)%#codegen







    coder.allowpcode('plain');


    isInMATLABCoder=~isempty(coder.target);
    if isInMATLABCoder
        eml_invariant(false,eml_message(eml_const(msgID),varargin{:}));
    else
        m=message(msgID,varargin{:});
        me=MException(m);
        throwAsCaller(me);
    end
