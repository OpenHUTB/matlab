function qp=quantizePoints(p)

    nameOfFunction='quantizePoints';
    validateattributes(p,{'numeric'},{'nonempty','finite','real',...
    'nonnan',},...
    nameOfFunction,'p',1);
    precision=1e12;


    qp=p;

end