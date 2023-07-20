function a=addToLoAndAdjust(a,b)%#codegen




    coder.allowpcode('plain');


    alo=imag(a);
    ahi=real(a);


    for j=1:numel(b)
        if b(j)~=0
            alo(j)=alo(j)+b(j);
            tmp=ahi(j);
            ahi(j)=ahi(j)+alo(j);
            alo(j)=alo(j)-(ahi(j)-tmp);
        end

        if isnan(alo(j))
            alo(j)=0.0;
        end

        a(j)=complex(ahi(j),alo(j));
    end
