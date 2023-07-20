classdef QRandGenerator<handle




    properties(Access=private)
        myState struct
prevState
    end

    properties(Dependent)
Offset
    end
    properties(GetAccess=public)


MAX_QRAND_DIMS
    end

    methods



        function obj=QRandGenerator(varargin)

            obj.prevState=globaloptim.internal.mexfiles.mx_computeQuasiRand();
            obj.MAX_QRAND_DIMS=obj.prevState.MaxDims;

            if(nargin==0)
                obj.myState=obj.prevState;
                obj.myState.Offset=0;
            else
                obj.myState=varargin{1};
            end
        end


        function delete(obj)

            globaloptim.internal.mexfiles.mx_computeQuasiRand(obj.prevState);
        end


        function set.Offset(obj,val)
            obj.myState.Offset=val;
            globaloptim.internal.mexfiles.mx_computeQuasiRand(obj.myState);
        end


        function pts=getPoints(~,npts,dims)











            pts=globaloptim.internal.mexfiles.mx_computeQuasiRand(npts,dims);



        end
    end
end
