function c=two_prod(a,b)%#codegen




    coder.allowpcode('plain');


    da=matlab.internal.coder.doubledouble.split(a);
    shi=a*b;

    da_hi=real(da);
    da_lo=imag(da);

    slo=zeros(size(a));
    db=complex(zeros(size(a)));
    db_hi=zeros(size(a));
    db_lo=zeros(size(a));
    for j=1:numel(a)
        if((b==86400000.0)||(b==1000.0)||(b==1e6)||(b==60000.0)||(b==3600000.0))
            slo(j)=da_lo(j)*b+(da_hi(j)*b-shi(j));
        else
            db(j)=matlab.internal.coder.doubledouble.split(b);
            db_hi(j)=real(db(j));
            db_lo(j)=imag(db(j));
            slo(j)=da_lo(j)*db_lo(j)+(da_hi(j)*db_lo(j)+(da_lo(j)*db_hi(j)+(da_hi(j)*db_hi(j)-shi(j))));
        end
    end
    slo(isnan(slo))=0.0;
    c=complex(shi,slo);

end
