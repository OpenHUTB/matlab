function yOut=upfirdnGPUImpl(xCol,hCl,Lx,Lh,hCols,nChans,p,q)%#codegen



























    coder.allowpcode('plain');

    coder.gpu.internal.kernelfunImpl(false);


    x=upsample(xCol,p);


    if(hCols==1&&nChans==1)||(hCols~=nChans)


        w=conv2(x,hCl);
    else


        w=zeros(Lh+size(x,1)-1,nChans,'like',xCol);
        for n=1:nChans
            result=conv(x(1:end,n),hCl(1:end,n));
            w(1:end,n)=result;
        end
    end


    y=downsample(w,q);


    Ly=ceil(((Lx-1)*p+Lh)/q);
    if size(y,1)<Ly
        yOut=y;
    else
        yOut=y(1:Ly,:);
    end

end