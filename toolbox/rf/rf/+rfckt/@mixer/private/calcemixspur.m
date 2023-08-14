function spurdata=calcemixspur(h,spurdata,zl,zs,z0,cktindex,~)






    narginchk(6,7);


    checkproperty(h);
    fin=spurdata.Fin;
    fin(fin==0.0)=eps;
    pin=spurdata.Pin;
    idxin=spurdata.Idxin;
    [pl,freq]=calcpout(h,pin,fin,zl,zs,z0);
    k=1;
    if isempty(spurdata.Pout{k+cktindex})
        psignal=max(pl);
    else
        psignal=spurdata.Pout{k+cktindex}(1);
    end
    idx=find(pl>(psignal-99));
    if~isempty(idx)
        freq=freq(idx);
        pl=pl(idx);
        idxin=idxin(idx);
        n=length(spurdata.Freq{k+cktindex});
        m=length(freq);
        spurdata.Freq{k+cktindex}=[spurdata.Freq{k+cktindex};freq];
        spurdata.Pout{k+cktindex}=[spurdata.Pout{k+cktindex};pl];
        for ii=1:m
            spurdata.Indexes{cktindex+1}{n+ii,1}=idxin{ii};
        end
    end


    spurdata.Fin=spurdata.Freq{k+1}(1);
    spurdata.Pin=spurdata.Pout{k+1}(1);
    spurdata=addmixspur(h,spurdata,zl,zs,z0,cktindex);