



classdef IdObject<matlab.mixin.Copyable&matlab.mixin.Heterogeneous


    properties
        Id uint32=0
    end


    methods




        function this=IdObject(id)


            narginchk(0,1);
            if nargin==1
                validateattributes(id,{'numeric'},{'scalar','nonempty'},1);
                this.Id=id;
            end
        end
    end
end
