classdef SGP4<matlabshared.orbit.internal.GeneralPerturbations %#codegen





    methods
        function propagator=SGP4(varargin)


            coder.allowpcode('plain');


            propagator@matlabshared.orbit.internal.GeneralPerturbations(varargin{:});
        end
    end

    methods(Static)
        [position,velocity]=propagate(tleData,time)
        [position,velocity]=propagate_mex(tleStruct,time)
    end
end


