function result=hasQuantizationError(n,comphandle)
















    h=comphandle;
    global err;

    if(isfi(n)&&strcmp(get_param(h,'Type'),'block'))

        if(strcmp(get_param(h,'BlockType'),'Gain'))
            data=str2num(get_param(h,'Gain'));
        else
            data=str2num(get_param(h,'Value'));%#ok<ST2NM>
        end
        wordLength=n.WordLength;
        fractionLength=n.FractionLength;
        err=zeros(size(data));


        if~strcmp(class(data),"embedded.fi")

            if(~isreal(n))
                sign=1;
            else
                sign=double(n.Signed);
            end
            if(sign==0)
                f='ufixed';
            else
                f='fixed';
            end
            q=quantizer(f,[wordLength,fractionLength]);



            ind=(upperbound(n)>=data);
            warning('off','fixed:fi:overflow');
            err(ind)=quantize(q,data(ind))-data(ind);
            warning('on','fixed:fi:overflow');

            ind=(q.max<data);
            err(ind)=1;
            ind=(q.min>data);
            err(ind)=1;
        end
    end

    if any(err)
        result=true;
    else
        result=false;
    end
    clear global err;


