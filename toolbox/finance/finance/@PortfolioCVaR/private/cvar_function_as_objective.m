function[f,df]=cvar_function_as_objective(x,Y,plevel,objScalingFactor)





















    [S,n]=size(Y);

    x=x(:);

    z=-Y*x(1:n);

    ka=ceil(plevel*S);

    if nargout<2
        z=sort(z);

        if ka<S
            f=((ka-S*plevel)*z(ka)+sum(z(ka+1:S)))/(S*(1-plevel));
        else
            f=z(ka);
        end


        if nargin==4
            f=objScalingFactor*f;
        end

    else
        [z,ii]=sort(z);



        if ka<S
            f=((ka-S*plevel)*z(ka)+sum(z(ka+1:S)))/(S*(1-plevel));
            df=-((ka-S*plevel)*Y(ii(ka),:)+sum(Y(ii(ka+1:S),:),1))/(S*(1-plevel));
        else
            f=z(ka);
            df=-Y(ii(ka),:);
        end
        df=df';


        if n<numel(x)
            df=[df;zeros(numel(x)-n,1)];
        end


        if nargin==4
            f=objScalingFactor*f;
            df=objScalingFactor*df;
        end

    end
