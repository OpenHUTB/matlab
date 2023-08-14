function P=calcRadiatedPower(obj,fc,R,varargin)














    narginchk(3,4);
    [PointsSph,n_s,Area_s]=em.internal.generateRadiationSphere(R,obj);
    if nargin==3
        Z=1e-12;
    elseif~isempty(varargin)
        validateattributes(varargin{1},{'numeric'},{'finite','real',...
        'positive','nonnan','scalar'});
        Z=varargin{1};
    end

    if isa(obj,'em.Antenna')
        [EfieldpatSph,HfieldpatSph]=EHfields(obj,fc,PointsSph);
    elseif isa(obj,'em.Array')
        N=prod(obj.ArraySize);
        Es=zeros(3,size(PointsSph,2),N);
        Hs=Es;
        for i=1:N



            [Es(:,:,i),Hs(:,:,i)]=EHfields(obj,fc,PointsSph,'ElementNumber',i,...
            'Termination',Z);
        end
        EfieldpatSph=sum(Es,3);
        HfieldpatSph=sum(Hs,3);
    else
        error('Only antennas and arrays can be used to compute radiated power')

    end


    Poynting=0.5*real(cross(EfieldpatSph,conj(HfieldpatSph)));
    P=R^2*sum(abs(dot(n_s,Poynting)).*Area_s);
    clear Area_s n_s
