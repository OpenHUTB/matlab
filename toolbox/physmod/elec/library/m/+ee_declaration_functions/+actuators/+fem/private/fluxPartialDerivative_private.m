function dFdX=fluxPartialDerivative_private(F,X,interp_method)%#codegen














    coder.allowpcode('plain');

    delta=min(abs(diff(X)))/10;
    [ni,nx]=size(F);
    dFdX=zeros(ni,nx);
    for i=1:ni

        switch interp_method
        case 2
            flux_m=interp1(X,F(i,:),X-delta,'spline','extrap');
            flux_p=interp1(X,F(i,:),X+delta,'spline','extrap');
        case 3
            flux_m=interp1(X,F(i,:),X-delta,'spline','extrap');
            flux_p=interp1(X,F(i,:),X+delta,'spline','extrap');
        otherwise
            flux_m=interp1(X,F(i,:),X-delta,'linear','extrap');
            flux_p=interp1(X,F(i,:),X+delta,'linear','extrap');
        end
        dFdX(i,:)=(flux_p-flux_m)/(2*delta);
    end

end