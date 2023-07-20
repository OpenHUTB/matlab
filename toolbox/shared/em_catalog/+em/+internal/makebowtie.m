function[pleft,pright]=makebowtie(L,a,alpha,center,type,numpoints)























    nameOfFunction='makebowtie';
    validateattributes(L,{'numeric'},{'scalar','nonempty','real',...
    'finite','nonnan','positive'},...
    nameOfFunction,'Length',1);

    validateattributes(a,{'numeric'},{'scalar','nonempty','real',...
    'finite','nonnan','positive'},...
    nameOfFunction,'Width in center',2);

    validateattributes(alpha,{'numeric'},{'scalar','nonempty','real',...
    'finite','nonnan','positive'},...
    nameOfFunction,'Flare angle',3);


    if(alpha>=175)
        error(message('antenna:antennaerrors:InvalidValueLess','alpha','175 deg'));
    elseif(alpha<5)
        error(message('antenna:antennaerrors:InvalidValueGreater','alpha','5 deg'));
    end

    validateattributes(center,{'numeric'},...
    {'nonempty','finite','real',...
    'nonnan','numel',3},nameOfFunction,'Center',4);

    validateattributes(type,{'char','string'},{'nonempty','scalartext'},nameOfFunction,...
    'Type of bowtie',5);

    bowtieset={'Triangular','Rounded'};
    typeofbowtie=strcmpi(type,bowtieset);
    if~any(typeofbowtie)
        error(message('antenna:antennaerrors:InvalidValue','type','either Triangular or Rounded rather',type));
    else
        bowtietype=bowtieset{typeofbowtie};
    end

    validateattributes(numpoints,{'numeric'},{'scalar','nonempty',...
    'integer','finite',...
    'nonnan','positive'},...
    nameOfFunction,'Number of boundary points',6);

    r=(L/2)*secd(alpha/2);
    W=r*sind(alpha/2);
    x_min=-L/2;
    x_max=L/2;
    y_min=-W;
    y_max=W;
    feed_x=center(1);
    feed_y=center(2);

    switch bowtietype
    case 'Triangular'

        xleft=x_min.*ones(1,numpoints);
        yleft=linspace(y_min,y_max,numpoints);
        yleft=fliplr(yleft);

        xright=x_max.*ones(1,numpoints);
        yright=fliplr(yleft);
    case 'Rounded'

        theta_left=(linspace(180-alpha/2,180+alpha/2,numpoints));
        theta_right=(linspace(-alpha/2,alpha/2,numpoints));

        xleft=L/2.*cosd(theta_left);
        yleft=L/2.*sind(theta_left);
        xright=L/2.*cosd(theta_right);
        yright=L/2.*sind(theta_right);
    end


    px_right=[feed_x;xright';feed_x];
    py_right=[feed_y-a/2;yright';feed_y+a/2];







    pz_right=zeros(size(px_right));

    px_left=[feed_x;xleft';feed_x];
    py_left=[feed_y+a/2;yleft';feed_y-a/2];








    pz_left=zeros(size(px_left));

    pleft=[px_left';py_left';pz_left'];
    pright=[px_right';py_right';pz_right'];

    pleft=em.internal.quantizePoints(pleft);
    pright=em.internal.quantizePoints(pright);
end




















