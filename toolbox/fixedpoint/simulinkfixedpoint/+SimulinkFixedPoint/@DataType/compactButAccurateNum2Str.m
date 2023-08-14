
function decimalNumberStr=compactButAccurateNum2Str(origNumberInDouble)












    if isinf(origNumberInDouble)

        decimalNumberStr=num2str(origNumberInDouble);
    else
        for numDecimalDigits=15:19

            decimalNumberStr=num2str(origNumberInDouble,numDecimalDigits);

            if eval(decimalNumberStr)==origNumberInDouble

                break;
            end
        end

    end
