function out=options(varargin)





































    persistent OPTIONS;


    reset_options=(nargin==1)&&isempty(varargin{1});

    if isempty(OPTIONS)||reset_options
        defaults={


        'NewtonMaxIter',12
        'NewtonMaxProbe',1





        'NewtonXtolFactor',1e-3
        'NewtonFtolFactor',1e-2


        'NewtonJacobianRelTol',inf
        'NewtonJacobianAbsTol',inf
        'NewtonJacobianVerify',0


        'NewtonJacobianExcludeDiffEqns',false

        'NewtonJacobianExcludeDiffVars',false












        'RetainJacobianSteps',0
        'RetainJacobianIters',0


        'MaxOrder12',2


        'UseBDF',false




        'ErrorControl2vs1',false


        'SaveStepStats',0


        'UseMvJacobian',false


        }';
        OPTIONS=struct(defaults{:});
    end

    if~reset_options
        for i=1:2:length(varargin)
            assert(isfield(OPTIONS,varargin{i}));
            OPTIONS.(varargin{i})=varargin{i+1};
        end
    end

    out=OPTIONS;

end
