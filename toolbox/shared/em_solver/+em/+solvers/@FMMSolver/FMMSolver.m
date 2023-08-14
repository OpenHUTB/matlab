classdef FMMSolver<matlab.mixin.SetGet&matlab.mixin.CustomDisplay&matlab.mixin.Copyable






    properties(SetObservable,AbortSet)
        Iterations(1,1)double{mustBeInteger,mustBePositive}=100
        RelativeResidual(1,1)double{mustBeGreaterThan(RelativeResidual,0),mustBeLessThan(RelativeResidual,1)}=1e-4
    end


    properties(SetObservable,AbortSet)
        Precision(1,1)double{mustBeGreaterThan(Precision,0),mustBeLessThan(Precision,1)}=2e-4
    end


    properties(Constant,Hidden)
        epsilon0=8.85418782e-012;
        mu0=1.25663706e-006;
        c0=em.internal.emConstants.c0;
        eta0=em.internal.emConstants.eta0;
    end

    properties(Hidden,SetObservable,AbortSet)
        IterativeSolver char{mustBeMember(IterativeSolver,{'gmres','bicgstab','cgs','tfqmr'})}='gmres'
    end

    properties(Hidden)

        Mesh(1,1)struct{isfield(Mesh,{'P','t'})}

I
IBasis
Preconditioner

Normals

        MaxDimInMesh(1,1)double{mustBeNumeric,mustBeFinite}


Geom

        WavePolarization(1,3)double{mustBeNumeric,mustBeFinite}

        WaveDirection(1,3)double{mustBeNumeric,mustBeFinite}

IEType

V_efie

LHSEfie

LHSMfie

RHS

I_mfie

NumRWG

Frequency

Wavenumber

ElemsPerWavelength

Matvec

ResidualVector

SolverCache

SelfIntegral

PropCheckCache
    end

    methods
        function f=FMMSolver(varargin)

            f.SolverCache=containers.Map('KeyType','double','ValueType','any');
        end
    end

    methods(Hidden)
        solvePlaneWave(obj,f,dir,pol)
        solveDrivenVoltage(obj,f,V)
    end

    methods(Access=protected)
        solve(obj,type)
        findElementsPerLambda(obj)
        generateBFNeighbors(obj)
        expandIncidentField(obj)
        generateLHSEfie(obj,I)
        generateLHSMfie(obj,I)
        cacheSolution(obj)
        parsecfieIterative(obj,argsin)
        CurrentCFIE=currentOnPatches(obj)
    end


    methods(Abstract,Hidden)
        generatePreconditioner(obj)
        generateRHS(obj)
        lhs=generateLHS(obj,I)
    end

    methods
        varargout=convergence(obj)
    end

    methods(Static,Access=protected)
        U=hfmm3d(prec,zk,srcinfo,pg,targ,pgt);
        [pot,ier]=wrapper_fmm3d(mex_id_,nd,eps,zk,ns,sources,charges,dipoles,pot,a,b,c,d,e,f,nss,nds,nsss,nd3,nssss,nddd,nsssss,in23,in24,in25,in26,in27,in28,in29,in30,in31,in32,in33,in34,in35,in36,in37);
    end
end

