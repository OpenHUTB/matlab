function transphi=transformParameters(paramtransform,varargin)
















    if any(paramtransform==2)&&~SimBiology.internal.checkForToolbox('stats',true)
        exception=MException(message('SimBiology:sbiofit:StatsRequired'));
        throwAsCaller(exception);
    end

    if nargin==1

        if all(paramtransform==0)
            transphi=@(x)x;
        elseif all(paramtransform==1)
            transphi=@(x)log(x);
        elseif all(paramtransform==2)
            transphi=@(x)norminv(x);
        elseif all(paramtransform==3)
            transphi=@(x)log(x./(1-x));
        else
            i1=(paramtransform==1);
            i2=(paramtransform==2);
            i3=(paramtransform==3);
            transphi=@(x)transbetaselector(x,i1,i2,i3);
        end

    elseif nargin==2&&strcmp(varargin{1},'inverse')

        if all(paramtransform==0)
            transphi=@(x)x;
        elseif all(paramtransform==1)
            transphi=@(x)exp(x);
        elseif all(paramtransform==2)
            transphi=@(x)normcdf(x);
        elseif all(paramtransform==3)
            transphi=@(x)1./(1+exp(-x));
        else
            i1=(paramtransform==1);
            i2=(paramtransform==2);
            i3=(paramtransform==3);
            transphi=@(x)transphiselector(x,i1,i2,i3);
        end

    elseif nargin==2&&strcmp(varargin{1},'deriv_inv')


            if all(paramtransform==0)
                transphi=@(x)ones(size(x));
            elseif all(paramtransform==1)
                transphi=@(x)exp(x);
            elseif all(paramtransform==2)
                transphi=@(x)normpdf(x);
            elseif all(paramtransform==3)
                transphi=@(x)1./(2+exp(-x)+exp(x));
            else
                i1=(paramtransform==1);
                i2=(paramtransform==2);
                i3=(paramtransform==3);
                transphi=@(x)dtransphiselector(x,i1,i2,i3);
            end
        end
    end
end


function psi=transbetaselector(phi,i1,i2,i3)
    psi=phi;
    if any(i1)
        psi(i1,:)=log(phi(i1,:));
    end
    if any(i2)
        psi(i2,:)=norminv(phi(i2,:));
    end
    if any(i3)
        psi(i3,:)=log(phi(i3,:)./(1-phi(i3,:)));
    end
end


function psi=transphiselector(phi,i1,i2,i3)
    psi=phi;
    if any(i1)
        psi(i1,:)=exp(phi(i1,:));
    end
    if any(i2)
        psi(i2,:)=normcdf(phi(i2,:));
    end
    if any(i3)
        psi(i3,:)=1./(1+exp(-phi(i3,:)));
    end
end


function d_psi=dtransphiselector(phi,i1,i2,i3)
    d_psi=ones(size(phi));
    if any(i1)
        d_psi(i1,:)=exp(phi(i1,:));
    end
    if any(i2)
        d_psi(i2,:)=normpdf(phi(i2,:));
    end
    if any(i3)
        d_psi(i3,:)=1./(2+exp(-phi(i3,:))+exp(phi(i3,:)));
    end
end

