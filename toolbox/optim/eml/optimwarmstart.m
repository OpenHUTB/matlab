function ws=optimwarmstart(x0,options,varargin)



























%#codegen

    coder.allowpcode('plain');

    validateattributes(x0,{'double'},{'nonempty'});
    validateattributes(options,{'struct'},{'scalar'});

    coder.internal.prefer_const(x0,options,varargin{:});


    coder.internal.errorIf(~isfield(options,'SolverName'),'optimlib:warmstart:InvalidOptionsType');




    poptions=struct(...
    'CaseSensitivity',false,...
    'PartialMatching','unique',...
    'StructExpand',false,...
    'IgnoreNulls',true);


    params={'MaxLinearEqualities';'MaxLinearInequalities'};
    pstruct=struct();
    ZERO=zeros('uint32');
    for k=coder.unroll(1:numel(params))
        pstruct.(params{k})=ZERO;
    end

    pstruct=coder.internal.parseParameterInputs(pstruct,poptions,varargin{:});

    wsoptions=optim.coder.warmstart.createWarmStartOptions();
    if nargin>2
        wsoptions=getParamArgs(options.SolverName,wsoptions,pstruct,params,varargin{:});
    end




    coder.internal.errorIf(strcmpi(eml_option('UseMalloc'),'Off')&&wsoptions.MaxLinearEqualities<0,...
    'optim_codegen:warmstart:StaticMemoryMaxLinEqUnset');

    coder.internal.errorIf(strcmpi(eml_option('UseMalloc'),'Off')&&wsoptions.MaxLinearInequalities<0,...
    'optim_codegen:warmstart:StaticMemoryMaxLinIneqUnset');




    supportedSolvers=coder.const(['quadprog',newline,...
    ' lsqlin']);
    supportedAlgorithms='active-set';
    switch coder.const(options.SolverName)
    case 'quadprog'
        coder.internal.assert(strcmpi(options.Algorithm,supportedAlgorithms),'optimlib:warmstart:UnsupportedAlgorithm',options.SolverName,options.Algorithm,supportedAlgorithms);
        ws=optim.coder.warmstart.QuadprogWarmStart(x0,options,wsoptions);
    case 'lsqlin'
        coder.internal.assert(strcmpi(options.Algorithm,supportedAlgorithms),'optimlib:warmstart:UnsupportedAlgorithm',options.SolverName,options.Algorithm,supportedAlgorithms);
        ws=optim.coder.warmstart.LsqlinWarmStart(x0,options,wsoptions);
    otherwise
        coder.internal.assert(false,'optimlib:warmstart:SolverUnsupported',supportedSolvers);
    end

end


function wsoptions=getParamArgs(solver,wsoptions,pstruct,params,varargin)


    coder.inline('always');
    coder.internal.prefer_const(solver,params,varargin{:});
    for k=coder.unroll(1:numel(params))

        name=params{k};
        wsoptions.(name)=getCheckParam(solver,pstruct,name,wsoptions,varargin{:});
    end

end


function val=getCheckParam(solver,pstruct,name,wsoptions,varargin)


    coder.inline('always');
    coder.internal.prefer_const(solver,pstruct,varargin{:});
    tVal=coder.internal.getParameterValue(pstruct.(name),[],varargin{:});
    if ischar(tVal)
        val=lower(deblank(tVal));
    elseif isstring(tVal)&&isscalar(tVal)
        val=lower(deblank(char(tVal)));
    else
        val=tVal;
    end

    if isempty(val)
        val=wsoptions.(name);
    else
        val=checkParam(solver,val,name);
    end

end


function val=checkParam(solver,val,name)



    if coder.const(strcmpi(solver,'quadprog'))||coder.const(strcmpi(solver,'lsqlin'))
        val=optim.coder.warmstart.checkWarmStartParam(val,name);
    end

end

