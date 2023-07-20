function y=eml_al_nr_reciprocal(u,numIters)



%#codegen



    coder.allowpcode('plain');

    if~isempty(coder.target)
        eml_prefer_const(u);
        eml_prefer_const(numIters);
    end


    sz=size(u);
    outLen=numel(u);




    if isa(u,'double')
        y=coder.nullcopy(zeros(sz));
        uInput=double(0);
    end


    if isa(u,'single')
        y=coder.nullcopy(single(zeros(sz)));
        uInput=single(0);
    end


    if~isfloat(u)
        [uNT,yNT,yFm]=locaGetOutputFixptAttrib(u);

        if(yNT.FractionLength==0)
            switch(yNT.WordLength)
            case 8
                if yNT.SignednessBool
                    y=int8(0);
                else
                    y=uint8(0);
                end
            case 16
                if yNT.SignednessBool
                    y=int16(0);
                else
                    y=uint16(0);
                end
            case 32
                if yNT.SignednessBool
                    y=int32(0);
                else
                    y=uint32(0);
                end
            case 64
                if yNT.SignednessBool
                    y=int64(0);
                else
                    y=uint64(0);
                end
            otherwise
                y=coder.nullcopy(fi(zeros(sz),yNT));
            end
        else
            y=coder.nullcopy(fi(zeros(sz),yNT));
        end

        uInput=fi(u,uNT,yFm);
    end


    for idx=1:outLen
        u_idx=u(idx);

        if(u_idx<cast(0,'like',u_idx))
            uInput(:)=-u_idx;
            u_sign_change=true;
        else
            uInput(:)=u_idx;
            u_sign_change=false;
        end


        if isfloat(uInput)

            b=reciprocal_nr_kernel(uInput,numIters);
        else

            b=reciprocal_nr_kernel_fi(uInput,numIters);
        end

        if u_sign_change
            y(idx)=-b;
        else
            y(idx)=b;
        end

    end

end




function b=reciprocal_nr_kernel(a,n)

%#codegen

    if~isempty(coder.target)
        eml_prefer_const(n);
    end

    if a==cast(0,'like',a)
        b=cast(1/a,'like',a);
        return;
    elseif abs(a)==cast(inf,'like',a)
        b=cast(1/a,'like',a);
        return;
    end

    f=abs(a);

    [t,e]=log2(f);

    b=cast(1,'like',a);

    for i=1:n
        b(:)=b*(2-b*t);
    end

    b=b*pow2(-e);

end




function y=reciprocal_nr_kernel_fi(u,n)
%# codegen 

    [a,p]=fxpFREXP(u);

    isInputZero=isequal(u,cast(0,'like',u));




    if isInputZero&&(p>cast(0,'like',p))
        p=cast(0,'like',p);
    end

    localFm=u.fimath;

    wl=u.WordLength;
    fl=u.FractionLength;

    b=fi(1,0,wl,wl-2,localFm);

    for i=1:n
        b(:)=b*(cast(2,'like',b)-b*a);
    end

    if u.Signed
        extraIntLength=1;
    else
        extraIntLength=0;
    end

    output_fl=(wl-fl-1-extraIntLength);

    if b.WordLength>1
        if p>=0
            keep_extra_bit=1-fl-extraIntLength;






            if((keep_extra_bit>0)&&~isInputZero)
                y=reinterpretcast(bitsra(b,p-1),numerictype(false,wl,wl-1));
                y=fi(y,numerictype(u.Signed,wl,output_fl));
            else
                y=fi(bitsra(b,p),numerictype(u.Signed,wl,output_fl));
            end
        else
            b=reinterpretcast(b,numerictype(false,wl,0));
            y=reinterpretcast(bitsra(b,fl-1+p),numerictype(false,wl,wl-fl-1));
            y=fi(y,numerictype(u.Signed,wl,output_fl));
        end
    else
        y=b;
        y=fi(y,numerictype(u.Signed,wl,output_fl));
    end

end




function[y,r]=fxpFREXP(u)









%# codegen 

    if~isfi(u)
        error('fi:internal:mustbefi','Input must be fi.\n');
    end

    WL=u.WordLength;

    if WL>128
        error('fi:internal:mustlessthan128','Word Length of fi object cannot exceed 128\n');
    end

    if WL==1
        v=reinterpretcast(fi(u,false,2,u.FractionLength),numerictype(false,2,0));
    else
        v=reinterpretcast(u,numerictype(false,WL,0));
    end

    if WL>64



        r=bitsll(int16(v>fi(2^64-1,false,WL,0,'hex','ffffffffffffffff')),6);
        v=bitsra(v,r);

        sh=bitsll(int16(v>(2^32-1)),5);
        v=bitsra(v,sh);
        r=bitor(r,sh);

        sh=bitsll(int16(v>(2^16-1)),4);
        v=bitsra(v,sh);
        r=bitor(r,sh);

        sh=bitsll(int16(v>(2^8-1)),3);
        v=bitsra(v,sh);
        r=bitor(r,sh);

        sh=bitsll(int16(v>(2^4-1)),2);
        v=bitsra(v,sh);
        r=bitor(r,sh);

        sh=bitsll(int16(v>(2^2-1)),1);
        v=bitsra(v,sh);
        r=bitor(r,sh);

    elseif WL>32

        r=bitsll(int16(v>(2^32-1)),5);
        v=bitsra(v,r);

        sh=bitsll(int16(v>(2^16-1)),4);
        v=bitsra(v,sh);
        r=bitor(r,sh);

        sh=bitsll(int16(v>(2^8-1)),3);
        v=bitsra(v,sh);
        r=bitor(r,sh);

        sh=bitsll(int16(v>(2^4-1)),2);
        v=bitsra(v,sh);
        r=bitor(r,sh);

        sh=bitsll(int16(v>(2^2-1)),1);
        v=bitsra(v,sh);
        r=bitor(r,sh);

    elseif WL>16

        r=bitsll(int16(v>(2^16-1)),4);
        v=bitsra(v,r);

        sh=bitsll(int16(v>(2^8-1)),3);
        v=bitsra(v,sh);
        r=bitor(r,sh);

        sh=bitsll(int16(v>(2^4-1)),2);
        v=bitsra(v,sh);
        r=bitor(r,sh);

        sh=bitsll(int16(v>(2^2-1)),1);
        v=bitsra(v,sh);
        r=bitor(r,sh);

    elseif WL>8

        r=bitsll(int16(v>(2^8-1)),3);
        v=bitsra(v,r);

        sh=bitsll(int16(v>(2^4-1)),2);
        v=bitsra(v,sh);
        r=bitor(r,sh);

        sh=bitsll(int16(v>(2^2-1)),1);
        v=bitsra(v,sh);
        r=bitor(r,sh);

    else

        r=bitsll(int16(v>(2^4-1)),2);
        v=bitsra(v,r);

        sh=bitsll(int16(v>(2^2-1)),1);
        v=bitsra(v,sh);
        r=bitor(r,sh);
    end

    r=bitor(r,bitsra(int16(v),1))+1;

    r=r-cast(u.FractionLength,'like',r);

    if u.WordLength>1
        y=reinterpretcast(bitsll(u,WL-u.FractionLength-r),numerictype(false,WL,WL));
    else
        y=reinterpretcast(u,numerictype(false,WL,WL));
    end

end





function[uNT,yNT,yFm]=locaGetOutputFixptAttrib(u)

    if~isempty(coder.target)
        eml_prefer_const(u);
    end

    if isinteger(u)
        switch class(u)
        case 'int8'
            uWL=8;isUnsUInput=0;
        case 'uint8'
            uWL=8;isUnsUInput=1;
        case 'int16'
            uWL=16;isUnsUInput=0;
        case 'uint16'
            uWL=16;isUnsUInput=1;
        case 'int32'
            uWL=32;isUnsUInput=0;
        case 'uint32'
            uWL=32;isUnsUInput=1;
        case 'int64'
            uWL=64;isUnsUInput=0;
        otherwise
            uWL=64;isUnsUInput=1;
        end
        uFL=0;
    else

        isUnsUInput=double((~isfloat(u))&&(~issigned(u)));
        uNT=eml_al_numerictype(u);
        uWL=uNT.WordLength;
        uFL=uNT.FractionLength;
    end

    if isUnsUInput
        extraIntLength=1;
    else
        extraIntLength=2;
    end

    if isfi(u)&&isscaleddouble(u)
        uNT=numerictype(...
        'Signed',~isUnsUInput,...
        'WordLength',uWL,...
        'FractionLength',uFL,...
        'DataTypeMode','Scaled double: binary point scaling');
        yNT=numerictype(...
        'Signed',~isUnsUInput,...
        'WordLength',uWL,...
        'FractionLength',uWL-uFL-extraIntLength,...
        'DataTypeMode','Scaled double: binary point scaling');
    else
        uNT=numerictype(~isUnsUInput,uWL,uFL);
        yNT=numerictype(~isUnsUInput,uWL,uWL-uFL-extraIntLength);
    end

    yFm=fimath(...
    'ProductMode','SpecifyPrecision',...
    'ProductWordLength',uWL,...
    'ProductFractionLength',uWL-2,...
    'SumMode','SpecifyPrecision',...
    'SumWordLength',uWL,...
    'SumFractionLength',uWL-2,...
    'RoundMode','Floor',...
    'OverflowMode','Saturate'...
    );

end


