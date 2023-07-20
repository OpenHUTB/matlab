function isDecaf=decaf(setDecaf)





    persistent decafState;
    if isempty(decafState)
        decafState=false;
    end

    isDecaf=decafState;

    if nargin>0
        decafState=setDecaf;
    end

end
