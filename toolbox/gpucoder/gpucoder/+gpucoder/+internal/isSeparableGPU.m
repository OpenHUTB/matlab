
function[separable,hcol,hrow]=isSeparableGPU(a_size,h)






    resHD=720*1280;
    if(a_size(1)*a_size(2)>resHD)
        sep_threshold=81;
    else
        sep_threshold=289;
    end

    if((numel(h)>=sep_threshold)&&...
        (ismatrix(h))&&...
        all(size(h)~=1)&&...
        all(isfinite(h(:))))

        s=zeros(size(h));
        u=zeros(size(h,1));
        v=zeros(size(h,2));
        [u,s,v]=svd(h);

        s=diag(s(:,:));
        tol=length(h)*max(s)*eps;
        rank=sum(s>tol);

        if(rank==1)

            hcol=u(:,1)*sqrt(s(1));
            hrow=v(:,1)'*sqrt(s(1));
            separable=true;
        else
            separable=false;
        end
    else
        separable=false;
    end

    if~separable




        hcol=zeros(size(h,1),1);
        hrow=zeros(1,size(h,2));
    end