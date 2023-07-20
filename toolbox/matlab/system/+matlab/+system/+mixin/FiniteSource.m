classdef FiniteSource<handle














%#codegen
%#ok<*EMCLS>

    methods(Access=private,Static)
        function name=matlabCodegenRedirect(~)
            name='matlab.system.mixin.coder.FiniteSource';
        end
    end

    methods(Sealed)
        function status=isDone(obj)










            if~isLocked(obj)
                if getNumInputs(obj)>0
                    matlab.system.internal.error(...
                    'MATLAB:system:isDoneCallbyNonSource');
                end
                setup(obj);
                reset(obj);
            end
            status=isDoneImpl(obj);
        end
    end

    methods(Access=protected)

        function status=isDoneImpl(~)
            status=false;
        end
    end

    methods(Access=public,Static,Hidden)
        function eofport=isEOFPortAvailable(~)
            coder.allowpcode('plain');
            eofport=false;
        end
    end
end
