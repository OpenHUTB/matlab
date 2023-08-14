function[f,df]=mad_local_objective(x,dY,objScalingFactor)



















    [N,n]=size(dY);

    Z=dY*x(1:n);

    f=mean(abs(Z));


    if nargin==3
        f=objScalingFactor*f;
    end

    if nargout>1
        df=(1/N)*(dY'*sign(Z));


        if numel(x)>n
            df=[df;zeros(numel(x)-n,1)];
        end


        if nargin==3
            df=objScalingFactor*df;
        end

    end
