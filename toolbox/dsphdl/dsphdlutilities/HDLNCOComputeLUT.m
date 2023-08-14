function[fullSine,fullCos]=HDLNCOComputeLUT(quantWL,OutputWL,OutputFL,LUTCompress,OutputDataType,outType)





    delta=1/(2^(quantWL-2));

    Fsat=fimath('RoundMode','Nearest',...
    'OverflowMode','Saturate',...
    'SumMode','KeepLSB',...
    'SumWordLength',OutputWL,...
    'SumFractionLength',OutputFL,...
    'CastBeforeSum',true);

    if(~LUTCompress)||isdouble(outType)
        quarterSineDouble=sin(pi/2*(0:delta:1)');
    else

        WL_lut=quantWL-2;
        bs=ceil(WL_lut/3);
        A=2*pi*2^-(bs+2);
        B=2*pi*2^-bs*2^-(bs+2);
        Cbs=WL_lut-2*bs;
        C=2*pi*2^-(2*bs)*2^-(Cbs+2);

        index=fi((0:2^WL_lut-1)',0,WL_lut,0);
        Ak=bitshift(index,-(bs+Cbs));
        Bk=index;
        Bk.bin(:,1:bs)='0';
        Bk=bitshift(Bk,-Cbs);
        Ck=index;
        Ck.bin(:,1:2*bs)='0';
        quarterSineDouble=sin(A*double(Ak)+B*double(Bk));
        p2=cos(A*double(Ak)).*sin(C*double(Ck));
        quarterSineDouble(2^WL_lut+1)=1;

    end


    if strcmpi(OutputDataType,'Binary point scaling')&&~isdouble(outType)

        quarterSine=fi(quarterSineDouble,outType,Fsat);
        if LUTCompress


            shiftbits=floor(log2(0.75/max(p2)));
            outWL_LUT2=ceil(OutputWL/4);

            temp_p2=fi(p2*2^shiftbits,numerictype(0,outWL_LUT2,outWL_LUT2),Fsat);
            temp_p2=fi(temp_p2,outType,Fsat);
            p2_new=bitshift(temp_p2,-shiftbits);
            quarterSine(1:end-1)=quarterSine(1:end-1)+p2_new;

        end
    else
        quarterSine=quarterSineDouble;
    end

    quarterCos=quarterSine(end:-1:1);
    halfSine=[quarterSine;quarterSine(end-1:-1:1)];
    halfCos=[quarterCos;-quarterCos(end-1:-1:1)];
    fullSine=[halfSine;-halfSine(2:end-1)];
    fullCos=[halfCos;halfCos(end-1:-1:2)];
end
