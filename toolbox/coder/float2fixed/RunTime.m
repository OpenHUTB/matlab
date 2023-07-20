%#codegen 

function out=RunTime(enableVal)
    coder.allowpcode('plain');
    persistent pEnabled
    if isempty(pEnabled)
        pEnabled=true;
    end

    if nargin==0
        out=pEnabled;
        return;
    else
        pEnabled=enableVal;
        out=pEnabled;
    end
end