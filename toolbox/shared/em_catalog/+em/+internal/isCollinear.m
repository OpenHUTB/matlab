function tf=isCollinear(p1,p2,p3)











    nameOfFunction='isCollinear';
    N=3;
    if numel(p1)==2
        p1(3)=0;
    end

    if numel(p2)==2
        p2(3)=0;
    end

    if numel(p3)==2
        p3(3)=0;
    end

    validateattributes(p1,{'numeric'},{'nonempty','finite','real',...
    'nonnan','ncols',N},...
    nameOfFunction,'p1',1);
    validateattributes(p2,{'numeric'},{'nonempty','finite','real',...
    'nonnan','ncols',N},...
    nameOfFunction,'p2',2);
    validateattributes(p3,{'numeric'},{'nonempty','finite','real',...
    'nonnan','ncols',N},...
    nameOfFunction,'p3',2);

    colmat=([p2-p1;p3-p1;p2-p3]);
    tf=isequal(rank(colmat,sqrt(eps)),1);

end
