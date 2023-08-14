classdef BasicHomMedium<em.wire.solver.BasicMedium
    properties
epsilon_r
mu_r
EMSolObj
    end
    properties(Constant=true)
        relTol=1e-3;
        absTol=1e-10;
        neighborR=5;
    end
    methods
        function obj=BasicHomMedium(epsilon_r,mu_r)
            obj.epsilon_r=epsilon_r;
            obj.mu_r=mu_r;
            obj.EMSolObj=em.wire.solver.EMSolution();
        end
        function lambda0=Lambda0(obj,freqs)
            lambda0=obj.c0./freqs;
        end
        function lambda=Lambda(obj,freqs)
            lambda=(obj.c0/sqrt(obj.epsilon_r*obj.mu_r))./freqs;
        end
        function waveNumber=WaveNumber(obj,freqs)
            waveNumber=(2*pi*freqs/obj.c0)*sqrt(obj.epsilon_r*obj.mu_r);
        end

        function PmV=CalcSegECoeffs(obj,rp_,Up,rsm_,Um,hm_,omV,...
            a_,nR,freqs)



            PmV=em.wire.solver.CalcSegECoeffsImpl(rp_.',Up.',...
            rsm_.',Um.',hm_,int16(omV(end)),a_,...
            nR<obj.neighborR,obj.epsilon_r*obj.mu_r,freqs);
        end

        function ECoeffs=CalcSegEFullCoeffs(obj,rp_,rsm_,Um,hm_,...
            omV,a_,nR,freq)





            ECoeffs=em.wire.solver.CalcSegEFullCoeffsImpl(...
            rp_.',rsm_.',Um.',hm_,int16(omV(end)),a_,...
            nR<obj.neighborR,obj.epsilon_r,obj.mu_r,freq);
        end

        function HCoeffs=CalcSegHFullCoeffs(obj,rp_,rsm_,Um,hm_,...
            omV,a_,nR,freq)





            HCoeffs=em.wire.solver.CalcSegHFullCoeffsImpl(...
            rp_.',rsm_.',Um.',hm_,int16(omV(end)),a_,...
            nR<obj.neighborR,obj.epsilon_r,obj.mu_r,freq);
        end
    end
end