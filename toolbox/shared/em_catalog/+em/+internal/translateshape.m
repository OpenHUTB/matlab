function p=translateshape(points,vector)

















    nameOfFunction='translateshape';


    validateattributes(points,{'numeric'},{'nonempty','finite','real',...
    'nonnan','nrows',3},nameOfFunction,'Points',1);

    validateattributes(vector,{'numeric'},{'nonempty','finite','real',...
    'nonnan','numel',3},nameOfFunction,'Vector',2);

    if~isrow(vector)
        vector=vector';
    end

    np=size(points,2);


    tx=vector(1);
    ty=vector(2);
    tz=vector(3);


    P=[points',ones(np,1)];


    T=[1,0,0,0;...
    0,1,0,0;...
    0,0,1,0;...
    tx,ty,tz,1];


    p=P*T;


    p=p(:,1:3)';
    p=em.internal.quantizePoints(p);
end