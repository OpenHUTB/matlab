function[J,u,v]=removeExtraNaNs(J,u,v)











    if nargin<3
        n=isnan(J)|isnan(u);
    else
        n=isnan(J)|isnan(u)|isnan(v);
    end


    J(n)=NaN;
    u(n)=NaN;


    firstOrPrecededByNaN=[true;n(1:end-1)];
    extraNaN=n&firstOrPrecededByNaN;
    J(extraNaN)=[];
    u(extraNaN)=[];


    if~isempty(J)&&isnan(J(end))
        terminatingNaN=numel(J);
    else
        terminatingNaN=[];
    end
    J(terminatingNaN)=[];
    u(terminatingNaN)=[];


    if isempty(J)
        J=reshape(J,[0,1]);
        u=J;
    end

    if nargin==3
        v(n)=NaN;
        v(extraNaN)=[];
        v(terminatingNaN)=[];
        if isempty(v)
            v=reshape(v,[0,1]);
        end
    end
end
