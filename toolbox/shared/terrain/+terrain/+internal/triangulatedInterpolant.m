classdef triangulatedInterpolant




    properties(SetAccess=immutable)
LatitudeLimits
LongitudeLimits
Values
    end

    methods
        function obj=triangulatedInterpolant(gridVectors,v)




            validateattributes(gridVectors,{'cell'},{'size',[1,2]})
            latv=gridVectors{1};
            lonv=gridVectors{2};
            validateattributes(latv,{'numeric'},{'real','finite','nonsparse','vector','increasing'})
            validateattributes(lonv,{'numeric'},{'real','finite','nonsparse','vector','increasing'})
            obj.LatitudeLimits=[latv(1),latv(end)];
            obj.LongitudeLimits=[lonv(1),lonv(end)];


            obj.Values=v;
            validateattributes(v,{'numeric'},{'real','finite','nonsparse','size',[numel(latv),numel(lonv)]});
        end

        function varargout=subsref(obj,s)






            switch s(1).type
            case '()'
                if isscalar(s)



                    ind=s.subs;
                    latq=ind{1};
                    lonq=ind{2};
                    validateattributes(latq,{'numeric'},{'real','nonsparse','vector'})
                    validateattributes(lonq,{'numeric'},{'real','nonsparse','vector','size',size(latq)})


                    Vq=nan(size(latq));
                    nn=~isnan(latq);
                    Vq(nn)=obj.interpolate(latq(nn),lonq(nn));

                    varargout={Vq};
                else
                    [varargout{1:nargout}]=builtin('subsref',obj,s);
                end
            otherwise
                [varargout{1:nargout}]=builtin('subsref',obj,s);
            end
        end
    end

    methods(Access=private)
        function Vq=interpolate(obj,latq,lonq)



            V=obj.Values;
            gridSize=size(V);
            latlim=obj.LatitudeLimits;
            lonlim=obj.LongitudeLimits;









            numlat=gridSize(1);
            numlon=gridSize(2);
            latrange=latlim(end)-latlim(1);
            lonrange=lonlim(end)-lonlim(1);
            fromSouth=1+max(0,min(latrange,latq-latlim(1)))*(numlat-1)/latrange;
            fromWest=1+max(0,min(lonrange,lonq-lonlim(1)))*(numlon-1)/lonrange;
            southSubscript=min(numlat-1,floor(fromSouth));
            westSubscript=min(numlon-1,floor(fromWest));



            westIndOffset=(westSubscript-1).*numlat;
            eastIndOffset=westIndOffset+numlat;
            southwestHeight=V(southSubscript+westIndOffset);
            southeastHeight=V(southSubscript+eastIndOffset);
            northwestHeight=V(southSubscript+1+westIndOffset);
            northeastHeight=V(southSubscript+1+eastIndOffset);




            dX=fromWest-westSubscript;
            dY=fromSouth-southSubscript;
            Vq=nan(size(latq));
            lowerTri=(dY<dX);
            Vq(lowerTri)=southwestHeight(lowerTri)+...
            (dX(lowerTri).*(southeastHeight(lowerTri)-southwestHeight(lowerTri)))+...
            (dY(lowerTri).*(northeastHeight(lowerTri)-southeastHeight(lowerTri)));
            Vq(~lowerTri)=southwestHeight(~lowerTri)+...
            (dX(~lowerTri).*(northeastHeight(~lowerTri)-northwestHeight(~lowerTri)))+...
            (dY(~lowerTri).*(northwestHeight(~lowerTri)-southwestHeight(~lowerTri)));
        end
    end
end
