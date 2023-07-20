function[y,m,d]=days2ymd(days)%#codegen




    coder.allowpcode('plain');

    dn=days+719529;


    dn=dn-61;
    y=zeros(size(days));
    mo=zeros(size(days));
    m=zeros(size(days));
    d=zeros(size(days));
    for j=1:numel(days)

        dnj=dn(j);

        if(dnj>=0.0&&dnj<=double(intmax))

            idn=int32(dnj);

            coder.internal.assert(dnj==idn,'MATLAB:datetime:DoubleDoubleAssertionCodegen')

            ig.quot=idivide(idn,146097);
            ig.rem=rem(idn,146097);

            ic.quot=idivide(ig.rem,36524);
            ic.rem=rem(ig.rem,36524);

            if(ic.quot>3)
                ic.quot=int32(3);
                ic.rem=ig.rem-ic.quot*36524;
            end

            ib.quot=idivide(ic.rem,1461);
            ib.rem=rem(ic.rem,1461);

            ia.quot=idivide(ib.rem,365);
            ia.rem=rem(ib.rem,365);
            if(ia.quot>3)
                ia.quot=int32(3);
                ia.rem=ib.rem-ia.quot*365;
            end

            y(j)=double(ig.quot*400+ic.quot*100+ib.quot*4+ia.quot);
            imo=idivide(ia.rem*5+308,153)-2;
            mo(j)=double(imo);
            d(j)=double((ia.rem-idivide(((imo+4)*153),5)+122)+1);
        else

            g=floor(dnj/146097);
            dg=dnj-g*146097;

            c=floor(dg/36524);

            if(c>3)
                c=3;
            end

            dc=dg-c*36524;

            b=floor(dc/1461);
            db=dc-b*1461;

            a=floor(db/365);
            if a>3
                a=3;

            end
            da=db-a*365;

            y(j)=g*400+c*100+b*4+a;

            mo(j)=floor((da*5+308)/153)-2;

            d(j)=(da-floor(((mo(j)+4)*153)/5)+122)+1;

        end


        if(mo(j)>9)
            y(j)=y(j)+1;
            m(j)=(mo(j)+2)-11;
        else
            m(j)=(mo(j)+2)+1;
        end


    end

end