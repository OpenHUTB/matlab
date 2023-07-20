function outStr=printConstantValue(this,hC,value)

    if~isreal(value)
        outStr=num2str(value);
    elseif isscalar(value)
        switch class(value)
        case 'logical'
            if value
                outStr='true';
            else
                outStr='false';
            end
        case{'double','single','int8','int16','int32','int64',...
            'uint8','uint16','uint32','uint64'}
            classType=class(value);
            outStr=[classType,'(',num2str(value),')'];
        case 'embedded.fi'
            rndMethod=value.RoundingMethod;
            overflow=value.OverflowAction;
            if~ischar(overflow)
                assert(false,"Unexpected type for overflow mode");
            end
            productMode=value.ProductMode;
            sumMode=value.SumMode;
            signed='1';
            if strcmp(value.Signedness,'Unsigned')
                signed='0';
            end
            fimathStr=['''RoundingMethod''',',','''',rndMethod,'''',','...
            ,'''OverflowAction''',',','''',overflow,'''',','...
            ,'''ProductMode''',',','''',productMode,'''',','...
            ,'''SumMode''',',','''',sumMode,''''];
            fimath=this.getFiMath(fimathStr);
            numericTStr=[signed,',',num2str(value.WordLength),',',num2str(value.FractionLength)];
            numericTyp=this.getNumericType(numericTStr);
            outStr=['fi(0, ',numericTyp,',',fimath,', ''hex'', ','''',num2str(value.hex),'''',')'];
        end
    elseif isvector(value)
        outStr='[';
        for ii=1:value.length
            if ii~=value.length
                if mod(ii,6)==0
                    suffix=',...\n\t\t\t';
                else
                    suffix=',';
                end
            else
                suffix='';
            end
            outStr=[outStr,printConstantValue(this,hC,value(ii)),suffix];%#ok<AGROW>
        end
        outStr=[outStr,']'];
    else
        assert(~isempty(hC),'serilzation of pir failed. unsupported data type found');
        hN=hC.Owner;
        errMsg=message('hdlcoder:engine:pirserializenotimpl',...
        'Unsupported Data Type',hC.Name,hC.RefNum,hN.Name,hN.FullPath);
        fprintf(errMsg.getString());
        mEx=MException(errMsg);
        throw(mEx);
    end
end
