

function decimalNumberStr=compactButAccurateNum2Str(origNumberInDouble)



    if~isscalar(origNumberInDouble)
        decimalNumberStr='';
        return;
    end








    if isempty(origNumberInDouble)
        decimalNumberStr='';
    else
        for numDecimalDigits=15:19
            decimalNumberStr=num2str(origNumberInDouble,numDecimalDigits);
            if eval(decimalNumberStr)==origNumberInDouble
                break
            end
        end
    end
end
