function p=rotateshape(points,axispoint1,axispoint2,rotangle)


















    nameOfFunction='rotateshape';
    validateattributes(points,{'numeric'},{'nonempty','finite','real',...
    'nonnan','nrows',3},nameOfFunction,'Points',1);
    validateattributes(axispoint1,{'numeric'},{'nonempty','finite','real',...
    'nonnan','numel',3},nameOfFunction,'Axis point1',2);
    validateattributes(axispoint2,{'numeric'},{'nonempty','finite','real',...
    'nonnan','numel',3},nameOfFunction,'Axis point2',3);
    validateattributes(rotangle,{'numeric'},{'scalar','nonempty','real',...
    'finite','nonnan'},nameOfFunction,'Rotation angle',4);


    if~isrow(axispoint1)
        axispoint1=axispoint1';
    end

    if~isrow(axispoint2)
        axispoint2=axispoint2';
    end


    tol=sqrt(eps);
    if all(abs(axispoint1-axispoint2)<tol)
        error(message('antenna:antennaerrors:InvalidValue','Axis point 1','unique rather','equal to axis point 2'));
    end

    np=size(points,2);

    direction_vector=axispoint2-axispoint1;


    vn=direction_vector./(norm(direction_vector));
    u=vn(1);
    v=vn(2);
    w=vn(3);


    R=zeros(4,4);
    a=axispoint1(1);
    b=axispoint1(2);
    c=axispoint1(3);
    R(1,:)=[u^2+(v^2+w^2)*cosd(rotangle),...
    u*v*(1-cosd(rotangle))-w*sind(rotangle),...
    u*w*(1-cosd(rotangle))+v*sind(rotangle),...
    (a*(v^2+w^2)-u*(b*v+c*w))*(1-cosd(rotangle))+(b*w-c*v)*sind(rotangle)];
    R(2,:)=[u*v*(1-cosd(rotangle))+w*sind(rotangle),...
    v^2+(u^2+w^2)*cosd(rotangle),...
    v*w*(1-cosd(rotangle))-u*sind(rotangle),...
    (b*(u^2+w^2)-v*(a*u+c*w))*(1-cosd(rotangle))+(c*u-a*w)*sind(rotangle)];
    R(3,:)=[u*w*(1-cosd(rotangle))-v*sind(rotangle),...
    v*w*(1-cosd(rotangle))+u*sind(rotangle),...
    w^2+(u^2+v^2)*cosd(rotangle),...
    (c*(u^2+v^2)-w*(a*u+b*v))*(1-cosd(rotangle))+(a*v-b*u)*sind(rotangle)];
    R(4,:)=[0,0,0,1];

    P=[points;ones(1,np)];
    p=R*P;
    p=p(1:3,:);
    p=em.internal.quantizePoints(p);
end

