function[x,fval,exitFlag,output,population,scores]=gapenalty(...
    FitnessFcn,nvars,Aineq,bineq,Aeq,beq,lb,ub,...
    NonconFcn,options,output,Iterate,subtype)













    isMINLP=~isempty(options.LinearConstr.IntegerVars);



    if~isMINLP
        problem=i_initialize(FitnessFcn,nvars,zeros(0,nvars),zeros(0,1),...
        lb,ub,NonconFcn,Iterate,options);
    else

        problem=i_initialize(FitnessFcn,nvars,Aineq,bineq,lb,ub,...
        NonconFcn,Iterate,options);



        Aineq=zeros(0,nvars);
        bineq=zeros(0,1);
        Aeq=zeros(0,nvars);
        beq=zeros(0,1);
    end

    problem.options.isMINLP=isMINLP;



    problem=i_displayAndPlot(problem);




    Iterate.x=[];



    usePCT=~problem.options.UserVectorized&&~problem.options.SerialUserFcn;
    if~isempty(NonconFcn)
        constr_remote={'fun',[],NonconFcn};
    else
        constr_remote={[]};
    end


    ProblemdefOptions=options.ProblemdefOptions;
    alreadySet=ProblemdefOptions.FromSolve||~ProblemdefOptions.FunOnWorkers;
    cleanupObj=setOptimFcnHandleOnWorkers(usePCT,{'fun',[],FitnessFcn},constr_remote,alreadySet);


    if any(strcmp(subtype,{'boundconstraints','linearconstraints'}))
        [x,~,exitFlag,output,population,scores]=...
        galincon(problem.fitnessfcn,problem.nvars,Aineq,bineq,Aeq,beq,...
        problem.lb,problem.ub,problem.options,output,Iterate);
    elseif strcmp(subtype,'unconstrained')
        [x,~,exitFlag,output,population,scores]=...
        gaunc(problem.fitnessfcn,problem.nvars,problem.options,output,Iterate);
    end
    if isempty(x)

        fval=[];
        return;
    end

    [fval,exitFlag,output]=i_generateOutput(FitnessFcn,NonconFcn,...
    Aineq,bineq,Aeq,beq,problem,x,exitFlag,output);




    if options.Verbosity>0
        fprintf('%s\n',output.message);
    end
    delete(cleanupObj);


    function problem=i_initialize(FitnessFcn,nvars,...
        Aineq,bineq,lb,ub,NonconFcn,Iterate,options)



        problem=struct('fitnessfcn',FitnessFcn,'nvars',nvars,...
        'Aineq',Aineq,'bineq',bineq,'Aeq',zeros(0,nvars),'beq',zeros(0,1),...
        'lb',lb,'ub',ub,'nonlcon',NonconFcn,'intcon',[],'rngstate',[],...
        'solver','ga');

        if~isempty(NonconFcn)&&size(options.InitialScores,1)>0

            options.InitialScores=[];
        end



        problem.options=options;








        problem.options.UserVectorized=strcmpi(options.Vectorized,'on');
        problem.options.Vectorized='on';





        conScale=gaminlpconscale;


        if~isempty(NonconFcn)
            conScale.mIneq=numel(Iterate.cineq);
            conScale.mEq=numel(Iterate.ceq);
        else
            conScale.mIneq=0;
            conScale.mEq=0;
        end


        conScale.noConstrEvals=isempty(problem.nonlcon)&&isempty(problem.Aineq);


        problem.fitnessfcn=@(x)gaminlppenaltyfcn(x,problem,conScale);



        problem.nonlcon=[];


        function[fval,exitflag,output]=i_generateOutput(FitnessFcn,NonconFcn,...
            Aineq,bineq,Aeq,beq,problem,xfinal,galinconexitflag,output)






            fval=FitnessFcn(xfinal);
            if isempty(NonconFcn)
                c=[];
                ceq=[];
            else


                [c,ceq]=NonconFcn(xfinal);
            end
            output.funccount=output.funccount+1;

            if problem.options.isMINLP
                output.problemtype='integerconstraints';
                Aineq=problem.Aineq;bineq=problem.bineq;
                ceq=[];
            else
                output.problemtype='nonlinearconstr';
            end


            conviol=[...
            abs(Aeq*xfinal(:)-beq);...
            Aineq*xfinal(:)-bineq;...
            xfinal(:)-problem.ub(:);...
            problem.lb(:)-xfinal(:);
            c(:);
            abs(ceq(:))];
            output.maxconstraint=norm(max(conviol,0),Inf);





            if galinconexitflag>0

                linTol=max(sqrt(eps),problem.options.TolCon);
                linFeasible=isTrialFeasible(xfinal(:),Aineq,bineq,...
                Aeq,beq,problem.lb,problem.ub,linTol);



                nonlinFeasible=(isempty(c)||(max(c(:))<problem.options.TolCon))&&...
                (isempty(ceq)||(norm(ceq(:),Inf)<problem.options.TolCon));


                if~linFeasible||~nonlinFeasible
                    exitflag=-2;
                else
                    exitflag=galinconexitflag;
                end
            else
                exitflag=galinconexitflag;
            end



            hasConstr=~isempty(problem.lb)||~isempty(problem.ub)||...
            ~isempty(NonconFcn)||~isempty(problem.Aineq);


            output.message=gaminlpcreateexitmsg(exitflag,galinconexitflag,...
            hasConstr,output.message);


            function problem=i_displayAndPlot(problem)


                userVerbosity=problem.options.Verbosity;


                problem.options.Display='off';
                problem.options.Verbosity=0;





                if userVerbosity>1






                    outFcns=problem.options.OutputFcns;
                    if isempty(outFcns)
                        problem.options.OutputPlotFcnOptions=optimoptions(@ga);
                        problem.options.OutputPlotFcnOptions=copyForOutputAndPlotFcn(...
                        problem.options.OutputPlotFcnOptions,problem.options);
                        outFcns{1}=@gaminlpiterdisp;
                    else
                        outFcns{end+1}=@gaminlpiterdisp;
                    end


                    problem.options.OutputFcns=outFcns;
                    problem.options.OutputFcnsArgs{end+1}={};
                end




                if~isempty(problem.options.PlotFcns)


                    PlotFcnsStr=cellfun(@func2str,problem.options.PlotFcns,...
                    'UniformOutput',false);


                    idxBestF=ismember(PlotFcnsStr,'gaplotbestf');
                    problem.options.PlotFcns(idxBestF)={@gaminlpplotbestf};


                    idxBestFun=ismember(PlotFcnsStr,'gaplotbestfun');
                    problem.options.PlotFcns(idxBestFun)={@gaminlpplotbestfun};


                    idxScores=ismember(PlotFcnsStr,'gaplotscores');
                    problem.options.PlotFcns(idxScores)={@gaminlpplotscores};
                end







