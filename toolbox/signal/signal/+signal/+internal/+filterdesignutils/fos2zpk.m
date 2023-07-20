function[z,p,k]=fos2zpk(b,a)












%#codegen

    coder.inline('never');
    coder.allowpcode('plain');

    narginchk(2,2);

    k=b(1)/a(1);
    bn=b/b(1);
    DT=class(b);

    if isequal(bn,cast([1,0,-2,0,1],DT))
        z=cast([1;-1;1;-1],DT);
    elseif isequal(bn,cast([1,-2,1,0,0],DT))
        z=cast([1;0;1;0],DT);
    else
        z=fos2roots(bn);
    end
    p=fos2roots(a/a(1));


    function rt=fos2roots(B)

        DT=class(B);
        cast0=cast(0,DT);
        cast2=cast(2,DT);
        cast3=cast(3,DT);
        cast4=cast(4,DT);


        aa=B(2);bb=B(3);cc=B(4);dd=B(5);





        aa2=aa*aa;
        qq=cast(-3/8,DT)*aa2+bb;
        rr=aa2*aa/cast(8,DT)-aa*bb/cast2+cc;
        ss=cast(-3/256,DT)*aa2*aa2+aa2*bb/cast(16,DT)-aa*cc/cast4+dd;





        if isa(B,'single')
            thresRR=cast(2e-4,'single');
        else
            thresRR=1e-11;
        end
        if abs(rr)<thresRR/10

            sqq0=sqrt(complex(qq*qq/cast4-ss));
            sqq1=sqrt(complex(-qq/cast2+sqq0));
            sqq2=sqrt(complex(-qq/cast2-sqq0));
            rt=[sqq1;-sqq1;sqq2;-sqq2;]-aa/cast4;

        else



            a=cast2*qq;a2=a*a;
            b=qq*qq-cast4*ss;


            q=b-a2/cast3;
            r=cast2*a2*a/cast(27,DT)-rr*rr-a*b/cast3;




            if abs(q)<cast(1e-15,DT)
                rt=[cast0;cast0;cast0;-aa];
            else

                sqrtdisc=sqrt(complex(r*r/cast4+q*q*q/cast(27,DT)));
                z=(-r/cast2+sqrtdisc)^cast(1/3,DT);
                v=(-r/cast2-sqrtdisc)^cast(1/3,DT);
                k=complex(-q/(cast3*z)-a/cast3+z);
                kv=complex(-q/(cast3*v)-a/cast3+v);




                if isa(B,'single')
                    thres=cast(0.01,'single');
                else
                    thres=1e-4;
                end

                if~isfinite(k)||(isfinite(kv)&&(abs(v)>abs(z)||(abs(k)<thres&&abs(kv)>cast3*abs(k))))
                    k=kv;
                end
                if abs(imag(k))<=cast2*eps(DT)
                    k=complex(real(k));
                end


                if abs(rr)<thresRR&&abs(rr)>abs(k)

                    sqq0=sqrt(complex(qq*qq/cast4-ss));
                    sqq1=sqrt(complex(-qq/cast2+sqq0));
                    sqq2=sqrt(complex(-qq/cast2-sqq0));
                    rt=[sqq1;-sqq1;sqq2;-sqq2;]-aa/cast4;
                else





                    s=sqrt(k);
                    rt=[-s+sqrt(+cast2*rr/s-k-cast2*qq);...
                    -s-sqrt(+cast2*rr/s-k-cast2*qq);...
                    s+sqrt(-cast2*rr/s-k-cast2*qq);...
                    s-sqrt(-cast2*rr/s-k-cast2*qq)]/cast2-aa/cast4;
                end
            end
        end
