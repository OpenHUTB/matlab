function p=chebspace(r,n,type)













    nameOfFunction='chebspace';
    validateattributes(r,{'numeric'},{'scalar','nonempty','real',...
    'finite','nonnan','positive'},...
    nameOfFunction,'Half-distance',1);
    validateattributes(n,{'numeric'},{'scalar','nonempty',...
    'integer','finite',...
    'nonnan','positive'},...
    nameOfFunction,'Number of points',2);
    validateattributes(type,{'char','string'},{'nonempty','scalartext'},...
    nameOfFunction,'Type',3);

    N=n-1;
    switch type
    case 'I'
        p=r*cos((2.*(0:N)+1).*pi./(2*N+2));
    case 'II'
        p=r*cos((0:N).*pi/N);
    otherwise
        error(message('antenna:antennaerrors:IncorrectOption','type','I or II'));
    end
    p=em.internal.quantizePoints(p);
end