function retval=formatMatrixVal(this,val,isUsedInEval)
    narginchk(3,3);
    if isempty(val)
        retval='[]';
    elseif ischar(val)
        retval=val;
    elseif~isscalar(val)
        dims=size(val);

        reshapedVal=reshape(val,prod(dims),1);
        retval=formatVal(this,reshapedVal,isUsedInEval);
        retval=['reshape(',retval,', [',int2str(dims),'])'];
    else
        retval=formatVal(this,val,isUsedInEval);
    end
end