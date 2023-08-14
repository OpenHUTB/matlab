function options=optimoptions(solver,varargin)






























%#codegen

    coder.allowpcode('plain');


    coder.internal.prefer_const(solver,varargin);
    coder.internal.assert(coder.internal.isConst(solver),...
    'Coder:toolbox:InputMustBeConstant','solver');

    optionsPassedIn=coder.const(isstruct(solver));

    if optionsPassedIn

        solverName=solver.SolverName;
    elseif isa(solver,'function_handle')
        solverName=func2str(solver);
    elseif coder.internal.isTextRow(solver)&&~isempty(solver)
        solverName=char(solver);
    else

        coder.internal.assert(false,...
        'optimlib_codegen:optimoptions:SolverMustBeStringOrFcnHandle');
    end

    if strcmpi(solverName,'fmincon')||...
        strcmpi(solverName,'quadprog')||strcmpi(solverName,'lsqlin')||...
        strcmpi(solverName,'lsqnonlin')||strcmpi(solverName,'fsolve')||...
        strcmpi(solverName,'lsqcurvefit')
        opts=optim.coder.options.solverOptions(solverName);
    elseif optionsPassedIn
        opts=checkStruct(solver);
    else

        coder.internal.assert(false,...
        'optimlib_codegen:optimoptions:InvalidSolver',solverName);
    end


    if nargin>1


        poptions=struct(...
        'CaseSensitivity',false,...
        'PartialMatching','unique',...
        'StructExpand',false,...
        'IgnoreNulls',true);


        params=fieldnames(opts);
        pstruct=struct();
        ZERO=zeros('uint32');
        for k=coder.unroll(1:numel(params))
            pstruct.(params{k})=ZERO;
        end

        pstruct=coder.internal.parseParameterInputs(pstruct,poptions,varargin{:});
        if nargin>2&&coder.internal.isCharOrScalarString(varargin{1})



            options=getParamArgs(solverName,pstruct,params,opts,varargin{:});
        elseif optionsPassedIn

            for k=coder.unroll(1:numel(params))
                name=params{k};
                if paramFound(pstruct,name)

                    options.(name)=getCheckParam(solverName,pstruct,name,opts,varargin{:});
                elseif isfield(opts,name)

                    options.(name)=checkParam(solverName,opts.(name),name);
                else


                    options.(name)=[];
                end
            end
        end
    else
        options=opts;
    end

end



function opts=getParamArgs(solver,pstruct,params,options,varargin)


    coder.inline('always');
    coder.internal.prefer_const(solver,params,varargin);
    for k=coder.unroll(1:numel(params))

        name=params{k};
        opts.(name)=getCheckParam(solver,pstruct,name,options,varargin{:});
    end

end


function val=getCheckParam(solver,pstruct,name,options,varargin)


    coder.inline('always');
    coder.internal.prefer_const(solver,name,pstruct);
    tVal=coder.internal.getParameterValue(pstruct.(name),[],varargin{:});
    if ischar(tVal)
        val=lower(deblank(tVal));
    elseif isstring(tVal)&&isscalar(tVal)
        val=lower(deblank(char(tVal)));
    else
        val=tVal;
    end

    if isempty(val)
        val=options.(name);
    else
        val=checkParam(solver,val,name);
    end

end


function val=checkParam(solver,val,name)



    coder.internal.prefer_const(solver);

    coder.internal.assert(coder.internal.isConst(val),...
    'optimlib_codegen:optimoptions:OptionValueNotConstant',...
    name,...
    'IfNotConst','Fail');

    if coder.const(strcmpi(solver,'fmincon'))
        val=optim.coder.options.checkFminconParam(val,name);
    elseif coder.const(strcmpi(solver,'quadprog'))||coder.const(strcmpi(solver,'lsqlin'))
        val=optim.coder.options.checkQuadprogParam(val,name);
    else
        val=optim.coder.options.checkLevenbergMarquardtParam(val,name,solver);

    end

end


function p=paramFound(params,name)


    coder.inline('always');
    idx=params.(name);
    p=idx>zeros('like',idx);
end


function opt=checkStruct(opt)



    coder.inline('always');
    p=fieldnames(opt);
    for k=coder.unroll(1:numel(p))
        coder.internal.assert(coder.internal.isConst(opt.(p{k})),...
        'optimlib_codegen:optimoptions:OptionValueNotConstant',...
        p{k},'IfNotConst','Fail');
    end
end
