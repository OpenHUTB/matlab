function A=areaOfTriangle(varargin)


    narginchk(1,3);

    L=varargin{:};

    validateattributes(L,{'numeric'},...
    {'vector','nonempty','real','finite','nonnan','positive'});

    if isscalar(L)
        L1=L;
        L2=L;
        L3=L;
    elseif numel(L)==2
        L1=L(1);
        L2=L(2);
        L3=L(2);
    else
        L1=L(1);
        L2=L(2);
        L3=L(3);
    end

    s=(L1+L2+L3)/2;
    A=sqrt(s*(s-L1)*(s-L2)*(s-L3));