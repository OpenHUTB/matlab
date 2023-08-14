function[x,y,z]=splitline(p1,p2,N)












    narginchk(3,3)

    nameOfFunction='splitLine';
    validateattributes(p1,{'numeric'},{'ncols',3,'nonnan'},nameOfFunction,'Start point, p1',1);
    validateattributes(p2,{'numeric'},{'ncols',3,'nonnan'},nameOfFunction,'Stop point, p2',2);
    validateattributes(N,{'numeric'},{'scalar','nonempty',...
    'integer','finite','nonnan','positive','>',1},nameOfFunction,...
    'Number of points',3);


    x1=p1(1);
    y1=p1(2);
    z1=p1(3);
    x2=p2(1);
    y2=p2(2);
    z2=p2(3);
    x=linspace(x1,x2,N);
    y=linspace(y1,y2,N);
    z=linspace(z1,z2,N);
end