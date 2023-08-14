function initialValStr=convertRAMIV2Str(initialVal,addrType)




    if isnumeric(initialVal)

        if all(initialVal==0,'all')

            initialValStr='0';
        elseif all(initialVal==initialVal(1))


            initialValStr=mat2strExact(initialVal(1));
        else
            if iscolumn(initialVal)
                initialVal=initialVal.';
            end

            zeroPad=zeros(size(initialVal,1),2^addrType.WordLength-size(initialVal,ndims(initialVal)));
            zeroPaddedInitialVal=[initialVal,zeroPad];

            initialValStr=mat2strExact(zeroPaddedInitialVal);
        end
    else

        initialValStr=initialVal;
    end
end

function valStr=mat2strExact(value)
    valStr=mat2str(value,'class');


    if~(all((eval(valStr)==value),'all'))
        for numDigits=15:19
            valStr=mat2str(value,'class',numDigits);
            if(all((eval(valStr)==value),'all'))
                break;
            end
        end
    end
end
