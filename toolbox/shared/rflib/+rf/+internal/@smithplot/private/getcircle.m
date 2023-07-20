function[points,desc,infostruct]=getcircle(type,value)




    infostruct='';

    switch lower(type)
    case 'r'
        [center,radius]=rcircle(value);
        desc='Resistance';
    case 'x'
        [center,radius]=xcircle(value);
        desc='Reactance';
    case 'g'
        [center,radius]=gcircle(value);
        desc='Conductance';
    case 'b'
        [center,radius]=bcircle(value);
        desc='Susceptance';
    case 'gamma'
        [center,radius]=gammacircle(value);
        desc='|Gamma|';
    case 'q'
        [center,radius]=qcircle(value);
        desc='Q-contour';
    end

    [x,y]=circlexy(center,radius);
    points=complex(x,y);

end

function[x,y]=circlexy(c,r,nump)


    if nargin<3
        nump=1024;
    end
    num_c=numel(c);
    x=nan(1,num_c*(nump+1));
    y=nan(1,num_c*(nump+1));

    for kk=1:num_c
        angles=linspace(0,2*pi,nump);
        allpoints=c(kk)+r(kk).*exp(1i*angles);
        x((kk-1)*(nump+1)+1:kk*(nump+1)-1)=real(allpoints);
        y((kk-1)*(nump+1)+1:kk*(nump+1)-1)=imag(allpoints);

    end

    x=x(1:end-1);
    y=y(1:end-1);

end

function[center,radius]=rcircle(r)


    center=r./(r+1);
    radius=abs(1./(r+1));

end


function[center,radius]=xcircle(x)


    center=1+1i*(1./x);
    radius=abs(1./x);

end


function[center,radius]=gcircle(g)


    [center,radius]=rcircle(g);
    center=-center;

end


function[center,radius]=bcircle(b)


    [center,radius]=xcircle(b);
    center=-center;

end


function[center,radius]=qcircle(q)


    center=-1i/q.*[1,-1];
    radius=[sqrt(1+q^2)/q,sqrt(1+q^2)/q];

end


function[center,radius]=gammacircle(gamma)


    center=zeros(size(gamma));
    radius=gamma;

end
