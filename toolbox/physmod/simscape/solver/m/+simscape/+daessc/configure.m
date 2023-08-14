function out=configure(varargin)

































    persistent OPTIONS;

    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if slfeature('EnableDAESSC')==0
        out=[];
        return
    end

    if isempty(OPTIONS)
        OPTIONS=local_defaults();
    end

    if(nargin==1)
        if isempty(varargin{1})

            OPTIONS=local_defaults();
        elseif isstruct(varargin{1})

            OPTIONS=varargin{1};
        else



            conf=local_configuration(varargin{1});
            switch conf
            case 'FAST'
                OPTIONS=local_fast(OPTIONS);
            case{'BALANCED','AUTO'}

                OPTIONS=local_balanced(OPTIONS);
            case 'ROBUST'
                OPTIONS=local_robust(OPTIONS);
            case 'QUICK_DEBUG'
                OPTIONS=local_quick_debug(OPTIONS);
            case 'FULL_DEBUG'
                OPTIONS=local_full_debug(OPTIONS);
            case{'MANUAL'}

            otherwise
                assert(false)
            end
        end
    else

        for i=1:2:length(varargin)
            OPTIONS=local_set(OPTIONS,varargin{i:i+1});
        end
    end
    out=OPTIONS;
end

function s=local_set(s,f,v)
    assert(isfield(s,f));
    s.(f)=v;
end

function opts=local_defaults()
    defaults={


    'NewtonMaxIter',12
    'NewtonMaxProbe',1





    'NewtonXtolFactor',1e-2
    'NewtonFtolFactor',1e-1


    'NewtonJacobianRelTol',0.5
    'NewtonJacobianAbsTol',sqrt(eps)
    'NewtonJacobianVerify',1


    'NewtonJacobianExcludeDiffEqns',true

    'NewtonJacobianExcludeDiffVars',true












    'RetainJacobianSteps',1e9
    'RetainJacobianIters',1e9


    'UseMvJacobian',0
    }';
    opts=struct(defaults{:});
end

function conf=local_configuration(in)
    u=upper(in);
    if contains(u,'AUTO')
        conf='AUTO';
        return
    end
    if contains(u,'FAST')
        conf='FAST';
        return
    end
    if contains(u,'BALANCED')
        conf='BALANCED';
        return
    end
    if contains(u,'ROBUST')
        conf='ROBUST';
        return
    end
    if contains(u,'QUICK')&&contains(u,'DEBUG')
        conf='QUICK_DEBUG';
        return
    end
    if contains(u,'FULL')&&contains(u,'DEBUG')
        conf='FULL_DEBUG';
        return
    end
    if contains(u,'MANUAL')
        conf='MANUAL';
        return
    end

    assert(false,sprintf('Unsupported configuration: ''%s''',in))
end

function opts=local_fast(in)
    opts=in;
    opts=local_set(opts,'NewtonJacobianVerify',0);
    opts=local_set(opts,'NewtonJacobianExcludeDiffEqns',false);
    opts=local_set(opts,'NewtonJacobianExcludeDiffVars',false);
    opts=local_set(opts,'RetainJacobianSteps',1e9);
    opts=local_set(opts,'RetainJacobianIters',1e9);
end

function opts=local_balanced(in)
    opts=in;
    opts=local_set(opts,'NewtonJacobianVerify',1);
    opts=local_set(opts,'NewtonJacobianExcludeDiffEqns',true);
    opts=local_set(opts,'NewtonJacobianExcludeDiffVars',true);
    opts=local_set(opts,'RetainJacobianSteps',1e9);
    opts=local_set(opts,'RetainJacobianIters',1e9);
end

function opts=local_robust(in)
    opts=in;
    opts=local_set(opts,'NewtonJacobianVerify',1);
    opts=local_set(opts,'NewtonJacobianExcludeDiffEqns',false);
    opts=local_set(opts,'NewtonJacobianExcludeDiffVars',false);
    opts=local_set(opts,'RetainJacobianSteps',1e9);
    opts=local_set(opts,'RetainJacobianIters',1e9);
end

function opts=local_quick_debug(in)
    opts=in;
    opts=local_set(opts,'NewtonJacobianVerify',0);
    opts=local_set(opts,'NewtonJacobianExcludeDiffEqns',false);
    opts=local_set(opts,'NewtonJacobianExcludeDiffVars',false);
    opts=local_set(opts,'RetainJacobianSteps',0);
    opts=local_set(opts,'RetainJacobianIters',1e9);
end

function opts=local_full_debug(in)
    opts=in;
    opts=local_set(opts,'NewtonJacobianVerify',0);
    opts=local_set(opts,'NewtonJacobianExcludeDiffEqns',false);
    opts=local_set(opts,'NewtonJacobianExcludeDiffVars',false);
    opts=local_set(opts,'RetainJacobianSteps',1e9);
    opts=local_set(opts,'RetainJacobianIters',0);
end
