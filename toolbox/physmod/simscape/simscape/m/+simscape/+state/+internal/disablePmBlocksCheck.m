function origValue=disablePmBlocksCheck(value)





    persistent pVal;
    if isempty(pVal)
        pVal=false;
    end
    origValue=pVal;
    if nargin==1
        pVal=value;
    end
end
