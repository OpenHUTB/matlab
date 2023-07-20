classdef GcompIP3<handle


    properties(SetAccess=protected)
IP3
    end

    methods
        function set.IP3(obj,newIP3)
            validateattributes(newIP3,{'numeric'},{'scalar','real','nonnan'},'','IP3')
            obj.IP3=newIP3;
        end
    end
end