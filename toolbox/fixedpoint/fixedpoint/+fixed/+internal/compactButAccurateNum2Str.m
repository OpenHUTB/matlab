function decimalNumberStr=compactButAccurateNum2Str(origNumberInDouble)









    origNumberInDouble=double(origNumberInDouble);
    if isfinite(origNumberInDouble)
        for numDecimalDigits=15:19
            decimalNumberStr=num2str(origNumberInDouble,numDecimalDigits);
            if str2double(decimalNumberStr)==origNumberInDouble;
                break
            end
        end
    else

        decimalNumberStr=num2str(origNumberInDouble);
    end
end
