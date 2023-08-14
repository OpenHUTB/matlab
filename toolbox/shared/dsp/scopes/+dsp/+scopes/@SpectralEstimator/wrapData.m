function xout=wrapData(obj,xin)




    [nrows,ncols,n3d]=size(xin);
    fact=ceil(nrows/obj.pNFFT);
    extraZeros=obj.pNFFT*fact-nrows;
    xin=[xin;zeros(extraZeros,ncols,n3d)];
    xin=reshape(xin,obj.pNFFT,ncols*fact,n3d);
    xout=zeros(obj.pNFFT,ncols,n3d);
    for idx=1:ncols
        xout(:,idx,:)=sum(xin(:,(idx-1)*fact+1:idx*fact,:),2);
    end
end
