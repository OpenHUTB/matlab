function area=findArea(X,Y)











    nameOfFunction='findArea';
    validateattributes(X,{'numeric'},{'nonempty','finite','real',...
    'nonnan','numel',3},...
    nameOfFunction,'X',1);
    validateattributes(Y,{'numeric'},{'nonempty','finite','real',...
    'nonnan','numel',3},...
    nameOfFunction,'Y',2);
    tol=sqrt(eps);
    area=0.5*abs((X(1)-X(3))*(Y(2)-Y(3)))-((X(2)-X(3))*(Y(1)-Y(3)));
    if area<tol
        area=0;
    end

end

