classdef FiniteSource<handle




%#codegen
%#ok<*EMCLS>

    methods(Sealed)
        function status=isDone(obj)

            if~isLocked(obj)
                if getNumInputs(obj)>0
                    matlab.system.internal.error(...
                    'MATLAB:system:isDoneCallbyNonSource');
                end
                setupAndReset(obj);
            end
            status=isDoneImpl(obj);
        end
    end

    methods(Access=protected)

        function status=isDoneImpl(~)
            status=false;
        end
    end

    methods(Access=public)
        function obj=FiniteSource
            coder.allowpcode('plain');
        end
    end

end
