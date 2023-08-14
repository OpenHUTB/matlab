function lpi_modified=resolveDALUTPartition(this,lpi)






    polyc=this.polyphasecoefficients;

    lpi=sort(lpi,'descend');
    lpi_modified=[];

    out={};
    for n=1:size(polyc,1)
        allowedin=length(find(polyc(n,:)));
        m=1;
        done=0;
        out1=[];
        while~done
            if allowedin>lpi(m)
                out1=[out1,lpi(m)];
                allowedin=allowedin-lpi(m);
            else
                out1=[out1,allowedin];
                done=1;
            end
            m=m+1;
        end
        out{n}=out1;
    end
    maxlen=0;
    for n=1:length(out)
        if maxlen<length(out{n})
            maxlen=length(out{n});
        end
    end
    for n=1:length(out)
        if length(out{n})<maxlen
            lpi_modified(n,:)=[out{n},zeros(1,(maxlen-length(out{n})))];
        else
            lpi_modified(n,:)=out{n};
        end
    end



