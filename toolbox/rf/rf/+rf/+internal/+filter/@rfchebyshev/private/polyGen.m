function out=polyGen(Coeff)




    nelem=size(Coeff,1);
    if nelem>1
        out=1;
        for i=1:nelem
            out=conv(out,Coeff(i,:));
        end
    else
        out=Coeff;
    end
    index=find(out,1);
    out=out(index:end);
end
