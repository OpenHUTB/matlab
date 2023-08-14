classdef Equation<hgsetget









    properties
        lhs='';
        rhs='';
        operator='=';
        units='';
    end

    methods
        function out=toString(h)
            out=([h.lhs,' ',h.operator,' ',h.rhs]);
            if~isempty(h.units)
                out=[out,' ',h.units];
            end
        end
        function disp(h)
            for i=1:numel(h)
                fprintf('%s\n',toString(h(i)));
            end
        end
    end

end

