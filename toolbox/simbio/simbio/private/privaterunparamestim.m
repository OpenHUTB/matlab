function[knew,result]=privaterunparamestim(pe_info)




























    transaction=SimBiology.Transaction.create(pe_info.model);%#ok<NASGU>            



    configset=pe_info.model.getconfigset('active');

    userConfigset.OutputTimes=configset.SolverOptions.OutputTimes;
    userConfigset.STL=configset.RuntimeOptions.StatesToLog;
    userConfigset.SA=configset.SolverOptions.SensitivityAnalysis;

    configset.RuntimeOptions.StatesToLog=pe_info.observed;



    pe_info.ttargetstartsat0=(pe_info.ttarget(1)==0.0);
    if pe_info.ttargetstartsat0


        configset.SolverOptions.OutputTimes=pe_info.ttarget(:);
    else



        configset.SolverOptions.OutputTimes=[0.0;pe_info.ttarget(:)];
    end


    configset.SolverOptions.SensitivityAnalysis=false;
    if userConfigset.SA

        warning(message('SimBiology:sbioparamestim:TURNING_OFF_SENSITIVITY'));
    end


    localCommitActiveVariants(pe_info.model);


    doses=pe_info.model.getdose;
    activeDoses=findobj(doses,'Active',true);


    exportedModel=pe_info.model.export(pe_info.estimated,activeDoses);




    exportedModel=localAccelerateModel(exportedModel);
    if useParallelEnabled(pe_info.optimoptions)
        parfor i=1:1
            exportedModel(i)=localAccelerateModel(exportedModel(i));
        end
    end
    exportedDoses=exportedModel.getdose;


    k0=pe_info.k0;
    if isempty(k0)
        k0=zeros(size(pe_info.estimated));
        for i=1:numel(k0)
            estObj=pe_info.estimated(i);
            if isa(estObj,'SimBiology.Species')
                k0(i)=estObj.InitialAmount;
            elseif isa(estObj,'SimBiology.Parameter')
                k0(i)=estObj.Value;
            elseif isa(estObj,'SimBiology.Compartment')
                k0(i)=estObj.Capacity;
            end
        end
    end


    try
        [~,~]=simulate(exportedModel,k0,exportedModel.getdose);
    catch originalException
        newException=MException(message('SimBiology:sbioparamestim:INITIAL_SIMULATION_ERROR'));
        newException=newException.addCause(originalException);
        throw(newException);
    end


    lb=zeros(size(k0));
    ub=[];

    switch pe_info.method
    case 'fminsearch'
        computeNorm=true;
        objfcn=createObjectiveFunctionHandle(computeNorm,exportedModel,exportedDoses,pe_info.ttargetstartsat0,pe_info.xtarget);
        optDefault=localFminsearchDefaults(objfcn(k0));
        opt=SimBiology.fit.internal.updateOptionsWithDefaults(pe_info.optimoptions,optDefault,pe_info.method);
        [knew,fval,exitflag,output]=...
        fminsearch(objfcn,k0,opt);
        result.fval=fval;
        result.exitflag=exitflag;
        result.iterations=output.iterations;
        result.funccount=output.funcCount;

    case{'lsqcurvefit','lsqnonlin'}
        computeNorm=false;
        objfcn=createObjectiveFunctionHandle(computeNorm,exportedModel,exportedDoses,pe_info.ttargetstartsat0,pe_info.xtarget);
        optDefault=localLsqnonlinDefaults(objfcn(k0),configset.SolverOptions.RelativeTolerance,k0);
        opt=SimBiology.fit.internal.updateOptionsWithDefaults(pe_info.optimoptions,optDefault,'lsqnonlin');


        [knew,resnorm,residual,exitflag,output]=...
        lsqnonlin(objfcn,k0,lb,ub,opt);
        result.fval=resnorm;
        result.residual=residual;
        result.exitflag=exitflag;
        result.iterations=output.iterations;
        result.funccount=output.funcCount;
        result.algorithm=output.algorithm;
        result.message=output.message;

    case 'fmincon'
        computeNorm=true;
        objfcn=createObjectiveFunctionHandle(computeNorm,exportedModel,exportedDoses,pe_info.ttargetstartsat0,pe_info.xtarget);
        optDefault=localFminconDefaults(objfcn(k0),configset.SolverOptions.RelativeTolerance,k0);
        opt=SimBiology.fit.internal.updateOptionsWithDefaults(pe_info.optimoptions,optDefault,pe_info.method);

        [knew,fval,exitflag,output]=...
        fmincon(objfcn,k0,[],[],[],[],lb,ub,[],opt);
        result.fval=fval;
        result.exitflag=exitflag;
        result.iterations=output.iterations;
        result.funccount=output.funcCount;
        result.algorithm=output.algorithm;
        result.message=output.message;

    case 'patternsearch'
        computeNorm=true;
        objfcn=createObjectiveFunctionHandle(computeNorm,exportedModel,exportedDoses,pe_info.ttargetstartsat0,pe_info.xtarget);
        optDefault=localPatternSearchDefaults(objfcn(k0));
        opt=SimBiology.fit.internal.updateOptionsWithDefaults(pe_info.optimoptions,optDefault,pe_info.method);

        [knew,fval,exitflag,output]=...
        patternsearch(objfcn,k0,[],[],[],[],lb,ub,[],opt);
        result.fval=fval;
        result.exitflag=exitflag;
        result.iterations=output.iterations;
        result.funccount=output.funccount;
        result.problemtype=output.problemtype;
        result.pollmethod=output.pollmethod;
        result.message=output.message;

    case 'patternsearch_hybrid'
        computeNorm=true;
        objfcn=createObjectiveFunctionHandle(computeNorm,exportedModel,exportedDoses,pe_info.ttargetstartsat0,pe_info.xtarget);
        optDefault=localHybridPatternSearchDefaults(objfcn(k0));
        opt=SimBiology.fit.internal.updateOptionsWithDefaults(pe_info.optimoptions,optDefault,'patternsearch');

        [knew,fval,exitflag,output]=...
        patternsearch(objfcn,k0,[],[],[],[],lb,ub,[],opt);
        result.fval=fval;
        result.exitflag=exitflag;
        result.iterations=output.iterations;
        result.funccount=output.funccount;
        result.problemtype=output.problemtype;
        result.pollmethod=output.pollmethod;
        result.message=output.message;

    case 'particleswarm'
        computeNorm=true;
        objfcn=createObjectiveFunctionHandle(computeNorm,exportedModel,exportedDoses,pe_info.ttargetstartsat0,pe_info.xtarget);
        optDefault=localParticleswarmDefaults(objfcn(k0),k0);
        opt=SimBiology.fit.internal.updateOptionsWithDefaults(pe_info.optimoptions,optDefault,pe_info.method);

        [knew,fval,exitflag,output]=...
        particleswarm(objfcn,length(k0),lb,ub,opt);
        knew=knew(:);
        result.fval=fval;
        result.exitflag=exitflag;
        result.iterations=output.iterations;
        result.funccount=output.funccount;
        result.message=output.message;

    case 'particleswarm_hybrid'
        computeNorm=true;
        objfcn=createObjectiveFunctionHandle(computeNorm,exportedModel,exportedDoses,pe_info.ttargetstartsat0,pe_info.xtarget);
        optDefault=localHybridParticleswarmDefaults(objfcn(k0),k0,configset.SolverOptions.RelativeTolerance);
        opt=SimBiology.fit.internal.updateOptionsWithDefaults(pe_info.optimoptions,optDefault,'particleswarm');

        [knew,fval,exitflag,output]=...
        particleswarm(objfcn,length(k0),lb,ub,opt);
        knew=knew(:);
        result.fval=fval;
        result.exitflag=exitflag;
        result.iterations=output.iterations;
        result.funccount=output.funccount;
        result.message=output.message;

    case 'ga'
        computeNorm=true;
        objfcn=createObjectiveFunctionHandle(computeNorm,exportedModel,exportedDoses,pe_info.ttargetstartsat0,pe_info.xtarget);
        optDefault=localGaDefaults(objfcn(k0));
        opt=SimBiology.fit.internal.updateOptionsWithDefaults(pe_info.optimoptions,optDefault,pe_info.method);

        [knew,fval,exitflag,output]=...
        ga(objfcn,length(k0),[],[],[],[],lb,ub,[],opt);
        knew=knew(:);
        result.fval=fval;
        result.exitflag=exitflag;
        result.generations=output.generations;
        result.funccount=output.funccount;
        result.message=output.message;

    case 'ga_hybrid'
        computeNorm=true;
        objfcn=createObjectiveFunctionHandle(computeNorm,exportedModel,exportedDoses,pe_info.ttargetstartsat0,pe_info.xtarget);
        optDefault=localHybridGaDefaults(objfcn(k0),configset.SolverOptions.RelativeTolerance,k0);
        opt=SimBiology.fit.internal.updateOptionsWithDefaults(pe_info.optimoptions,optDefault,'ga');

        [knew,fval,exitflag,output]=...
        ga(objfcn,length(k0),[],[],[],[],lb,ub,[],opt);
        knew=knew(:);
        result.fval=fval;
        result.exitflag=exitflag;
        result.generations=output.generations;
        result.funccount=output.funccount;
        result.message=output.message;

    otherwise

    end


    function fh=createObjectiveFunctionHandle(computeNorm,exportedModel,exportedDoses,ttargetstartsat0,xtarget)


        if computeNorm
            fh=@(k)localNormSimErrorFunc(k,exportedModel,exportedDoses,ttargetstartsat0,xtarget);
        else
            fh=@(k)localSimErrorFunc(k,exportedModel,exportedDoses,ttargetstartsat0,xtarget);
        end


        function F=localNormSimErrorFunc(k,exportedModel,exportedDoses,ttargetstartsat0,xtarget)
            F=localSimErrorFunc(k,exportedModel,exportedDoses,ttargetstartsat0,xtarget);
            F=norm(reshape(F,1,[]));


            function F=localSimErrorFunc(k,exportedModel,exportedDoses,ttargetstartsat0,xtarget)

                try
                    [~,x]=simulate(exportedModel,k,exportedDoses);
                    if~ttargetstartsat0


                        x=x(2:end,:);
                    end


                    if size(x,1)~=size(xtarget,1)
                        error(message('SimBiology:sbiofit:INVALID_RESULT'));
                    end
                    F=x-xtarget;
                catch ME %#ok<NASGU>

                    F=inf(size(xtarget));
                    return
                end

                function exportedModel=localAccelerateModel(exportedModel)

                    if SimBiology.internal.isMexSetupInvalid
                        warning(message('SimBiology:CodeGeneration:InvalidMexCompilerFitting'));
                    else
                        accelerate(exportedModel);
                    end

                    function localCommitActiveVariants(model)
                        variants=model.getvariant;


                        for i=numel(variants):-1:1
                            if~variants(i).Active
                                variants(i)=[];
                            end
                        end
                        if isempty(variants)

                            return
                        end


                        for i=1:numel(variants)

                            commit(variants(i),model);
                        end




                        function opts=localCommonDefaults(opts,f0)


                            opts.Display='off';
                            opts.FunctionTolerance=1e-6*f0;

                            function opts=localFminsearchDefaults(f0)


                                opts.Display='off';
                                opts.TolFun=1e-6*f0;

                                function opts=localLsqnonlinDefaults(initialResiduals,relativeTolerance,initialEstimates)

                                    opts=optimoptions('lsqnonlin');
                                    f0=sum(initialResiduals(:).^2);
                                    opts=localCommonDefaults(opts,f0);


                                    opts.FiniteDifferenceStepSize=max(eps^(1/3),relativeTolerance);


                                    opts.TypicalX=1e-6*initialEstimates;

                                    function opts=localFminconDefaults(f0,relativeTolerance,initialEstimates)
                                        opts=optimoptions('fmincon');
                                        opts=localCommonDefaults(opts,f0);
                                        opts.Algorithm='interior-point';


                                        opts.FiniteDifferenceStepSize=max(eps^(1/3),relativeTolerance);


                                        opts.TypicalX=1e-6*initialEstimates;

                                        function opts=localPatternSearchDefaults(f0)
                                            opts=optimoptions('patternsearch');
                                            opts=localCommonDefaults(opts,f0);
                                            opts.MeshTolerance=1.0e-3;
                                            opts.AccelerateMesh=true;

                                            function opts=localHybridPatternSearchDefaults(f0)
                                                opts=localPatternSearchDefaults(f0);
                                                opts.SearchMethod={@searchlhs,10,15};

                                                function opts=localParticleswarmDefaults(f0,k0)%#ok<INUSL>
                                                    opts=optimoptions('particleswarm');
                                                    opts.InitialSwarmMatrix=k0(:)';
                                                    opts.SwarmSize=10;
                                                    opts.MaxIterations=30;

                                                    function opts=localHybridParticleswarmDefaults(f0,k0,relativeTolerance)
                                                        opts=localParticleswarmDefaults(f0,k0);
                                                        fminopt=localFminconDefaults(f0,relativeTolerance,k0);
                                                        opts.HybridFcn={@fmincon,fminopt};

                                                        function opts=localGaDefaults(f0)
                                                            opts=optimoptions('ga');
                                                            opts=localCommonDefaults(opts,f0);
                                                            opts.PopulationSize=10;
                                                            opts.Generations=30;
                                                            opts.MutationFcn=@mutationadaptfeasible;

                                                            function opts=localHybridGaDefaults(f0,relativeTolerance,initialEstimates)
                                                                opts=localGaDefaults(f0);
                                                                fminopt=localFminconDefaults(f0,relativeTolerance,initialEstimates);
                                                                opts.HybridFcn={@fmincon,fminopt};

                                                                function tf=useParallelEnabled(opts)
                                                                    try
                                                                        value=opts.UseParallel;
                                                                    catch
                                                                        value=[];
                                                                    end
                                                                    if(ischar(value)&&strcmp('always',value))||((isnumeric(value)||islogical(value))&&isscalar(value)&&(value==1))
                                                                        tf=true;
                                                                    else
                                                                        tf=false;
                                                                    end
