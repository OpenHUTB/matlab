function[h,m,s]=secs2hms(secs)%#codegen




    coder.allowpcode('plain');

    h=zeros(size(secs));
    m=zeros(size(secs));
    s=zeros(size(secs));

    for j=1:numel(secs)

        secsj=secs(j);

        if(secsj>=0.0&&secsj<=double(intmax))

            isecs=int32(secsj);

            ih.quot=idivide(isecs,3600);
            ih.rem=rem(isecs,3600);

            im.quot=idivide(ih.rem,60);
            im.rem=rem(ih.rem,60);

            h(j)=double(ih.quot);
            m(j)=double(im.quot);
            s(j)=double(im.rem);

        else

            h(j)=floor(secsj/3600);
            m(j)=floor((secsj-3600*h(j))/60);
            s(j)=secsj-60*m(j);
        end

    end

end