function decimalNumberVectorStr=compactButAccurateVector2Str(v)



    if isempty(v)
        decimalNumberVectorStr='[]';
    elseif length(v)==1
        decimalNumberVectorStr=fixed.internal.compactButAccurateNum2Str(v);
    else
        decimalNumberVectorStr=['[',fixed.internal.compactButAccurateNum2Str(v(1))];
        for i=2:length(v)
            decimalNumberVectorStr=[decimalNumberVectorStr,', ',fixed.internal.compactButAccurateNum2Str(v(i))];%#ok<AGROW>
        end
        decimalNumberVectorStr(end+1)=']';
    end
end
