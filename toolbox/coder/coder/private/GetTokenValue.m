function value=GetTokenValue(buildInfo,key,varargin)




    if nargin==3
        field=varargin{1};
    else
        field='Tokens';
    end
    toks=get(buildInfo.(field),'Key');
    tokVals=get(buildInfo.(field),'Value');
    if isempty(toks)
        toks={};
        tokVals={};
    end
    if~iscell(toks)
        toks={toks};
        tokVals={tokVals};
    end
    tokIdx=find(strcmp(toks,key)==1);
    if isempty(tokIdx)
        value=[];
    else
        value=tokVals{tokIdx};
    end
