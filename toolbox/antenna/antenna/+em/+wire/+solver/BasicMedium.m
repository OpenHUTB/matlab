classdef(Abstract)BasicMedium<matlab.mixin.SetGet
    properties(Constant)
        epsilon0=8.854e-12;
        mu0=4*pi*1e-7;
        c0=1/sqrt(em.wire.solver.BasicMedium.epsilon0*em.wire.solver.BasicMedium.mu0);
    end
    properties(Abstract)



epsilon_r
mu_r
EMSolObj
    end
    methods(Abstract)
        Lambda(obj,freqs)
        WaveNumber(obj,freqs)
        CalcSegECoeffs(obj,rp_,Up,rsm_,Um,hm_,om,a_,nR,freqs)
        CalcSegEFullCoeffs(obj,rp_,rsm_,Um,hm_,omV,a_,nR,freqs)
        CalcSegHFullCoeffs(obj,rp_,rsm_,Um,hm_,omV,a_,nR,freqs)
    end
    methods
        function parts=allWireParts(obj)
            parts=obj.EMSolObj.allWireParts;
        end

        function parts=allScWireParts(obj)
            parts=obj.EMSolObj.allScWireParts;
        end

        function parts=allExWireParts(obj)
            parts=obj.EMSolObj.allExWireParts;
        end

        function res=Es(obj,varargin)
            res=obj.EMSolObj.Es(varargin{:});
        end

        function res=Ei(obj,varargin)
            SolverEiArgs={varargin{1},obj,varargin{2:end}};
            res=obj.EMSolObj.Ei(SolverEiArgs{:});
        end

        function res=Et(obj,varargin)
            SolverEiArgs={varargin{1},obj,varargin{2:end}};
            res=obj.EMSolObj.Et(SolverEiArgs{:});
        end

        function res=Hs(obj,varargin)
            res=obj.EMSolObj.Hs(varargin{:});
        end

        function res=Solve(obj,varargin)
            res=obj.EMSolObj.Solve(varargin{:});
        end

    end
end