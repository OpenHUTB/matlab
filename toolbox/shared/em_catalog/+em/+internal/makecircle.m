function p=makecircle(r,varargin)





    nameOfFunction='makecircle';
    validateattributes(r,{'numeric'},{'nonempty','scalar',...
    'nonnan','finite','real','positive'},...
    nameOfFunction,'Radius',1);

    N=30;
    del_phi=360/N;
    phi_start=0;
    phi_end=360-del_phi;
    phi=linspace(phi_start,phi_end,N);
    if(nargin==2)
        validateattributes(varargin{1},{'numeric'},{'nonempty','vector',...
        'nonnan','finite','real'},...
        nameOfFunction,'Angular discretization',2);
        phi=varargin{1};
    elseif(nargin>2)
        error(message('antenna:antennaerrors:IncorrectNumArguments','input','input','2'));
    end

    x=r.*cosd(phi);
    y=r.*sind(phi);
    z=zeros(size(x));
    p=[x;y;z];
    p=em.internal.quantizePoints(p);
end

