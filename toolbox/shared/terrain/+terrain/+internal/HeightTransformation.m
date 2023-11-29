classdef(Sealed,Hidden)HeightTransformation

    properties(Constant,Hidden)
        GeoidHeightInterpolant=map.geodesy.internal.egm96GeoidHeightInterpolant
    end


    methods(Access=private)
        function obj=HeightTransformation
        end
    end

    methods(Static)
        function H=ellipsoidalToOrthometric(h,varargin)


            narginchk(2,3)


            N=geoidHeight(varargin{:});
            validateattributes(h,{'numeric'},{'real','nonsparse','size',size(N)});


            H=h-N;
        end

        function h=orthometricToEllipsoidal(H,varargin)


            narginchk(2,3)


            N=geoidHeight(varargin{:});
            validateattributes(H,{'numeric'},{'real','nonsparse','size',size(N)});


            h=H+N;
        end
    end
end

function N=geoidHeight(varargin)

    G=terrain.internal.HeightTransformation.GeoidHeightInterpolant;

    if nargin==1

        latlonv=varargin{1};
        validateattributes(latlonv,{'cell'},{'size',[1,2]})
        latv=latlonv{1};
        lonv=latlonv{2};
        validateattributes(latv,{'numeric'},{'real','nonsparse','vector','increasing'})
        validateattributes(lonv,{'numeric'},{'real','nonsparse','vector','increasing'})

        N=double(G({min(max(latv,-90),90),mod(lonv,360)}));
    else

        lat=varargin{1};
        lon=varargin{2};
        validateattributes(lat,{'numeric'},{'real','nonsparse'})
        validateattributes(lon,{'numeric'},{'real','nonsparse','size',size(lat)})


        N=zeros(size(lat));
        N(:)=double(G(min(max(lat(:),-90),90),mod(lon(:),360)));
    end
end