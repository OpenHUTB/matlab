function[x,fval,exitflag,output,solutions]=...
    fmultistart(problem,startPointSets,msoptions)



















    try
        inputOptions=globaloptim.internal.mergeOptionsStructs(optimset(problem.solver),problem.options);
        tmpOptions=inputOptions;
        tmpOptions.MaxIter=0;
        tmpOptions.Display='off';
        tmpOptions.OutputFcn=[];
        tmpOptions.PlotFcns=[];
        problem.options=tmpOptions;
        if any(strcmp(problem.solver,{'lsqnonlin','lsqcurvefit'}))
            [~,~,~,~,tmpOutput]=feval(problem.solver,problem);
        else
            [~,~,~,tmpOutput]=feval(problem.solver,problem);
        end

        problem.options=inputOptions;

        numEvalCallFunEvals=tmpOutput.funcCount;
    catch usrInput_ME
        errMsg=message('globaloptim:MultiStart:run:ProblemError');
        globaloptim_ME=MException(errMsg.Identifier,getString(errMsg));
        usrInput_ME=addCause(usrInput_ME,globaloptim_ME);
        rethrow(usrInput_ME)
    end


    startTime=clock;


    switch msoptions.Display
    case{'off','none'}
        verbosity=0;
    case 'final'
        verbosity=1;
    case 'iter'
        verbosity=2;
    otherwise
        verbosity=1;
    end

    startPoints=[];

    for i=1:length(startPointSets)
        startPoints=[startPoints,list(startPointSets{i},problem)'];
    end



    if isfield(problem,'nonlcon')&&~isempty(problem.nonlcon)


        [tmpNlinIneqCon,~]=problem.nonlcon(problem.x0);
        numNlinIneqCon=numel(tmpNlinIneqCon);
        numNlinSizeFunEvals=1;
    else
        numNlinIneqCon=0;
        numNlinSizeFunEvals=0;
    end


    [startPoints,numPreRunFunEvals]=...
    globaloptim.internal.filterStartPoints(msoptions.StartPointsToRun,startPoints,...
    problem,numNlinIneqCon);
    numPreRunFunEvals=numPreRunFunEvals+numNlinSizeFunEvals;


    numStartPointsToRun=size(startPoints,2);


    runFinishedInTime=false(1,numStartPointsToRun);

    runMadeProgress=false(1,numStartPointsToRun);

    solOut=cell(1,numStartPointsToRun);

    runInParallelMode=msoptions.UseParallel&&isParallelPoolAvailableToUse;

    if verbosity>1
        i_printIterativeDisplayHeader(runInParallelMode);
    end


    timeStore.maxTime=msoptions.MaxTime;
    timeStore.startTime=startTime;



    problem.options=globaloptim.internal.createOutputFunctions(problem.options,timeStore);


    problemStruct=createProblemStruct(problem.solver,[],problem);
    problemStruct.options=problem.options;
    problemAsCell=struct2cell(rmfield(problemStruct,'solver'));

    localSolver=problem.solver;

    hLocalSolver=str2func(localSolver);


    stop=false;

    if isempty(msoptions.OutputFcns)
        haveoutputfcn=false;
    else
        haveoutputfcn=true;


        msoptions.OutputFcns=createCellArrayOfFunctions(msoptions.OutputFcns,'OutputFcns');
    end


    if isempty(msoptions.PlotFcns)
        haveplotfcn=false;
    else
        haveplotfcn=true;


        msoptions.PlotFcns=createCellArrayOfFunctions(msoptions.PlotFcns,'PlotFcns');
    end


    if runInParallelMode
        if haveoutputfcn||haveplotfcn
            warning(message('globaloptim:MultiStart:run:NoOutputPlotFcnsInParallel'))
        end

        maxTimeExceeded=etime(clock,timeStore.startTime)>=timeStore.maxTime;

        if~maxTimeExceeded
            parfor i=1:numStartPointsToRun
                [solOut{i},runFinishedInTime(i),runMadeProgress(i)]=...
                i_runThisStartPoint(localSolver,hLocalSolver,problemAsCell,...
                startPoints(:,i),verbosity,i,timeStore);
            end
        end
    else
        if haveoutputfcn||haveplotfcn

            funccount=numEvalCallFunEvals+numPreRunFunEvals;
            localsolution=struct('X',[],'Fval',[],'Exitflag',[]);
            bestx=[];
            bestfval=[];



            bestSolOut={[],[],Inf,-10,[]};

            msoptions.OutputPlotFcnOptions=msoptions;


            optimValues=...
            i_updateOptimValues(localsolution,0,funccount,bestx,bestfval);
            stop=globaloptim.internal.callOutputAndPlotFcns(msoptions,optimValues,'init','MultiStart');
        end

        maxTimeExceeded=etime(clock,timeStore.startTime)>=timeStore.maxTime;

        if(~stop&&~maxTimeExceeded)
            for i=1:numStartPointsToRun
                [solOut{i},runFinishedInTime(i),runMadeProgress(i)]=...
                i_runThisStartPoint(localSolver,hLocalSolver,problemAsCell,...
                startPoints(:,i),verbosity,i,timeStore);
                if haveoutputfcn||haveplotfcn

                    funccount=funccount+solOut{i}{5}.funcCount;
                    if isempty(solOut{i}{2})
                        localsolution.X=[];
                        localsolution.Fval=[];
                    else
                        localsolution.X=problem.x0;
                        localsolution.X(:)=solOut{i}{2}(:);
                        localsolution.Fval=solOut{i}{3};
                    end
                    localsolution.Exitflag=solOut{i}{4};

                    [bestx,bestfval,idxBestRun]=...
                    i_getBestRun({bestSolOut,solOut{i}},problem);
                    if~isempty(idxBestRun)&&idxBestRun==2
                        bestSolOut=solOut{i};
                    end

                    optimValues=i_updateOptimValues(localsolution,...
                    i,funccount,bestx,bestfval);
                    stop=globaloptim.internal.callOutputAndPlotFcns(msoptions,optimValues,...
                    'iter','MultiStart');
                    if stop
                        break
                    end
                end

                maxTimeExceeded=etime(clock,timeStore.startTime)>=timeStore.maxTime;

                if~runFinishedInTime(i)||maxTimeExceeded
                    break
                end
            end
        end
        if haveoutputfcn||haveplotfcn

            optimValues=i_updateOptimValues(localsolution,...
            i,funccount,bestx,bestfval);
            globaloptim.internal.callOutputAndPlotFcns(msoptions,optimValues,'done','MultiStart');
        end
    end

    solOut=solOut(runFinishedInTime|runMadeProgress);

    [x,fval]=i_getBestRun(solOut,problem);

    if nargout==5
        solutions=i_populateSolutionVector(solOut,msoptions.TolX,...
        msoptions.TolFun,problem.x0);
    end


    [exitflag,output]=...
    i_createExitflagAndOutput(solOut,numEvalCallFunEvals+numPreRunFunEvals,...
    runFinishedInTime,runMadeProgress,timeStore.maxTime,stop);

    if verbosity>0
        i_printExitMsg(output.message);
    end




    function[solOut,thisRunFinishedInTime,thisRunMadeProgress]=...
        i_runThisStartPoint(solver,hSolver,problemAsCell,x0,...
        verbosity,runIndex,timeStore)

        problemAsCell{2}(:)=x0;

        thisRunFinishedInTime=true;

        thisRunMadeProgress=false;



        outFun=optimget(problemAsCell{end},'OutputFcn');
        if iscell(outFun)
            outFunInfo=functions(outFun{end});
        else
            outFunInfo=functions(outFun);
        end
        ws=outFunInfo.workspace{1};
        outStoreCont=ws.outStoreCont;


        outStoreCont.resetOutputStore();

        try

            warningState=[warning('off','optim:fminunc:SwitchingMethod'),...
            warning('off','optimlib:lsqncommon:SwitchToLineSearch'),...
            warning('off','optimlib:checkbounds:IgnoringExtraLbs'),...
            warning('off','optimlib:checkbounds:IgnoringExtraUbs'),...
            warning('off','optimlib:checkbounds:PadLbWithMinusInf'),...
            warning('off','optimlib:checkbounds:PadUbWithInf')];

            if any(strcmp(solver,{'lsqnonlin','lsqcurvefit'}))
                [thisX,thisFval,~,thisExitflag,thisOutput]=...
                hSolver(problemAsCell{:});
            else
                [thisX,thisFval,thisExitflag,thisOutput]=...
                hSolver(problemAsCell{:});
            end
            warning(warningState);
        catch ME
            thisX=[];
            thisFval=Inf;
            thisExitflag=-10;



            outStore=outStoreCont.getOutputStore();
            thisOutput=struct('funcCount',outStore.funcCount);
            warning(warningState);
        end
        if~isinf(timeStore.maxTime)
            thisRunFinishedInTime=false;
            if thisExitflag~=-1||...
                etime(clock,timeStore.startTime)<timeStore.maxTime
                thisRunFinishedInTime=true;
            end
        end

        if~thisRunFinishedInTime
            if isfield(thisOutput,'iterations')&&thisOutput.iterations>=1
                thisRunMadeProgress=true;
            end
        end


        solOut={problemAsCell{2},thisX,thisFval,thisExitflag,thisOutput};

        if verbosity>1&&thisRunFinishedInTime
            i_printIterativeDisplay(thisFval,thisExitflag,thisOutput,runIndex);
        end

        function[x,fval,idxBestRun]=i_getBestRun(solutions,problem)

            allFvals=cellfun(@(x)x{3},solutions);


            allExitFlag=cellfun(@(x)x{4},solutions);


            idxPosEF=allExitFlag>0;
            idxMinusTenEF=allExitFlag==-10;


            if all(idxMinusTenEF)
                x=[];
                fval=[];
                idxBestRun=[];
                return
            elseif any(idxPosEF)


                idx=find(idxPosEF);
                [fval,idxBestInPosEF]=min(allFvals(idx));
                idxBestRun=idx(idxBestInPosEF);
            else


                numRuns=length(solutions);
                constrViolLessTolCon=false(1,numRuns);
                if isfield(problem.options,'TolCon')
                    tolCon=optimget(problem.options,'TolCon',1e-6);
                else
                    tolCon=1e-6;
                end


                idxMinInfeas=1;
                minInfeasVal=Inf;
                for i=1:numRuns

                    outputStruct=solutions{i}{5};
                    if isfield(outputStruct,'constrviolation')
                        constrViolation=outputStruct.constrviolation;


                    elseif~isempty(solutions{i}{2})
                        constrViolation=...
                        i_calculateConstrViolation(solutions{i}{2},problem);
                    else
                        constrViolation=Inf;
                    end
                    if constrViolation<=tolCon
                        constrViolLessTolCon(i)=true;
                    elseif constrViolation<minInfeasVal
                        minInfeasVal=constrViolation;
                        idxMinInfeas=i;
                    end
                end
                if any(constrViolLessTolCon)
                    [fval,idxTmp]=min(allFvals(constrViolLessTolCon));
                    idxVecTmp=find(constrViolLessTolCon,idxTmp);
                    idxBestRun=idxVecTmp(end);
                else
                    idxBestRun=idxMinInfeas;
                    fval=solutions{idxBestRun}{3};
                end
            end

            x=solutions{idxBestRun}{2};

            function constrViolation=i_calculateConstrViolation(x,problem)


                dimX=numel(x);



                if~isfield(problem,'Aeq')||isempty(problem.Aeq)
                    Aeq=zeros(0,dimX);
                else
                    Aeq=problem.Aeq;
                end
                if~isfield(problem,'beq')||isempty(problem.beq)
                    beq=zeros(0,1);
                else
                    beq=problem.beq;
                end



                if~isfield(problem,'lb')
                    lb=-Inf(dimX,1);
                else
                    lb=problem.lb;
                end
                if~isfield(problem,'ub')
                    ub=Inf(dimX,1);
                else
                    ub=problem.ub;
                end

                [~,lb,ub]=checkbounds(problem.x0,lb,ub,dimX);

                constrViolation=max([0;norm(Aeq*x(:)-beq,inf);(lb-x(:));(x(:)-ub)]);

                function[exitflag,output]=...
                    i_createExitflagAndOutput(solutions,numMultiStartFunEvals,...
                    runFinishedInTime,runMadeProgress,maxTime,stop)


                    localFuncCount=sum(cellfun(@(x)x{5}.funcCount,solutions));


                    output.funcCount=localFuncCount+numMultiStartFunEvals;



                    output.localSolverTotal=sum(runFinishedInTime|runMadeProgress);

                    output.localSolverSuccess=sum(cellfun(@(x)x{4}>0,solutions));
                    output.localSolverIncomplete=sum(cellfun(@(x)x{4}==0,solutions));



                    if output.localSolverTotal==0
                        output.localSolverNoSolution=0;
                    else
                        output.localSolverNoSolution=sum(cellfun(@(x)x{4}<0,solutions));
                    end


                    [exitflag,output.message]=...
                    i_createExitflagAndMsg(solutions,runFinishedInTime,...
                    runMadeProgress,maxTime,stop);

                    function[exitflag,msg]=...
                        i_createExitflagAndMsg(solutions,runFinishedInTime,...
                        runMadeProgress,maxTime,stop)
                        allExitFlag=cellfun(@(x)x{4},solutions);

                        idxPosEF=allExitFlag>0;
                        idxZeroEF=allExitFlag==0;
                        idxMinusTwoEF=allExitFlag==-2;
                        idxFailEF=allExitFlag==-10;
                        idxOutFcnEF=allExitFlag==-1;

                        numActualStartPointsRun=sum(runFinishedInTime|runMadeProgress);

                        if any(~runFinishedInTime)&&~stop


                            exitflag=-5;
                        elseif isempty(allExitFlag)

                            exitflag=-8;
                        elseif sum(idxPosEF)==numActualStartPointsRun

                            exitflag=1;
                        elseif any(idxPosEF)

                            exitflag=2;
                        elseif all(idxFailEF)
                            exitflag=-10;
                        elseif any(idxZeroEF)
                            exitflag=0;
                        else
                            exitflag=-8;
                            if all(idxMinusTwoEF)
                                exitflag=-2;
                            end
                        end

                        switch exitflag
                        case 2
                            msg1=getString(message('globaloptim:MultiStart:run:Exit2pt1'));
                            msg2=getString(message('globaloptim:MultiStart:run:Exit2pt2',...
                            num2str(sum(idxPosEF),'%d'),num2str(numActualStartPointsRun,'%d')));
                        case 1
                            msg1=getString(message('globaloptim:MultiStart:run:Exit1pt1'));
                            if numActualStartPointsRun==1
                                msg2=getString(message('globaloptim:MultiStart:run:Exit1pt2v1'));
                            else
                                msg2=getString(message('globaloptim:MultiStart:run:Exit1pt2v2',num2str(numActualStartPointsRun,'%d')));
                            end
                        case 0
                            msg1=getString(message('globaloptim:MultiStart:run:Exit0pt1'));
                            if numActualStartPointsRun==1
                                msg2a=getString(message('globaloptim:MultiStart:run:Exit0pt2av1'));
                            else
                                msg2a=getString(message('globaloptim:MultiStart:run:Exit0pt2av2',...
                                num2str(sum(idxZeroEF),'%d'),num2str(numActualStartPointsRun,'%d')));
                            end
                            msg2b=getString(message('globaloptim:MultiStart:run:Exit0pt2b'));
                            if numActualStartPointsRun==1
                                msg2c=getString(message('globaloptim:MultiStart:run:Exit0pt2cv1'));
                            else
                                msg2c=getString(message('globaloptim:MultiStart:run:Exit0pt2cv2',num2str(numActualStartPointsRun,'%d')));
                            end
                            msg2=[msg2a,msg2b,msg2c];
                        case-2
                            msg1=getString(message('globaloptim:MultiStart:run:ExitNeg2pt1'));
                            if numActualStartPointsRun==1
                                msg2a=getString(message('globaloptim:MultiStart:run:ExitNeg2pt2av1'));
                            else
                                msg2a=getString(message('globaloptim:MultiStart:run:ExitNeg2pt2av2',num2str(numActualStartPointsRun,'%d')));
                            end
                            msg2b=getString(message('globaloptim:MultiStart:run:ExitNeg2pt2b'));
                            msg2=[msg2a,msg2b];
                        case-5
                            msg1=getString(message('globaloptim:MultiStart:run:ExitNeg5pt1'));
                            if numActualStartPointsRun==1
                                msg2a=getString(message('globaloptim:MultiStart:run:ExitNeg5pt2av1',num2str(maxTime,'%g')));
                            else
                                msg2a=getString(message('globaloptim:MultiStart:run:ExitNeg5pt2av2',...
                                num2str(numActualStartPointsRun,'%d'),num2str(maxTime,'%g')));
                            end
                            if sum(idxPosEF)==1
                                msg2b=getString(message('globaloptim:MultiStart:run:ExitNeg5pt2bv1'));
                            else
                                msg2b=getString(message('globaloptim:MultiStart:run:ExitNeg5pt2bv2',num2str(sum(idxPosEF),'%d')));
                            end
                            msg2=[msg2a,msg2b];
                        case-8
                            msg1=getString(message('globaloptim:MultiStart:run:ExitNeg8pt1'));
                            if numActualStartPointsRun==1
                                msg2a=getString(message('globaloptim:MultiStart:run:ExitNeg8pt2av1'));
                            else
                                msg2a=getString(message('globaloptim:MultiStart:run:ExitNeg8pt2av2',num2str(numActualStartPointsRun,'%d')));
                            end
                            numRunsStopped=sum(idxOutFcnEF);
                            if numRunsStopped==1
                                msg2b=getString(message('globaloptim:MultiStart:run:ExitNeg8pt2bv1'));
                            elseif numRunsStopped==0
                                msg2b='';
                            else
                                msg2b=getString(message('globaloptim:MultiStart:run:ExitNeg8pt2bv2',num2str(numRunsStopped,'%d')));
                            end
                            msg2=[msg2a,msg2b];
                        case-10
                            msg1=getString(message('globaloptim:MultiStart:run:ExitNeg10pt1'));
                            if numActualStartPointsRun==1
                                msg2=getString(message('globaloptim:MultiStart:run:ExitNeg10pt2v1'));
                            else
                                msg2=getString(message('globaloptim:MultiStart:run:ExitNeg10pt2v2',num2str(numActualStartPointsRun,'%d')));
                            end
                        otherwise

                            error(message('globaloptim:MultiStart:run:InvalidExitflag'));
                        end



                        if stop
                            exitflag=-1;
                            msg1=sprintf('MultiStart stopped by the output or plot function.\n\n');
                            if numActualStartPointsRun==0
                                msg2=sprintf('MultiStart stopped before any calls to the local solver.');
                            end
                        end


                        msg=[msg1,msg2];

                        function SolVec=i_populateSolutionVector(solOut,tolX,tolFun,xOrigShape)
                            allExitFlag=cellfun(@(X)X{4},solOut);

                            idxPosEF=allExitFlag>0;

                            solutionSet=solOut(idxPosEF);



                            if isempty(solutionSet)
                                SolVec=GlobalOptimSolution.empty(1,0);
                            else
                                numSolutions=length(solutionSet);
                                solPoints=zeros(numel(xOrigShape),numSolutions);
                                solFvals=zeros(1,numSolutions);
                                for i=1:numSolutions
                                    solPoints(:,i)=solutionSet{i}{2}(:);
                                    solFvals(i)=solutionSet{i}{3};
                                end


                                [~,idx]=sort(solFvals);

                                solutionSet=solutionSet(idx);


                                [indDistinctSol,numDistinctSol,locSameSol]=...
                                i_findDistinctSolutions(solPoints(:,idx),tolX,solFvals(idx),tolFun);


                                SolVec(1:numDistinctSol)=GlobalOptimSolution;

                                cDS=0;
                                for i=1:numSolutions
                                    if indDistinctSol(i)
                                        cDS=cDS+1;
                                        ThisXSol=xOrigShape;
                                        ThisX0=xOrigShape;
                                        ThisXSol(:)=solutionSet{i}{2}(:);
                                        ThisX0(:)=solutionSet{i}{1}(:);
                                        ThisFval=solutionSet{i}{3};
                                        ThisEF=solutionSet{i}{4};
                                        ThisOutput=solutionSet{i}{5};
                                        indAllX0=find(locSameSol==cDS);
                                        numOtherX0=size(indAllX0,2)-1;
                                        ThisOtherX0=cell(1,numOtherX0);
                                        ThisOtherX0(:)={xOrigShape};
                                        for j=1:numOtherX0
                                            ThisOtherX0{j}(:)=solutionSet{indAllX0(j+1)}{1}(:);
                                        end
                                        SolVec(cDS)=GlobalOptimSolution(ThisXSol,ThisFval,ThisEF,...
                                        ThisOutput,ThisX0,ThisOtherX0);
                                    end
                                end
                            end

                            function[indDistinctSol,countDistinctSol,locSameSol]=...
                                i_findDistinctSolutions(solPoints,tolX,solFvals,tolFun)
                                numPnts=size(solPoints,2);
                                if numPnts==0
                                    indDistinctSol=[];
                                    return
                                end


                                countDistinctSol=0;


                                locSameSol=zeros(1,numPnts);


                                indDistinctSol=true(1,numPnts);

                                for i=1:numPnts-1
                                    if indDistinctSol(i)
                                        countDistinctSol=countDistinctSol+1;
                                        indNearPoints=...
                                        find(globaloptim.internal.mexfiles.mx_distancepoints(solPoints(:,i),solPoints(:,i+1:end))<=...
                                        (tolX*max(1,norm(solPoints(:,i)))).^2)+i;
                                        indNonDistinct=indNearPoints((abs(solFvals(indNearPoints)-solFvals(i))...
                                        <=tolFun*max(1,abs(solFvals(i)))));
                                        indDistinctSol(indNonDistinct)=false;
                                        locSameSol([i;indNonDistinct])=countDistinctSol;
                                    end
                                end
                                if indDistinctSol(end)
                                    countDistinctSol=countDistinctSol+1;
                                    locSameSol(end)=countDistinctSol;
                                end

                                function isOpen=isParallelPoolAvailableToUse




                                    parfor ii=1:1


                                    end


                                    try
                                        currPool=gcp();

                                        if~isempty(currPool)
                                            poolSize=currPool.NumWorkers;
                                        else
                                            poolSize=0;
                                        end
                                    catch E %#ok<NASGU>
                                        poolSize=0;
                                    end

                                    isOpen=poolSize~=0;

                                    function i_printIterativeDisplayHeader(runInParallelMode)
                                        if runInParallelMode
                                            fprintf('Running the local solvers in parallel.\n');
                                        end
                                        fprintf('\n%8s %12s %12s %8s %8s %12s\n%8s %12s %12s %8s %8s %12s\n',...
                                        ' Run ',' Local  ','    Local   ',' Local ',' Local ',' First-order',...
                                        'Index','exitflag','     f(x)   ','# iter ','F-count',' optimality');

                                        function i_printIterativeDisplay(localFval,localExitFlag,localOutput,runIndex)

                                            FuncCount=localOutput.funcCount;
                                            if localExitFlag~=-10
                                                localIterNum=localOutput.iterations;
                                                localFirstOrderOpt=localOutput.firstorderopt;
                                                fprintf('%8d %9d %12.4g %9d %9d %13.4g\n',...
                                                runIndex,localExitFlag,localFval,localIterNum,FuncCount,...
                                                localFirstOrderOpt);
                                            else
                                                fprintf('%8d %9d %22s %9d\n',...
                                                runIndex,localExitFlag,'',FuncCount);

                                            end

                                            function i_printExitMsg(exitMsg)
                                                fprintf('\n%s\n',exitMsg);

                                                function optimValues=i_updateOptimValues(localSolution,...
                                                    localRunIndex,funcCount,bestX,bestFval)

                                                    optimValues.localsolution=localSolution;
                                                    optimValues.localrunindex=localRunIndex;
                                                    optimValues.funccount=funcCount;
                                                    optimValues.bestx=bestX;
                                                    optimValues.bestfval=bestFval;
