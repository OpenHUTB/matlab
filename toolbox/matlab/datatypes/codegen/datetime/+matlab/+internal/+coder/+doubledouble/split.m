function aout=split(a)%#codegen




    coder.allowpcode('plain');


    DD_SPLITTER=134217729.0;
    DD_SPLIT_THRESH=6.69692879491417e+299;
    DD_RSCALE=268435456.0;
    DD_SCALE=3.7252902984619140625e-09;


    aout=complex(zeros(size(a)),zeros(size(a)));
    for j=1:numel(a)

        if(abs(a(j))<=DD_SPLIT_THRESH)
            temp=DD_SPLITTER*a(j);
            shi=temp-(temp-a(j));
            slo=a(j)-shi;
            aout(j)=complex(shi,slo);
        elseif isfinite(a)
            a(j)=a(j)*DD_SCALE;
            temp=DD_SPLITTER*a(j);
            shi=temp-(temp-a(j));
            slo=a(j)-shi;
            shi=shi*DD_RSCALE;
            slo=slo*DD_RSCALE;
            aout(j)=complex(shi,slo);
        else
            aout(j)=complex(a(j),0);
        end

    end
