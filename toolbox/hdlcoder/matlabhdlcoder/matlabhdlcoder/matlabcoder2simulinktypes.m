function tpinfo=matlabcoder2simulinktypes(coderType)




    tpinfo.iscomplex=0;

    tpinfo.numdims=length(coderType.SizeVector);
    tpinfo.dims=coderType.SizeVector;

    tpinfo.iscomplex=coderType.Complex;
    tpinfo.sltype=getCoderType2SlType(coderType);
end


function sltype=getCoderType2SlType(coderType)
    switch coderType.ClassName
    case{'double','single','int8','int16','int32','int64'...
        ,'uint8','uint16','uint32','uint64'}
        sltype=coderType.ClassName;

    case{'half'}
        sltype='fixdt(''half'')';

    case 'embedded.fi'
        wordsize=coderType.NumericType.WordLength;
        binarypoint=-coderType.NumericType.FractionLength;

        if coderType.NumericType.SignednessBool
            c='s';
        else
            c='u';
        end

        if(binarypoint>0)
            sltype=sprintf('%sfix%d_E%d',c,wordsize,binarypoint);
        elseif(binarypoint<0)
            sltype=sprintf('%sfix%d_En%d',c,wordsize,-binarypoint);
        else
            sltype=sprintf('%sfix%d',c,wordsize);
        end

    case 'logical'
        sltype='boolean';

    otherwise
        error(message('hdlcoder:matlabhdlcoder:unhandleddatatype',coderType.ClassName));
    end
end
