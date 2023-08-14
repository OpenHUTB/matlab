function[p,corners]=makestrip(length,width,n,distribution,varargin)






























    nameOfFunction='makestrip';
    if nargin>7
        error(message('antenna:antennaerrors:IncorrectNumArguments','input','input','7'));
    elseif(nargin==5)
        error(message('antenna:antennaerrors:IncorrectNumArguments','input','input','5'));
    end

    validateattributes(n,{'numeric'},{'scalar','nonempty',...
    'integer','finite',...
    'nonnan','positive'},...
    nameOfFunction,'Number of points',3);

    validateattributes(distribution,{'char','string'},{'nonempty','scalartext'},nameOfFunction,...
    'Type of distribution',4);


    if numel(varargin)>2
        planeStr=validatestring(varargin{3},{'XY','YZ','XZ','YX','ZY','ZX'});
    else
        planeStr='XY';
    end




    if numel(varargin)>=2
        if~isempty(varargin{1})&&~isempty(varargin{2})
            point1=varargin{1};
            point2=varargin{2};
            validateattributes(point1,{'numeric'},...
            {'nonempty','finite','real',...
            'nonnan','2d'},...
            nameOfFunction,'Point 1',5);
            validateattributes(point2,{'numeric'},{'nonempty','finite','real',...
            'nonnan','2d'},...
            nameOfFunction,'Point 2',6);
            [m1,n1]=size(point1);
            [m2,n2]=size(point2);

            if~isequal(m1,3)&&~isequal(n1,3)
                error(message('antenna:antennaerrors:IncorrectSizeOfArguments'));
            end

            if~isequal(m2,3)&&~isequal(n2,3)
                error(message('antenna:antennaerrors:IncorrectSizeOfArguments'));
            end

            if~isequal(m1,3)
                point1=point1';
            end

            if~isequal(m1,3)
                point2=point2';
            end

            point1=em.internal.quantizePoints(point1);
            point2=em.internal.quantizePoints(point2);
        else
            point1=[];
            point2=[];
        end
    else
        point1=[];
        point2=[];
    end


    corners=em.internal.makerectangle(length,width);


    switch distribution
    case 'linear'
        p1(1,:)=linspace(corners(1,1),corners(1,2),n);
        p1(2,:)=linspace(corners(2,1),corners(2,2),n);
        p1(3,:)=linspace(corners(3,1),corners(3,2),n);
        p2=fliplr(p1);
        p2(2,:)=-1.*p2(2,:);
    case 'chebyshev-I'
        p1(1,:)=em.internal.chebspace(length/2,n,'I');
        p1(2,:)=corners(2,1).*ones(1,n);
        p1(3,:)=zeros(1,n);
        p2=fliplr(p1);
        p2(2,:)=-1.*p2(2,:);
    case 'chebyshev-II'
        p1(1,:)=em.internal.chebspace(length/2,n,'II');
        p1(2,:)=corners(2,1).*ones(1,n);
        p1(3,:)=zeros(1,n);
        p2=fliplr(p1);
        p2(2,:)=-1.*p2(2,:);
    end


    p1=em.internal.quantizePoints(p1);
    p2=em.internal.quantizePoints(p2);


    switch planeStr
    case 'XY'
        p1=p1;
        p2=p2;
        loc=1;
    case 'YZ'
        p1=[p1(3,:);p1(2,:);p1(1,:)];
        p2=[p2(3,:);p2(2,:);p2(1,:)];
        loc=3;
    case 'ZX'
        p1=[p1(2,:);p1(3,:);p1(1,:)];
        p2=[p2(2,:);p2(3,:);p2(1,:)];
        loc=3;
    end

    if~isempty(point1)&&~isempty(point2)

        [p1x,p1y,p1z]=insertpoints(p1,point1);
        p1=sortpoints(p1x,p1y,p1z,loc);
        [p2x,p2y,p2z]=insertpoints(p2,point2);
        p2=sortpoints(p2x,p2y,p2z,loc);
    end


    p1=sortpoints(p1(1,:),p1(2,:),p1(3,:),loc);
    p2=sortpoints(p2(1,:),p2(2,:),p2(3,:),loc);


    p1_u=zeros(3,2*(size(p1,2)));
    p1_u(:,1:2:end)=p1_u(:,1:2:end)+p1;
    p2_u=zeros(3,2*(size(p2,2)));
    p2_u(:,1:2:end)=p2_u(:,1:2:end)+p2;
    p2_u=[p2_u(:,end),p2_u(:,1:end-1)];
    p=p1_u+p2_u;

end

function[px,py,pz]=insertpoints(p1,p2)



    p1_x=p1(1,:);
    p1_y=p1(2,:);
    p1_z=p1(3,:);


    px=[p1_x,p2(1,:)];
    py=[p1_y,p2(2,:)];
    pz=[p1_z,p2(3,:)];

end
function ps=sortpoints(px,py,pz,loc)

    flag='ascend';

    p1_xs=sort(px,2,flag);
    p1_ys=sort(py,2,flag);
    p1_zs=sort(pz,2,flag);


    tol=1e-12;
    if loc==1

        index=em.internal.findrepeats(p1_xs,tol);
    elseif loc==3

        index=em.internal.findrepeats(p1_zs,tol);
    end



    ps=[p1_xs;p1_ys;p1_zs];

    ps(:,index)=[];

end















