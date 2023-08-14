classdef(StrictDefaults)BlockInterleaver<comm.gpu.internal.InterleaverBase






































































    properties(Nontunable=true)


        PermutationVectorSource='Property';






        PermutationVector=(5:-1:1)';
    end

    properties(Constant,Hidden)
        PermutationVectorSourceSet=matlab.system.StringSet({'Property'});
    end

    methods
        function obj=BlockInterleaver(varargin)
            obj=obj@comm.gpu.internal.InterleaverBase(varargin);
            setProperties(obj,nargin,varargin{:},'PermutationVector');
        end

        function set.PermutationVector(obj,val)
            validatePermutationVector(obj,val);
            obj.PermutationVector=val;
        end

    end

    methods(Access=protected)
        function y=rhsPermVector(obj)
            y=obj.PermutationVector;
        end
    end

end





