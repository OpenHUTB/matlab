function[size,bp,signed]=hdlwordsize(sltype)














    if ischar(sltype)
        [size,bp,signed]=hdlwordsizefromslstring(sltype);
    else
        error(message('HDLShared:directemit:unknowndatatypeclass',class(sltype)));
    end


    function[size,bp,signed]=hdlwordsizefromslstring(sltype)


        switch sltype
        case 'boolean'
            size=1;
            bp=0;
            signed=0;
        case 'double'
            size=0;
            bp=0;
            signed=1;
        case 'int8'
            size=8;
            bp=0;
            signed=1;
        case 'uint8'
            size=8;
            bp=0;
            signed=0;
        case 'int16'
            size=16;
            bp=0;
            signed=1;
        case 'uint16'
            size=16;
            bp=0;
            signed=0;
        case 'int32'
            size=32;
            bp=0;
            signed=1;
        case 'uint32'
            size=32;
            bp=0;
            signed=0;
        case 'single'
            size=0;
            bp=0;
            signed=1;
        case 'half'
            size=0;
            bp=0;
            signed=1;
        case 'fixdt(''float16'')'
            size=0;
            bp=0;
            signed=1;
        case 'str'
            size=8;
            bp=0;
            signed=0;
        case ''
            error(message('HDLShared:directemit:nodatatype'));
        otherwise
            [bIsNumericType,numType]=fixed.internal.type.isNameOfNumericType(sltype);
            if bIsNumericType&&isfixed(numType)
                if numType.isscalingslopebias
                    error(message('HDLShared:directemit:unsupportedslopebias',sltype));
                end
                size=numType.WordLength;
                bp=numType.FractionLength;
                signed=double(numType.Signed);
            elseif isSLEnumType(sltype)
                size=32;
                bp=0;
                signed=1;
            else
                error(message('HDLShared:directemit:unknowndatatype',sltype));
            end
        end


