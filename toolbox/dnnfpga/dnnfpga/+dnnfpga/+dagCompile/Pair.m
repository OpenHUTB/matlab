




classdef Pair<handle

    properties
i
j
value
    end

    methods
        function obj=Pair(i,j,value)
            if nargin>=3
                obj.i=uint32(min(i,j));
                obj.j=uint32(max(i,j));
                obj.value=uint32(value);
            end
        end

    end


end