%#codegen



function[Sign,Exponent,Mantissa]=cf2cf(cfType,inSign,inExponent,inMantissa,inType)



    coder.allowpcode('plain');

    Sign=inSign;

    if(cfType==inType)

        Exponent=inExponent;
        Mantissa=inMantissa;
    elseif(inExponent==inType.Exponent_Inf_or_NaN)

        Exponent=cfType.Exponent_Inf_or_NaN;

        if(inType.MantissaLength<=cfType.MantissaLength)
            Mantissa=fi(inMantissa,0,cfType.MantissaLength,0);
        else
            Mantissa=bitsliceget(inMantissa,cfType.MantissaLength,1);
            if(inMantissa~=0)
                Mantissa=bitset(Mantissa,cfType.MantissaLength,1);
            end
        end
    elseif(inExponent==0)&&(inMantissa==0)

        Exponent=fi(0,0,cfType.ExponentLength,0);
        Mantissa=fi(0,0,cfType.MantissaLength,0);
    else
        [ExpCorrected_x,MantAppended_x]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(inType,inExponent,inMantissa);

        e=int32(storedInteger(ExpCorrected_x))-inType.ExponentBias+cfType.ExponentBias;


        pos=coder.customfloat.helpers.findFirst1(MantAppended_x);
        shift_length=uint8(MantAppended_x.WordLength)-pos;
        e(:)=e-int32(shift_length);
        if(shift_length>=MantAppended_x.WordLength)
            MantAppended_x(:)=0;
        else
            MantAppended_x=bitsll(MantAppended_x,shift_length);
        end

        InfExponent=bitsll(int32(1),cfType.ExponentLength)-1;

        if(e>=InfExponent)

            Exponent=fi(InfExponent,0,cfType.ExponentLength,0);
            Mantissa=fi(0,0,cfType.MantissaLength,0);
        elseif(e>-(cfType.MantissaLength+2))



            if(inType.MantissaLength<=cfType.MantissaLength)
                MantExtended_x=bitconcat(MantAppended_x,fi(0,0,cfType.MantissaLength...
                -inType.MantissaLength+1,0));
            else
                MantExtended_x=MantAppended_x;
            end

            sticky=false;

            if(e>0)
                Exponent=fi(e,0,cfType.ExponentLength,0);
            else

                shift_length1=1-e;

                if(shift_length1>0)
                    if(shift_length>=MantExtended_x.WordLength)
                        sticky=true;
                    else
                        sticky=(bitsll(MantExtended_x,MantExtended_x.WordLength...
                        -shift_length1)~=0);
                    end
                end

                MantExtended_x(:)=bitsrl(MantExtended_x,shift_length1);
                Exponent=fi(0,0,cfType.ExponentLength,0);
            end

            if(inType.MantissaLength>cfType.MantissaLength+1)
                sticky=(sticky||(bitsll(MantExtended_x,MantExtended_x.WordLength...
                -(inType.MantissaLength-cfType.MantissaLength-1))~=0));
            end

            [Exponent,Mantissa]=coder.customfloat.helpers.rounding(Exponent,bitsliceget(MantExtended_x,...
            MantExtended_x.WordLength-1,MantExtended_x.WordLength-cfType.MantissaLength-1),sticky);
        else

            Exponent=fi(0,0,cfType.ExponentLength,0);
            Mantissa=fi(0,0,cfType.MantissaLength,0);
        end
    end

end


