function p=makestriphelix(r,W,theta,S,offset,varargin)






    nameOfFunction='makestriphelix';
    if nargin>8
        error(message('antenna:antennaerrors:IncorrectNumArguments','input','input','6'));
    elseif(nargin==6)
        error(message('antenna:antennaerrors:IncorrectNumArguments','input','input','4'));
    end

    validateattributes(W,{'numeric'},{'scalar','nonempty','real',...
    'finite','nonnan','positive'},...
    nameOfFunction,'Strip width',2);


    if nargin==7
        point1=varargin{1};
        point2=varargin{2};
        validateattributes(point1,{'numeric'},...
        {'nonempty','finite','real',...
        'nonnan','numel',3},...
        nameOfFunction,'Point 1',5);
        validateattributes(point2,{'numeric'},{'nonempty','finite','real',...
        'nonnan','numel',3},...
        nameOfFunction,'Point 2',6);
        if~iscolumn(point1)
            point1=point1';
        end

        if~iscolumn(point2)
            point2=point2';
        end
    end
    if nargin~=8

        p1=em.internal.makehelix(r,theta,S,offset);
        p2=em.internal.makehelix(r+W,theta,S,offset);
    else

        p1=em.internal.makehelix(r,theta,S,offset);
        p2=p1;

        p2(3,:)=p2(3,:)+W;
    end

    if nargin==7
        p1=[point1,p1];
        p2=[point2,p2];
    end


    p1_u=zeros(3,2*(size(p1,2)));
    p1_u(:,1:2:end)=p1_u(:,1:2:end)+p1;
    p2_u=zeros(3,2*(size(p2,2)));
    p2_u(:,1:2:end)=p2_u(:,1:2:end)+p2;
    p2_u=[p2_u(:,end),p2_u(:,1:end-1)];
    p=p1_u+p2_u;
end
