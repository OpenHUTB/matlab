classdef SDP4<matlabshared.orbit.internal.GeneralPerturbations %#codegen





    methods
        function propagator=SDP4(varargin)


            coder.allowpcode('plain');


            propagator@matlabshared.orbit.internal.GeneralPerturbations(varargin{:});
        end
    end

    methods(Static)
        [position,velocity]=propagate(tleData,time)
        [position,velocity]=cg_propagate(tleStruct,time)
    end
end


