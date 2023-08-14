classdef rfelliptic<rf.internal.filter.RFFilter

    methods
        designData=filt_design_lc(obj)
    end

    methods
        function obj=rfelliptic(varargin)
            obj=obj@rf.internal.filter.RFFilter(varargin{:});
        end

        function filt_exact(~,~)
        end
    end
end