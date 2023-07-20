function[X,FVAL,EXITFLAG,OUTPUT,SOLUTIONSET]=globalsearchnlp(FUN,X,A,B,Aeq,Beq,LB,UB,NONLCON,options,localOptions)

















































































    defaultOptions=struct('MaxIter',1000,...
    'StageOneIter',200,...
    'MaxWaitCycle',20,...
    'PenaltyThresholdFactor',0.2,...
    'BasinRadiusFactor',0.2,...
    'DistanceThresholdFactor',0.75,...
    'AllowBasinOverlap',true,...
    'PopSize',16,...
    'StartPointsToRun','all',...
    'TolX',1e-6,...
    'TolFun',1e-6,...
    'MaxTime',Inf,...
    'Display','off',...
    'OutputFcns',[],...
    'PlotFcns',[]);




    if nargin~=11
        error(message('globaloptim:globalsearchnlp:IncorrectNumInputs'));
    end




    [~,A,B,Aeq,Beq,LB,UB]=globaloptim.globalsearch.checkglobalsearchnlpinputs(X,A,B,Aeq,Beq,LB,UB);


    B=B(:);
    Beq=Beq(:);





    try


        defaultLocalOptions=optimset('fmincon');


        localOptions=globaloptim.internal.mergeOptionsStructs(defaultLocalOptions,localOptions);




        InputMaxIter=localOptions.MaxIter;
        InputDisplay=localOptions.Display;
        InputOutputFcn=localOptions.OutputFcn;
        InputPlotFcns=localOptions.PlotFcns;
        localOptions.MaxIter=0;
        localOptions.Display='none';
        localOptions.OutputFcn=[];
        localOptions.PlotFcns=[];
        [~,~,~,outErrorCheck]=fmincon(FUN,X,A,B,Aeq,Beq,LB,...
        UB,NONLCON,localOptions);


        funcCount=outErrorCheck.funcCount;


        if~isempty(localOptions)
            localOptions.MaxIter=InputMaxIter;
            localOptions.Display=InputDisplay;
            localOptions.OutputFcn=InputOutputFcn;
            localOptions.PlotFcns=InputPlotFcns;
        end
    catch usrInput_ME
        globaloptim_ME=MException('globaloptim:globalsearchnlp:ProblemError',...
        'Failure in initial call to fmincon with user-supplied problem structure.');
        usrInput_ME=addCause(usrInput_ME,globaloptim_ME);
        rethrow(usrInput_ME)
    end




    startTime=clock;


    numOutputsRequested=nargout;



    options=globaloptim.internal.mergeOptionsStructs(defaultOptions,options);


    if isempty(options.OutputFcns)
        haveOutputFcns=false;
    else
        haveOutputFcns=true;
        options.OutputFcns=createCellArrayOfFunctions(...
        options.OutputFcns,'OutputFcns');
    end


    if isempty(options.PlotFcns)
        havePlotFcns=false;
    else
        havePlotFcns=true;
        options.PlotFcns=createCellArrayOfFunctions(...
        options.PlotFcns,'PlotFcns');
    end




    timeStore.maxTime=options.MaxTime;
    timeStore.startTime=startTime;
    localOptions=globaloptim.internal.createOutputFunctions(localOptions,timeStore);



    xOrigShape=X;





    [candPtLB,candPtUB]=globaloptim.internal.pCreateCandidatePointBounds(LB,UB);


    LOCAL.X=[];
    LOCAL.FVAL=[];
    LOCAL.EXITFLAG=[];
    LOCAL.OUTPUT=[];
    LOCAL.X0={};
    LOCAL.NumLocalSearch=[];
    LOCAL.MaxDist=[];
    LOCAL.LocalSolverCount=struct('Total',0,...
    'PosEF',0,'ZeroEF',0,'NegEF',0);









    failedSolnInfo=struct('X',[],'FVAL',[],'EXITFLAG',[],...
    'OUTPUT',[],'AllFailedLocalExitFlag',[]);



    localSolForDisp=struct('X',[],'Fval',[],'Exitflag',[]);


    penWts=[];


    switch options.Display
    case{'off','none'}
        verbosity=0;
    case 'final'
        verbosity=1;
    case 'iter'
        verbosity=2;
    otherwise
        verbosity=1;
    end


    if verbosity>1
        i_printIterativeDisplayHeader;
    end


    if haveOutputFcns||havePlotFcns

        options.OutputPlotFcnOptions=options;

        optimValues=i_updateOptimValues(localSolForDisp,0,funcCount,[],[]);
        stop=globaloptim.internal.callOutputAndPlotFcns(options,optimValues,'init','GlobalSearch');
    else
        stop=false;
    end


    localFuncCount=0;
    if i_isDone(timeStore,stop)
        [X,FVAL,EXITFLAG,OUTPUT,SOLUTIONSET]=i_doFinishTasks(...
        xOrigShape,LOCAL,failedSolnInfo,localSolForDisp,funcCount,...
        localFuncCount,timeStore,stop,options,numOutputsRequested,verbosity);
        return
    else
        [LOCAL,failedSolnInfo,localFuncCount,penWts,localSolForDisp]=...
        i_runLocalSolver(FUN,X(:),A,B,Aeq,Beq,LB,UB,NONLCON,...
        localOptions,options.AllowBasinOverlap,LOCAL,failedSolnInfo,...
        localFuncCount,penWts,xOrigShape,options.TolX,options.TolFun);



        if verbosity>1
            i_printIterativeDisplay('InitialPoint',0,LOCAL,failedSolnInfo,...
            xOrigShape,0,localFuncCount,'','',localSolForDisp);
        end
        if haveOutputFcns||havePlotFcns
            [currBestX,currBestFval]=i_retrieveSolution(LOCAL,...
            failedSolnInfo,xOrigShape);
            optimValues=i_updateOptimValues(localSolForDisp,LOCAL.LocalSolverCount.Total,...
            funcCount+localFuncCount,currBestX,currBestFval);
            stop=globaloptim.internal.callOutputAndPlotFcns(options,optimValues,'iter','GlobalSearch');
        end
    end


    StageTwoIter=options.MaxIter-options.StageOneIter;


    if~i_isDone(timeStore,stop)
        [TrialPts,scatterSearchFuncCount]=i_returnScatterSearchPts(...
        FUN,X,candPtLB,candPtUB,NONLCON,options.StageOneIter,...
        StageTwoIter,options.PopSize);
    else
        TrialPts=[];
        scatterSearchFuncCount=0;
    end


    funcCount=funcCount+scatterSearchFuncCount;



    if isempty(TrialPts)||i_isDone(timeStore,stop)
        [X,FVAL,EXITFLAG,OUTPUT,SOLUTIONSET]=i_doFinishTasks(...
        xOrigShape,LOCAL,failedSolnInfo,localSolForDisp,funcCount,...
        localFuncCount,timeStore,stop,options,numOutputsRequested,verbosity);
        return
    end





    StageOnePenVal=zeros(options.StageOneIter,1);
    for i=1:options.StageOneIter
        [StageOnePenVal(i),thisFuncCount]=i_calcPenalty(FUN,A,B,Aeq,...
        Beq,LB,UB,NONLCON,TrialPts(:,i),penWts,xOrigShape);
        funcCount=funcCount+thisFuncCount;
    end
    [~,StageOneBestIdx]=min(StageOnePenVal);
    StageOneBestPt=TrialPts(:,StageOneBestIdx);



    if i_isDone(timeStore,stop)
        [X,FVAL,EXITFLAG,OUTPUT,SOLUTIONSET]=i_doFinishTasks(...
        xOrigShape,LOCAL,failedSolnInfo,localSolForDisp,funcCount,...
        localFuncCount,timeStore,stop,options,numOutputsRequested,verbosity);
        return
    end


    [LOCAL,failedSolnInfo,localFuncCount,penWts,localSolForDisp]=...
    i_runLocalSolver(FUN,StageOneBestPt,A,B,Aeq,Beq,LB,UB,...
    NONLCON,localOptions,options.AllowBasinOverlap,LOCAL,...
    failedSolnInfo,localFuncCount,penWts,xOrigShape,...
    options.TolX,options.TolFun);


    if verbosity>1
        i_printIterativeDisplay('StageOneLocal',options.StageOneIter,LOCAL,...
        failedSolnInfo,xOrigShape,funcCount,localFuncCount,'','',...
        localSolForDisp);
    end


    if haveOutputFcns||havePlotFcns
        [currBestX,currBestFval]=i_retrieveSolution(LOCAL,...
        failedSolnInfo,xOrigShape);
        optimValues=i_updateOptimValues(localSolForDisp,LOCAL.LocalSolverCount.Total,...
        funcCount+localFuncCount,currBestX,currBestFval);
        stop=globaloptim.internal.callOutputAndPlotFcns(options,optimValues,'iter','GlobalSearch');
    end
    if i_isDone(timeStore,stop)
        [X,FVAL,EXITFLAG,OUTPUT,SOLUTIONSET]=i_doFinishTasks(...
        xOrigShape,LOCAL,failedSolnInfo,localSolForDisp,funcCount,...
        localFuncCount,timeStore,stop,options,numOutputsRequested,verbosity);
        return
    end




    if isempty(LOCAL.X)




        [localSolverThreshold,thisFuncCount]=i_calcPenalty(FUN,A,B,...
        Aeq,Beq,LB,UB,NONLCON,StageOneBestPt,penWts,xOrigShape);
        distWaitCycle=zeros(1,0);
    else




        nLocal=size(LOCAL.X,2);
        thisLocalSolverThreshold=zeros(nLocal,1);
        thisFuncCount=zeros(nLocal,1);
        for i=1:nLocal
            [thisLocalSolverThreshold(i),thisFuncCount(i)]=i_calcPenalty(...
            FUN,A,B,Aeq,Beq,LB,UB,NONLCON,LOCAL.X(:,i),penWts,xOrigShape);
        end
        localSolverThreshold=min(thisLocalSolverThreshold);
        thisFuncCount=sum(thisFuncCount);
        distWaitCycle=zeros(1,nLocal);
    end
    funcCount=funcCount+thisFuncCount;



    problem=createOptimProblem('fmincon','objective',FUN,...
    'x0',xOrigShape,'Aineq',A,'bineq',B,'Aeq',Aeq,'beq',Beq,...
    'lb',LB,'ub',UB,'nonlcon',NONLCON,'options',localOptions);



    if isempty(problem.nonlcon)
        numNlinIneqCon=0;
    else


        hdlNonlcon=problem.nonlcon;
        [tmpNlinIneqCon,~]=hdlNonlcon(problem.x0);
        numNlinIneqCon=numel(tmpNlinIneqCon);
        funcCount=funcCount+1;
    end


    waitCycle=0;
    for i=1:StageTwoIter



        if i_isDone(timeStore,stop)
            break
        end


        XthisStart=TrialPts(:,options.StageOneIter+i);
        [penThis,thisFuncCount]=i_calcPenalty(FUN,...
        A,B,Aeq,Beq,LB,UB,NONLCON,XthisStart,penWts,xOrigShape);
        funcCount=funcCount+thisFuncCount;



        [XthisStart,thisFuncCount]=globaloptim.internal.filterStartPoints(options.StartPointsToRun,...
        XthisStart,problem,numNlinIneqCon);
        funcCount=funcCount+thisFuncCount;




        if isempty(XthisStart)||isempty(LOCAL.X)



            isThisInsideBasins=false(1,size(LOCAL.X,2));
        else
            isThisInsideBasins=sqrt(globaloptim.internal.mexfiles.mx_distancepoints(XthisStart,LOCAL.X))'...
            <=options.DistanceThresholdFactor*LOCAL.MaxDist;
        end






        if options.BasinRadiusFactor>0
            distWaitCycle=distWaitCycle+double(isThisInsideBasins);
            distWaitCycle(~isThisInsideBasins)=0;
        end





        if penThis<localSolverThreshold&&all(~isThisInsideBasins)...
            &&~isempty(XthisStart)


            waitCycle=0;
            [LOCAL,failedSolnInfo,localFuncCount,penWts,localSolForDisp]=...
            i_runLocalSolver(FUN,XthisStart,A,B,Aeq,Beq,LB,UB,...
            NONLCON,localOptions,options.AllowBasinOverlap,LOCAL,...
            failedSolnInfo,localFuncCount,penWts,xOrigShape,...
            options.TolX,options.TolFun);




            if length(LOCAL.FVAL)>length(distWaitCycle)
                distWaitCycle(end+1)=0;%#ok
            end



            if verbosity>1
                i_printIterativeDisplay('StageTwoLocal',options.StageOneIter+i,...
                LOCAL,failedSolnInfo,xOrigShape,funcCount,...
                localFuncCount,penThis,localSolverThreshold,localSolForDisp);
            end
            if haveOutputFcns||havePlotFcns
                [currBestX,currBestFval]=i_retrieveSolution(LOCAL,...
                failedSolnInfo,xOrigShape);
                optimValues=i_updateOptimValues(localSolForDisp,...
                LOCAL.LocalSolverCount.Total,funcCount+localFuncCount,...
                currBestX,currBestFval);
                stop=globaloptim.internal.callOutputAndPlotFcns(options,optimValues,'iter','GlobalSearch');
            end


            localSolverThreshold=penThis;

        else



            if penThis>=localSolverThreshold
                waitCycle=waitCycle+1;
            else
                localSolverThreshold=penThis;
                waitCycle=0;
            end



            if waitCycle>options.MaxWaitCycle
                localSolverThreshold=localSolverThreshold+...
                options.PenaltyThresholdFactor*(1+abs(localSolverThreshold));
                waitCycle=0;
            end





            if options.BasinRadiusFactor>0




                idxDec=distWaitCycle>options.MaxWaitCycle;
                LOCAL.MaxDist(idxDec)=...
                LOCAL.MaxDist(idxDec)*(1-options.BasinRadiusFactor);
                distWaitCycle(idxDec)=0;
            end

            if verbosity>1&&~rem(i,100)
                localSolForDisp.Exitflag='';
                localSolForDisp.Fval=[];
                i_printIterativeDisplay('StageTwoSearch',options.StageOneIter+i,...
                LOCAL,failedSolnInfo,xOrigShape,funcCount,localFuncCount,...
                penThis,localSolverThreshold,localSolForDisp);
            end

        end

    end





    [X,FVAL,EXITFLAG,OUTPUT,SOLUTIONSET]=i_doFinishTasks(...
    xOrigShape,LOCAL,failedSolnInfo,localSolForDisp,funcCount,...
    localFuncCount,timeStore,stop,options,numOutputsRequested,verbosity);



    function viol=i_calcConstrViolation(A,B,Aeq,Beq,LBCOL,UBCOL,NONLCON,XCOL,X)




        LBCOL(isnan(LBCOL))=-inf;
        UBCOL(isnan(UBCOL))=inf;


        lowerBoundCon=LBCOL-XCOL;
        upperBoundCon=XCOL-UBCOL;


        if isempty(A)
            linIneqCon=[];
        else
            linIneqCon=A*XCOL-B;
        end
        if isempty(Aeq)
            linEqCon=[];
        else
            linEqCon=Aeq*XCOL-Beq;
        end


        if isempty(NONLCON)
            nonlinIneqCon=[];
            nonlinEqCon=[];
        else
            [nonlinIneqCon,nonlinEqCon]=NONLCON(X);
        end



        viol=[lowerBoundCon;upperBoundCon;linIneqCon;...
        abs(linEqCon);nonlinIneqCon(:);abs(nonlinEqCon(:))];


        function[penValue,funcCount]=i_calcPenalty(FUN,A,B,Aeq,Beq,LBCOL,UBCOL,NONLCON,XCOL,w,X)







            X(:)=XCOL;



            viol=i_calcConstrViolation(A,B,Aeq,Beq,LBCOL,UBCOL,NONLCON,XCOL,X);


            TOL=1e-4;
            viol(viol<TOL)=0;


            if isempty(w)
                penValue=FUN(X)+1000*sum(viol);
            else
                penValue=FUN(X)+w'*viol;
            end




            funcCount=1;

            function[local,failedSolnInfo,localFuncCount,penWts,solForDisp]=...
                i_runLocalSolver(FUN,XthisStart,A,B,Aeq,Beq,LB,UB,NONLCON,...
                options,AllowBasinOverlap,local,failedSolnInfo,localFuncCount,...
                penWts,X,TolX,TolFun)


                outFun=optimget(options,'OutputFcn');
                if iscell(outFun)
                    outFunInfo=functions(outFun{end});
                else
                    outFunInfo=functions(outFun);
                end
                ws=outFunInfo.workspace{1};
                outStoreCont=ws.outStoreCont;


                outStoreCont.resetOutputStore();

                try









                    X(:)=XthisStart;


                    [Xthis,FVALthis,EF,OUTPUTthis,LAMBDA]=fmincon(FUN,...
                    X,A,B,Aeq,Beq,LB,UB,NONLCON,options);


                    Xthis=Xthis(:);

                catch

                    Xthis=[];
                    FVALthis=[];
                    EF=-10;




                    outStore=outStoreCont.getOutputStore();
                    OUTPUTthis=struct('funcCount',outStore.funcCount);




                    LAMBDA=[];
                end


                localFuncCount=localFuncCount+OUTPUTthis.funcCount;


                local.LocalSolverCount.Total=local.LocalSolverCount.Total+1;
                if EF>0
                    local.LocalSolverCount.PosEF=local.LocalSolverCount.PosEF+1;
                elseif EF==0
                    local.LocalSolverCount.ZeroEF=local.LocalSolverCount.ZeroEF+1;
                else
                    local.LocalSolverCount.NegEF=local.LocalSolverCount.NegEF+1;
                end


                if EF>0






                    if isempty(local.X)
                        newSolWithinTolOfExistingSol=false;
                    else
                        distToLoc=sqrt(globaloptim.internal.mexfiles.mx_distancepoints(Xthis,local.X));
                        [md,idx]=min(distToLoc);
                        newSolXNearExistingSolX=md<=(TolX*max(1,norm(Xthis)));
                        newSolFvalNearExistingSolFval=i_FVAL_Gap(FVALthis,local.FVAL(idx))<TolFun;
                        newSolWithinTolOfExistingSol=newSolXNearExistingSolX&&newSolFvalNearExistingSolFval;
                    end

                    if newSolWithinTolOfExistingSol




                        thisDist=sqrt(globaloptim.internal.mexfiles.mx_distancepoints(XthisStart,local.X(:,idx)));
                        if thisDist>local.MaxDist(idx)
                            local.MaxDist(idx)=thisDist;
                            if~AllowBasinOverlap
                                local=i_reduceMaxDist(local,idx);
                            end
                        end
                        local.NumLocalSearch(idx)=local.NumLocalSearch(idx)+1;




                        if EF==1&&local.EXITFLAG(idx)>1
                            local.X(:,idx)=Xthis;
                            local.FVAL(idx)=FVALthis;
                            local.EXITFLAG(idx)=EF;
                            local.OUTPUT(idx)=OUTPUTthis;


                            local.X0{idx}=[XthisStart,local.X0{idx}];
                        else


                            local.X0{idx}=[local.X0{idx},XthisStart];
                        end
                    else

                        local.X=[local.X,Xthis];
                        local.FVAL=[local.FVAL,FVALthis];
                        local.EXITFLAG=[local.EXITFLAG,EF];
                        local.OUTPUT=[local.OUTPUT,OUTPUTthis];
                        local.X0=[local.X0,{XthisStart}];
                        thisDist=sqrt(globaloptim.internal.mexfiles.mx_distancepoints(XthisStart,Xthis));
                        local.MaxDist=[local.MaxDist,thisDist];
                        local.NumLocalSearch=[local.NumLocalSearch,1];



                        if~AllowBasinOverlap
                            local=i_reduceMaxDist(local,length(local.FVAL));
                        end
                    end

                    LAMBDA=[LAMBDA.lower;LAMBDA.upper;LAMBDA.ineqlin;LAMBDA.eqlin;...
                    LAMBDA.ineqnonlin;LAMBDA.eqnonlin];
                    penWts=max([penWts,abs(LAMBDA)],[],2);

                elseif isempty(failedSolnInfo.EXITFLAG)



                    failedSolnInfo.X=Xthis;
                    failedSolnInfo.FVAL=FVALthis;
                    failedSolnInfo.EXITFLAG=EF;
                    failedSolnInfo.OUTPUT=OUTPUTthis;
                    failedSolnInfo.AllFailedLocalExitFlag=EF;

                else









                    failedSolnInfo.AllFailedLocalExitFlag=[failedSolnInfo.AllFailedLocalExitFlag,EF];


                    if EF==-10||failedSolnInfo.EXITFLAG==-10
                        ReplaceMinusTenSoln=EF>-10;
                        ReplaceFeasFailSoln=false;
                        ReplaceInfeasFailSoln=false;
                    else


                        ReplaceMinusTenSoln=false;


                        LocalTolCon=optimget(options,'TolCon');



                        failConViol=failedSolnInfo.OUTPUT.constrviolation;
                        newConViol=OUTPUTthis.constrviolation;



                        ReplaceFeasFailSoln=failConViol<=LocalTolCon&&...
                        newConViol<=LocalTolCon&&FVALthis<failedSolnInfo.FVAL;




                        ReplaceInfeasFailSoln=(failConViol>LocalTolCon&&...
                        (newConViol<=LocalTolCon||newConViol<failConViol));
                    end

                    if ReplaceMinusTenSoln||ReplaceFeasFailSoln||ReplaceInfeasFailSoln
                        failedSolnInfo.X=Xthis;
                        failedSolnInfo.FVAL=FVALthis;
                        failedSolnInfo.EXITFLAG=EF;
                        failedSolnInfo.OUTPUT=OUTPUTthis;
                    end
                end



                if isempty(Xthis)
                    solForDisp.X=Xthis;
                else
                    solForDisp.X=X;
                    solForDisp.X(:)=Xthis;
                end
                solForDisp.Fval=FVALthis;
                solForDisp.Exitflag=EF;

                function[X,FVAL]=i_retrieveSolution(local,failedSolnInfo,X)







                    if isempty(local.X)
                        if isempty(failedSolnInfo.X)
                            X=[];
                        else
                            X(:)=failedSolnInfo.X;
                        end
                        FVAL=failedSolnInfo.FVAL;
                    else
                        [FVAL,idx]=min(local.FVAL);
                        X(:)=local.X(:,idx);
                    end

                    function[EXITFLAG,OUTPUT]=i_createExitflagAndOutput(local,...
                        failedSolnInfo,timeStore,funcCount,localFuncCount,stop)

                        EXITFLAG=i_createExitflag(local,failedSolnInfo,timeStore,stop);
                        OUTPUT=i_createOUTPUT(funcCount,localFuncCount,...
                        EXITFLAG,local,timeStore.maxTime,failedSolnInfo);

                        function EXITFLAG=i_createExitflag(local,failedSolnInfo,timeStore,stop)

                            if stop




                                EXITFLAG=-1;

                            elseif etime(clock,timeStore.startTime)>=timeStore.maxTime


                                EXITFLAG=-5;

                            elseif isempty(local.X)








                                EXITFLAG=max(failedSolnInfo.AllFailedLocalExitFlag);





                                SetExitFlagToMinus8=...
                                EXITFLAG==-1||EXITFLAG==-3||...
                                (EXITFLAG==-2&&~all(failedSolnInfo.AllFailedLocalExitFlag==-2));
                                EXITFLAG(SetExitFlagToMinus8)=-8;

                            else

                                if local.LocalSolverCount.Total==sum(local.NumLocalSearch)
                                    EXITFLAG=1;
                                else
                                    EXITFLAG=2;
                                end

                            end

                            function OUTPUT=i_createOUTPUT(funcCount,localFuncCount,...
                                EXITFLAG,LOCAL,maxTime,failedSolnInfo)

                                OUTPUT.funcCount=funcCount+localFuncCount;
                                OUTPUT.localSolverTotal=LOCAL.LocalSolverCount.Total;
                                OUTPUT.localSolverSuccess=LOCAL.LocalSolverCount.PosEF;
                                OUTPUT.localSolverIncomplete=LOCAL.LocalSolverCount.ZeroEF;
                                OUTPUT.localSolverNoSolution=LOCAL.LocalSolverCount.NegEF;
                                OUTPUT.message=i_createExitMsg(EXITFLAG,OUTPUT,maxTime,failedSolnInfo);

                                function msg=i_createExitMsg(EXITFLAG,OUTPUT,maxTime,failedSolnInfo)


                                    switch EXITFLAG
                                    case 2
                                        msg1='GlobalSearch stopped because it analyzed all the trial points.';
                                        msg2=i_createSecondaryMsgEF2(OUTPUT);
                                    case 1
                                        msg1='GlobalSearch stopped because it analyzed all the trial points.';
                                        msg2=i_createSecondaryMsgEF1(OUTPUT);
                                    case 0
                                        msg1='GlobalSearch stopped with one or more of the local solver runs stopping prematurely.';
                                        msg2=i_createSecondaryMsgEF0(OUTPUT);
                                    case-1
                                        msg1='GlobalSearch stopped by the output or plot function.';
                                        msg2=i_createSecondaryMsgEFM1(OUTPUT,failedSolnInfo);
                                    case-2
                                        msg1='No feasible solution found.';
                                        msg2=i_createSecondaryMsgEFM2(OUTPUT);
                                    case-5
                                        msg1='GlobalSearch stopped because maximum time is exceeded.';
                                        msg2=i_createSecondaryMsgEFM5(OUTPUT,maxTime);
                                    case-8
                                        msg1='No solution found.';
                                        msg2=i_createSecondaryMsgEFM8(OUTPUT,failedSolnInfo);
                                    case-10
                                        msg1='GlobalSearch encountered failures in the user provided functions.';
                                        msg2=i_createSecondaryMsgEFM10(OUTPUT);
                                    otherwise
                                        error(message('globaloptim:globalsearchnlp:InvalidExitflag'));
                                    end


                                    msg=sprintf('%s\n\n%s',msg1,msg2);

                                    function[TrialSolutions,NumFunEvals]=i_returnScatterSearchPts(FUN,...
                                        X,LB,UB,NONLCON,NumIterStageOne,NumIterStageTwo,RefSetSize)



















                                        TotalIter=NumIterStageOne+NumIterStageTwo;
                                        ssOpts=globaloptim.globalsearch.SS_Optimset(...
                                        'Display','none',...
                                        'CombineMethod','hypercube',...
                                        'UsePointDatabase','on',...
                                        'RefSetType','tiered',...
                                        'GoodFraction',0.75,...
                                        'IntensifyPoint',200,...
                                        'IntensifyLength',20,...
                                        'MaxPointDatabaseSize',TotalIter,...
                                        'RefSetSize',RefSetSize);
                                        try
                                            [TrialSolutions,NumFunEvals]=globaloptim.globalsearch.SS_Main(FUN,X,LB,UB,NONLCON,ssOpts);

                                        catch

                                            numVars=numel(X);
                                            TrialSolutions=zeros(numVars,0);
                                            NumFunEvals=0;
                                        end


                                        function gap=i_FVAL_Gap(fNew,fExist)

                                            gap=abs(fNew-fExist);



                                            if abs(fExist)>1e-6
                                                gap=gap/abs(fExist);
                                            end

                                            function local=i_reduceMaxDist(local,chgIdx)







                                                nLocal=length(local.FVAL);
                                                distLocal=sqrt(globaloptim.internal.mexfiles.mx_distancepoints(local.X(:,chgIdx),local.X));
                                                idx=setdiff(1:nLocal,chgIdx);
                                                for i=idx
                                                    maxDist=[local.MaxDist(i),local.MaxDist(chgIdx)];
                                                    if distLocal(i)<local.MaxDist(i)+local.MaxDist(chgIdx)


                                                        [~,idxSmall]=min(maxDist);
                                                        idxBig=setdiff(1:2,idxSmall);



                                                        ratio=maxDist(idxSmall)/maxDist(idxBig);
                                                        newSmallDist=ratio*distLocal(i)/(1+ratio);



                                                        if newSmallDist<0.25*distLocal(i)
                                                            newSmallDist=min(0.25*distLocal(i),maxDist(idxSmall));
                                                        end


                                                        maxDist(idxSmall)=newSmallDist;
                                                        maxDist(idxBig)=distLocal(i)-newSmallDist;
                                                        local.MaxDist(i)=maxDist(1);
                                                        local.MaxDist(chgIdx)=maxDist(2);

                                                    end
                                                end

                                                function i_printIterativeDisplayHeader

                                                    fprintf('\n%8s %8s %11s %13s %12s %12s %12s %16s\n%8s %8s %11s %13s %12s %12s %12s %16s\n',...
                                                    'Num Pts','','Best','Current','Threshold','Local','Local','',...
                                                    'Analyzed','F-count','f(x)','Penalty','Penalty','f(x)','exitflag','Procedure');

                                                    function i_printIterativeDisplay(LineType,NumPts,LOCAL,...
                                                        failedSolnInfo,xOrigShape,globalFuncCount,localFuncCount,...
                                                        Penalty,Threshold,localSolForDisp)


                                                        [~,BestFval]=i_retrieveSolution(LOCAL,failedSolnInfo,xOrigShape);


                                                        TotalFuncCount=globalFuncCount+localFuncCount;


                                                        LocalFval=localSolForDisp.Fval;
                                                        LocalExitFlag=localSolForDisp.Exitflag;


                                                        switch LineType
                                                        case 'InitialPoint'
                                                            if LocalExitFlag==-10

                                                                FormatStr='%8d %8d %11s %12s %13s %12s %12d %16s\n';
                                                            else
                                                                FormatStr='%8d %8d %11.4g %12s %13s %12.4g %12d %16s\n';
                                                            end
                                                            Procedure='Initial Point';
                                                        case 'StageOneLocal'
                                                            if LocalExitFlag==-10
                                                                if isempty(BestFval)

                                                                    FormatStr='%8d %8d %11s %12s %13s %12s %12d %16s\n';
                                                                else

                                                                    FormatStr='%8d %8d %11.4g %12s %13s %12s %12d %16s\n';
                                                                end
                                                            else
                                                                FormatStr='%8d %8d %11.4g %12s %13s %12.4g %12d %16s\n';
                                                            end
                                                            Procedure='Stage 1 Local';
                                                        case 'StageTwoSearch'
                                                            if isempty(BestFval)

                                                                FormatStr='%8d %8d %11s %13.4g %12.4g %12s %13s %16s\n';
                                                            else
                                                                FormatStr='%8d %8d %11.4g %13.4g %12.4g %12s %13s %16s\n';
                                                            end
                                                            Procedure='Stage 2 Search';
                                                        case 'StageTwoLocal'
                                                            if LocalExitFlag==-10
                                                                if isempty(BestFval)

                                                                    FormatStr='%8d %8d %11s %13.4g %12.4g %12s %12d %16s\n';
                                                                else

                                                                    FormatStr='%8d %8d %11.4g %13.4g %12.4g %12s %12d %16s\n';
                                                                end
                                                            else
                                                                FormatStr='%8d %8d %11.4g %13.4g %12.4g %12.4g %12d %16s\n';
                                                            end
                                                            Procedure='Stage 2 Local';
                                                        end


                                                        fprintf(FormatStr,NumPts,TotalFuncCount,BestFval,Penalty,...
                                                        Threshold,LocalFval,LocalExitFlag,Procedure);

                                                        function i_printExitMsg(exitMsg)

                                                            fprintf('\n%s\n',exitMsg);

                                                            function SolVec=i_createSolutionVector(Local,xOrigShape)


                                                                if isempty(Local.FVAL)
                                                                    SolVec=GlobalOptimSolution.empty(1,0);
                                                                else
                                                                    nSol=length(Local.FVAL);
                                                                    SolVec(1:nSol)=GlobalOptimSolution;

                                                                    [~,idx]=sort(Local.FVAL);
                                                                    for i=1:length(idx)
                                                                        ThisXSol=xOrigShape;
                                                                        ThisX0=xOrigShape;
                                                                        ThisXSol(:)=Local.X(:,idx(i));
                                                                        ThisX0(:)=Local.X0{idx(i)}(:,1);
                                                                        numOtherX0=size(Local.X0{idx(i)},2)-1;
                                                                        ThisOtherX0=cell(1,numOtherX0);
                                                                        ThisOtherX0(:)={xOrigShape};
                                                                        for j=1:numOtherX0
                                                                            ThisOtherX0{j}(:)=Local.X0{idx(i)}(:,j+1);
                                                                        end
                                                                        SolVec(i)=GlobalOptimSolution(ThisXSol,Local.FVAL(idx(i)),...
                                                                        Local.EXITFLAG(idx(i)),Local.OUTPUT(idx(i)),ThisX0,ThisOtherX0);
                                                                    end
                                                                end

                                                                function isDone=i_isDone(timeStore,stop)



                                                                    isDone=stop||etime(clock,timeStore.startTime)>=timeStore.maxTime;

                                                                    function msg2=i_createSecondaryMsgEF2(OUTPUT)

                                                                        msg2=sprintf('%d out of %d local solver runs converged with a positive local solver exit flag.',...
                                                                        OUTPUT.localSolverSuccess,OUTPUT.localSolverTotal);

                                                                        function msg2=i_createSecondaryMsgEF1(OUTPUT)

                                                                            if OUTPUT.localSolverTotal==1
                                                                                msg2=sprintf('The local solver ran once and it converged with a positive local solver exit flag.');
                                                                            else
                                                                                msg2=sprintf('All %d local solver runs converged with a positive local solver exit flag.',...
                                                                                OUTPUT.localSolverTotal);
                                                                            end

                                                                            function msg2=i_createSecondaryMsgEF0(OUTPUT)

                                                                                if OUTPUT.localSolverTotal==1
                                                                                    msg2a=sprintf('The local solver ran once and it exceeded the ');
                                                                                else
                                                                                    msg2a=sprintf('%d out of %d local solver runs exceeded the ',...
                                                                                    OUTPUT.localSolverIncomplete,OUTPUT.localSolverTotal);
                                                                                end
                                                                                msg2b=sprintf(['iteration limit (problem.options.MaxIterations) or \n',...
                                                                                'the function evaluation limit (problem.options.MaxFunctionEvaluations).']);
                                                                                if OUTPUT.localSolverTotal==1
                                                                                    msg2c=sprintf(['\nThe local solver run did not converge '...
                                                                                    ,'with a positive local solver exit flag.']);
                                                                                else
                                                                                    msg2c=sprintf(['\nNone of the %d local solver runs converged '...
                                                                                    ,'with a positive local solver exit flag.'],OUTPUT.localSolverTotal);
                                                                                end
                                                                                msg2=[msg2a,msg2b,msg2c];

                                                                                function msg2=i_createSecondaryMsgEFM1(OUTPUT,failedSolnInfo)

                                                                                    if OUTPUT.localSolverTotal==0


                                                                                        msg2='GlobalSearch stopped before any calls to the local solver.';
                                                                                    elseif OUTPUT.localSolverSuccess>0&&OUTPUT.localSolverTotal~=OUTPUT.localSolverSuccess

                                                                                        msg2=i_createSecondaryMsgEF2(OUTPUT);
                                                                                    elseif OUTPUT.localSolverSuccess>0

                                                                                        msg2=i_createSecondaryMsgEF1(OUTPUT);
                                                                                    elseif OUTPUT.localSolverIncomplete>0

                                                                                        msg2=i_createSecondaryMsgEF0(OUTPUT);
                                                                                    elseif all(failedSolnInfo.AllFailedLocalExitFlag==-2)

                                                                                        msg2=i_createSecondaryMsgEFM2(OUTPUT);
                                                                                    elseif all(failedSolnInfo.AllFailedLocalExitFlag==-10)

                                                                                        msg2=i_createSecondaryMsgEFM10(OUTPUT);
                                                                                    else

                                                                                        msg2=i_createSecondaryMsgEFM8(OUTPUT,failedSolnInfo);
                                                                                    end

                                                                                    function msg2=i_createSecondaryMsgEFM2(OUTPUT)

                                                                                        if OUTPUT.localSolverTotal==1
                                                                                            msg2a=sprintf('GlobalSearch called the local solver once ');
                                                                                        else
                                                                                            msg2a=sprintf('GlobalSearch called the local solver %d times ',OUTPUT.localSolverTotal);
                                                                                        end
                                                                                        msg2b=sprintf(['and did not find a point that satisfies\n',...
                                                                                        'the constraints within the local solver constraint tolerance (problem.options.ConstraintTolerance).']);
                                                                                        msg2=[msg2a,msg2b];

                                                                                        function msg2=i_createSecondaryMsgEFM5(OUTPUT,maxTime)
                                                                                            if OUTPUT.localSolverTotal==1
                                                                                                msg2a=sprintf(['GlobalSearch called the local solver once before exceeding \n',...
                                                                                                'the clock time limit (MaxTime = %g seconds).\n'],maxTime);
                                                                                            else
                                                                                                msg2a=sprintf(['GlobalSearch called the local solver %d times before exceeding \n',...
                                                                                                'the clock time limit (MaxTime = %g seconds).\n'],...
                                                                                                OUTPUT.localSolverTotal,maxTime);
                                                                                            end
                                                                                            if OUTPUT.localSolverSuccess==1
                                                                                                msg2b=['1 local solver run converged with a positive ',...
                                                                                                'local solver exit flag.'];
                                                                                            else
                                                                                                msg2b=sprintf(['%d local solver runs converged with a ',...
                                                                                                'positive local solver exit flag.'],OUTPUT.localSolverSuccess);
                                                                                            end
                                                                                            msg2=[msg2a,msg2b];

                                                                                            function msg2=i_createSecondaryMsgEFM8(OUTPUT,failedSolnInfo)

                                                                                                if OUTPUT.localSolverTotal==1
                                                                                                    msg2a=sprintf('GlobalSearch did not find a solution after 1 local solver run.');
                                                                                                else
                                                                                                    msg2a=sprintf('GlobalSearch did not find any solutions after %d local solver runs.',...
                                                                                                    OUTPUT.localSolverTotal);
                                                                                                end
                                                                                                isLocalStop=failedSolnInfo.AllFailedLocalExitFlag==-1;
                                                                                                numLocalStop=sum(isLocalStop(:));
                                                                                                if numLocalStop==1
                                                                                                    msg2b=sprintf('\n1 local solver run was stopped by the local output or plot function');
                                                                                                elseif numLocalStop>0
                                                                                                    msg2b=sprintf('\n%d local solver runs were stopped by the local output or plot function',...
                                                                                                    numLocalStop);
                                                                                                else
                                                                                                    msg2b='';
                                                                                                end

                                                                                                msg2=[msg2a,msg2b];

                                                                                                function msg2=i_createSecondaryMsgEFM10(OUTPUT)

                                                                                                    if OUTPUT.localSolverTotal==1
                                                                                                        msg2=sprintf(['The local solver ran once and it failed in ',...
                                                                                                        'a user supplied function.']);
                                                                                                    else
                                                                                                        msg2=sprintf(['All %d local solver runs failed in a user supplied ',...
                                                                                                        'function.'],OUTPUT.localSolverTotal);
                                                                                                    end

                                                                                                    function[X,FVAL,EXITFLAG,OUTPUT,SOLUTIONSET]=i_doFinishTasks(...
                                                                                                        xOrigShape,LOCAL,failedSolnInfo,localSolForDisp,funcCount,...
                                                                                                        localFuncCount,timeStore,stop,options,nOutputs,verbosity)



                                                                                                        [X,FVAL]=i_retrieveSolution(LOCAL,failedSolnInfo,xOrigShape);
                                                                                                        [EXITFLAG,OUTPUT]=i_createExitflagAndOutput(LOCAL,failedSolnInfo,...
                                                                                                        timeStore,funcCount,localFuncCount,stop);



                                                                                                        if verbosity>0
                                                                                                            i_printExitMsg(OUTPUT.message);
                                                                                                        end
                                                                                                        if~isempty(options.OutputFcns)||~isempty(options.PlotFcns)
                                                                                                            optimValues=i_updateOptimValues(localSolForDisp,...
                                                                                                            OUTPUT.localSolverTotal,OUTPUT.funcCount,X,FVAL);
                                                                                                            globaloptim.internal.callOutputAndPlotFcns(options,optimValues,'done','GlobalSearch');
                                                                                                        end


                                                                                                        if nOutputs==5
                                                                                                            SOLUTIONSET=i_createSolutionVector(LOCAL,xOrigShape);
                                                                                                        else
                                                                                                            SOLUTIONSET=[];
                                                                                                        end

                                                                                                        function optimValues=i_updateOptimValues(localSolution,...
                                                                                                            localRunIndex,funcCount,bestX,bestFval)

                                                                                                            optimValues.localsolution=localSolution;
                                                                                                            optimValues.localrunindex=localRunIndex;
                                                                                                            optimValues.funccount=funcCount;
                                                                                                            optimValues.bestx=bestX;
                                                                                                            optimValues.bestfval=bestFval;
