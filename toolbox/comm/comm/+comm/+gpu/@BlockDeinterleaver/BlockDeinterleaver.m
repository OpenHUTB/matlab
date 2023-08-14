classdef(StrictDefaults)BlockDeinterleaver<comm.gpu.internal.InterleaverBase








































































    properties(Nontunable=true)


        PermutationVectorSource='Property';






        PermutationVector=(5:-1:1)';
    end

    properties(Constant,Hidden)
        PermutationVectorSourceSet=matlab.system.StringSet({'Property'});
    end


    methods
        function obj=BlockDeinterleaver(varargin)
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
            y(obj.PermutationVector)=(1:numel(obj.PermutationVector))';
        end
    end

end





