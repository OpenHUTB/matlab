classdef hdlregister<hgsetget







    properties
input
output
clock
clock_enable
phases
phasemax

    end

    methods

        function this=hdlregister(varargin)
            prop=varargin(1:2:end-1);
            val=varargin(2:2:end);
            set(this,prop,val);

        end
    end

end


