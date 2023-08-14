%#codegen 

function out=coderEnableLog(varargin)
    coder.allowpcode('plain');
    coder.inline('never');

    persistent pInit pEnabled
    if isempty(pInit)
        pInit=false;

        coder.varsize('pEnabled',[1,Inf]);
        pEnabled=pInit;
    end

    if 1==nargin
        buffId=varargin{1};
        currLen=numel(pEnabled);
        if buffId>currLen
            out=pInit;
        else
            out=pEnabled(buffId);
        end
    else
        buffId=varargin{1};
        enableVal=varargin{2};

        tmp=sort(buffId);
        endBuffId=tmp(end);


        currLen=numel(pEnabled);
        if endBuffId>currLen
            pEnabled=[pEnabled,repmat(pInit,1,endBuffId-currLen)];
        end

        pEnabled(buffId)=enableVal;
        out=pEnabled;
    end
end