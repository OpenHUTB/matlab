function pv=creatematdata(this,flag)











    if nargin>1&&strcmpi(flag,'nondefault')
        props=getNonDefaultProps(this);
    else
        props=fieldnames(this);
    end

    vals=get(this,props);


    idx=cellfun(@(x)isa(x,'embedded.numerictype'),vals);
    if any(idx)
        vals=cellfun(@convertnttostring,vals,'UniformOutput',false);
    end
    pv=[props(:),vals(:)]';
    pv=pv(:)';

end

function outval=convertnttostring(inval)

    if~isa(inval,'embedded.numerictype')
        outval=inval;
    else
        outval=sprintf('numerictype(%d,%d,%d)',inval.SignednessBool,inval.WordLength,inval.FractionLength);
    end
end

