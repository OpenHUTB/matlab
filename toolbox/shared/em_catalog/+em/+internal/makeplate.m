function[p,corners]=makeplate(length,width,n,distribution,varargin)















    nameOfFunction='makeplate';
    validateattributes(n,{'numeric'},{'vector','nonempty',...
    'integer','finite','nonnan','positive','>',1},nameOfFunction,...
    'Number of points',3);

    validateattributes(distribution,{'char','string'},{'nonempty','scalartext'},nameOfFunction,...
    'Type of distribution',4);


    corners=em.internal.makerectangle(length,width);
    if isscalar(n)
        isnscalar=true;
        N=[n,n,n,n];
    elseif numel(n)==4
        isnscalar=false;
        N=n;
    else
        error(message('antenna:antennaerrors:InvalidOption'));

    end

    switch distribution
    case 'linear'
        n1=N(1);

        p1(1,:)=linspace(corners(1,1),corners(1,2),n1);
        p1(2,:)=linspace(corners(2,1),corners(2,2),n1);
        p1(3,:)=linspace(corners(3,1),corners(3,2),n1);

        n2=N(2);
        p2(1,:)=linspace(corners(1,2),corners(1,3),n2);
        p2(2,:)=linspace(corners(2,2),corners(2,3),n2);
        p2(3,:)=linspace(corners(3,2),corners(3,3),n2);

        if isnscalar

            p3=fliplr(p1);
            p3(2,:)=-1.*p3(2,:);

            p4=fliplr(p2);
            p4(1,:)=-1.*p4(1,:);
        else

            n3=N(3);
            p1(1,:)=linspace(corners(1,1),corners(1,2),n3);
            p1(2,:)=linspace(corners(2,1),corners(2,2),n3);
            p1(3,:)=linspace(corners(3,1),corners(3,2),n3);
            p3=fliplr(p1);
            p3(2,:)=-1.*p3(2,:);

            n4=N(4);
            p2(1,:)=linspace(corners(1,2),corners(1,3),n4);
            p2(2,:)=linspace(corners(2,2),corners(2,3),n4);
            p2(3,:)=linspace(corners(3,2),corners(3,3),n4);
            p4=fliplr(p2);
            p4(1,:)=-1.*p4(1,:);
        end


    case 'chebyshev-I'

        n1=N(1);
        p1(1,:)=em.internal.chebspace(length/2,n1,'I');
        p1(1,:)=fliplr(p1(1,:));
        p1(2,:)=corners(2,1).*ones(1,n1);
        p1(3,:)=zeros(1,n1);

        n2=N(2);
        p2(1,:)=length/2.*ones(1,n2);
        p2(2,:)=em.internal.chebspace(width/2,n2,'I');
        p2(2,:)=-1.*p2(2,:);
        p2(3,:)=zeros(1,n2);

        if isnscalar

            p3=fliplr(p1);
            p3(2,:)=-1.*p3(2,:);

            p4=fliplr(p2);
            p4(1,:)=-1.*p4(1,:);
        else

            n3=N(3);
            p1(1,:)=em.internal.chebspace(length/2,n3,'I');
            p1(1,:)=fliplr(p1(1,:));
            p1(2,:)=corners(2,1).*ones(1,n3);
            p1(3,:)=zeros(1,n3);
            p3=fliplr(p1);
            p3(2,:)=-1.*p3(2,:);

            n4=N(4);
            p2(1,:)=length/2.*ones(1,n4);
            p2(2,:)=em.internal.chebspace(width/2,n4,'I');
            p2(2,:)=-1.*p2(2,:);
            p2(3,:)=zeros(1,n4);
            p4=fliplr(p2);
            p4(1,:)=-1.*p4(1,:);
        end
    case 'chebyshev-II'

        n1=N(1);
        p1(1,:)=em.internal.chebspace(length/2,n1,'II');
        p1(1,:)=fliplr(p1(1,:));
        p1(2,:)=corners(2,1).*ones(1,n1);
        p1(3,:)=zeros(1,n1);

        n2=N(2);
        p2(1,:)=length/2.*ones(1,n2);
        p2(2,:)=em.internal.chebspace(width/2,n2,'II');
        p2(2,:)=-1.*p2(2,:);
        p2(3,:)=zeros(1,n2);
        if isnscalar

            p3=fliplr(p1);
            p3(2,:)=-1.*p3(2,:);

            p4=fliplr(p2);
            p4(1,:)=-1.*p4(1,:);
        else

            n3=N(3);
            p1(1,:)=em.internal.chebspace(length/2,n3,'I');
            p1(1,:)=fliplr(p1(1,:));
            p1(2,:)=corners(2,1).*ones(1,n3);
            p1(3,:)=zeros(1,n3);
            p3=fliplr(p1);
            p3(2,:)=-1.*p3(2,:);

            n4=N(4);
            p2(1,:)=length/2.*ones(1,n4);
            p2(2,:)=em.internal.chebspace(width/2,n4,'I');
            p2(2,:)=-1.*p2(2,:);
            p2(3,:)=zeros(1,n4);
            p4=fliplr(p2);
            p4(1,:)=-1.*p4(1,:);
        end
    end


    p1=em.internal.quantizePoints(p1);
    p2=em.internal.quantizePoints(p2);
    p3=em.internal.quantizePoints(p3);
    p4=em.internal.quantizePoints(p4);

    if nargin==6
        point1=varargin{1};
        loc=varargin{2};
        validateattributes(point1,{'numeric'},...
        {'nonempty','finite','real','nonnan','numel',3},...
        nameOfFunction,'Point 1',5);
        if~iscolumn(point1)
            point1=point1';
        end
        point1=em.internal.quantizePoints(point1);


        if loc==1
            [p1x,p1y,p1z]=insertpoints(p1,point1);
            p1=sortpoints(p1x,p1y,p1z,1);
        elseif loc==2
            [p2x,p2y,p2z]=insertpoints(p2,point1);
            p2=sortpoints(p2x,p2y,p2z,2);
        elseif loc==3
            [p3x,p3y,p3z]=insertpoints(p3,point1);
            p3=sortpoints(p3x,p3y,p3z,3);
        else
            [p4x,p4y,p4z]=insertpoints(p4,point1);
            p4=sortpoints(p4x,p4y,p4z,4);
        end
    end
    p=[p1,p2,p3,p4];
    p=em.internal.antuniquetol(p,1e-12);
end

function[px,py,pz]=insertpoints(p1,p2)



    p1_x=p1(1,:);
    p1_y=p1(2,:);
    p1_z=p1(3,:);


    px=[p1_x,p2(1,1)];
    py=[p1_y,p2(2,1)];
    pz=[p1_z,p2(3,1)];

end

function ps=sortpoints(px,py,pz,loc)

    if loc==1||loc==2
        flag='ascend';
    else
        flag='descend';
    end


    p1_xs=sort(px,2,flag);
    p1_ys=sort(py,2,flag);
    p1_zs=sort(pz,2,flag);


    tol=1e-12;
    if loc==1||loc==3

        index=em.internal.findrepeats(p1_xs,tol);
    else

        index=em.internal.findrepeats(p1_ys,tol);
    end



    ps=[p1_xs;p1_ys;p1_zs];

    ps(:,index)=[];

end