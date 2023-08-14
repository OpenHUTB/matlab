
function retval=formatCell(this,val,isUsedInEval)
    retval=[];
    for ii=1:numel(val)
        valstr=formatVal(this,val{ii},isUsedInEval);
        if isUsedInEval
            retval=sprintf('%s ''%s''',retval,valstr);
        else
            retval=sprintf('%s %s',retval,valstr);
        end
    end
    retval=['{',retval,'}'];
end