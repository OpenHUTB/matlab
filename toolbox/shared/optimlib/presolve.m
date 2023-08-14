function[H,f,Aineq,bineq,Aeq,beq,lb,ub,transforms,restoreData,exitflag,msg]=...
    presolve(H,f,Aineq,bineq,Aeq,beq,lb,ub,options,computeLambda,requestedTransforms,makeExitMsg)





































































































    if nargin<12
        makeExitMsg=true;
        if nargin<11

            requestedTransforms=[1:4,6:9,12]';
            if nargin<10
                computeLambda=true;
                if nargin<9
                    options=[];
                    if nargin<8
                        error(message('optimlib:presolve:notEnoughInputs'));
                    end
                end
            end
        end
    end


    defaultopt.Display='final';
    defaultopt.TolCon=1e-8;



    if isscalar(requestedTransforms)&&(requestedTransforms==0)
        requestedTransforms=[];
    elseif isempty(requestedTransforms)


        requestedTransforms=[1:4,6:9,12]';
    end
    transformsToPerform=false(12,1);
    transformsToPerform(requestedTransforms)=true;


    nVar=size(f,1);
    mEq=size(Aeq,1);
    mIneq=size(Aineq,1);

    nVarOrig=nVar;
    mEqOrig=mEq;
    mIneqOrig=mIneq;


    xtraVerbose=false;
    testingDisp=false;
    iterDisp=false;
    finalDisp=false;

    display=optimget(options,'Display',defaultopt,'fast');
    if strcmpi(display,'testing')
        testingDisp=true;
        iterDisp=true;
        finalDisp=true;
    elseif strcmpi(display,'iter')
        iterDisp=true;
        finalDisp=true;
    elseif strcmpi(display,'final')
        finalDisp=true;
    end

    if testingDisp
        fprintf('Presolve start:\n')
        fprintf('Variables  Equalities Inequalities\n');
        fprintf(' %6i    %6i    %6i\n',nVar,mEq,mIneq);
    end


    restoreData.nVarOrig=nVar;
    restoreData.mEqOrig=mEq;
    restoreData.mIneqOrig=mIneq;





    varsInProblem=uint32((1:nVar)');



    tolCon=optimget(options,'TolCon',defaultopt,'fast');




    tolZero=max(eps,1e-2*tolCon);

    tolBndShift=tolCon;


    tolDuplicate=max(eps,1e-4*tolCon);

    tolFixed=tolZero;




    MaxPasses=20000;
    MaxBndTightens=5;

    if isempty(Aineq)
        Aineq=sparse(0,nVar);
        bineq=reshape(bineq,0,1);
    elseif~issparse(Aineq)
        Aineq=sparse(Aineq);
    end
    if isempty(Aeq)
        Aeq=sparse(0,nVar);
        beq=reshape(beq,0,1);
    elseif~issparse(Aeq)
        Aeq=sparse(Aeq);
    end

    [nnzAineqCols,nnzAineqRows]=getNNZcounts(Aineq);
    [nnzAeqCols,nnzAeqRows]=getNNZcounts(Aeq);


    isLP=isempty(H);
    if isLP
        linearVars=true(nVar,1);
        H=sparse(0,nVar);
    else
        if~issparse(H)
            H=sparse(H);
        end
        linearVars=(getNNZcounts(H,2)==0);
    end




    impliedLowerBounded=false(nVar,1);
    impliedUpperBounded=false(nVar,1);





    transforms=[];

    if computeLambda





        ineqsInProblem=uint32((1:mIneq)');
        eqsInProblem=uint32((1:mEq)');
    else
        ineqsInProblem=[];
        eqsInProblem=[];
    end



    solvedProb=false;
    infeasProb=false;
    unboundedProb=false;


    exitflag=[];msg='';


    done=false;
    transformIdx=1;
    passes=1;



    if transformsToPerform(12)
        infiniteRHS();
    end


    feasRelFactor=max(1,max(norm(beq,Inf),norm(bineq,Inf)));


    while~done&&(passes<=MaxPasses)
        done=true;


        if transformsToPerform(1)
            fixVarsEqBnds();
            if unboundedProb||solvedProb
                break;
            end
        end


        if transformsToPerform(2)
            singletonIneqs();
            if infeasProb
                break;
            end
        end


        if transformsToPerform(3)
            singletonEqs();
            if infeasProb||unboundedProb||solvedProb
                break;
            end
        end


        if transformsToPerform(4)
            emptyRows();
            if infeasProb
                break;
            end
        end


        if transformsToPerform(5)&&passes<=MaxBndTightens
            compImpliedBnds();
            if infeasProb
                break;
            end
        end


        if transformsToPerform(6)
            forcingRedundantConstr();
            if infeasProb||unboundedProb||solvedProb
                break;
            end
        end


        if transformsToPerform(7)
            dbltnEqualities();
            if infeasProb
                break;
            end
        end


        if transformsToPerform(8)
            freeLinearColumnSingletons();
            if unboundedProb||solvedProb
                break;
            end
        end


        if transformsToPerform(9)
            unconstrVars();
            if unboundedProb||solvedProb
                break;
            end
        end

        passes=passes+1;
    end




    if transformsToPerform(10)&&~(infeasProb||unboundedProb||solvedProb)
        duplicateEqs();
    end

    if transformsToPerform(11)&&~(infeasProb||unboundedProb||solvedProb)
        scaleProblem();
    end


    restoreData.varsInProblem=varsInProblem;
    restoreData.ineqsInProblem=ineqsInProblem;
    restoreData.eqsInProblem=eqsInProblem;

    msgData={};
    if solvedProb
        exitflag=1;
        msgData={{'optimlib:presolve:Exit1basic'},{},finalDisp,false};
    elseif infeasProb
        exitflag=-2;
        msgData={{'optimlib:presolve:ExitNeg21basic','quadprog'},{},finalDisp,false};
    elseif unboundedProb
        exitflag=-3;
        msgData={{'optimlib:presolve:ExitNeg3basic','quadprog'},{},finalDisp,false};
    end

    if~isempty(msgData)&&makeExitMsg
        msg=createExitMsg(msgData{:});
    end

    if iterDisp&&isempty(exitflag)
        nVar=size(f,1);
        mEq=size(Aeq,1);
        mIneq=size(Aineq,1);

        if testingDisp
            fprintf('Presolve End:\n')
            fprintf('Variables  Equalities Inequalities\n');
            fprintf(' %6i    %6i    %6i\n',nVar,mEq,mIneq);
        end

        nVarDiff=nVarOrig-nVar;
        mEqDiff=mEqOrig-mEq;
        mIneqDiff=mIneqOrig-mIneq;
        if nVarDiff+mEqDiff+mIneqDiff>0
            fprintf(['Solved %i variables, %i equality, and %i inequality ',...
            'constraints during the presolve.\n'],nVarDiff,mEqDiff,mIneqDiff);
        end
    end


    function infiniteRHS()



        infRHS=isinf(bineq);
        if any(infRHS)

            if any(bineq(infRHS)<0)







                error(message('optimlib:presolve:NegInfDetectedIneq'));
            end

            if computeLambda


                forcingStruct.redundantIneqIdx=ineqsInProblem(infRHS);
                ineqsInProblem(infRHS)=[];
            else
                forcingStruct=[];
            end



            nnzAineqCols=nnzAineqCols-getNNZcounts(Aineq(infRHS,:),2);


            nnzAineqRows(infRHS,:)=[];


            Aineq(infRHS,:)=[];
            bineq(infRHS,:)=[];

            if testingDisp
                fprintf('Removing %i redundant inequality constraints\n',...
                sum(infRHS));
            end

            emptyColVec=zeros(0,1);
            pushTransformOnStack(12,uint32(emptyColVec),emptyColVec,forcingStruct);
        end

        if any(isinf(beq))
            error(message('optimlib:presolve:InfDetectedEq'));
        end

    end


    function fixVarsEqBnds
        fixed=abs(lb-ub)<tolFixed*max(1,max(abs(lb),abs(ub)));
        if any(fixed)
            if testingDisp
                fprintf('Fixing %i variables at equal bounds\n',sum(fixed));
                if xtraVerbose
                    fprintf('Variables fixed:\n');
                    disp(varsInProblem(fixed)');
                end
            end

            fixVariables(1,lb(fixed),fixed,[],[]);
            done=false;
        end
    end


    function singletonIneqs
        singletonRows=(nnzAineqRows==1);
        if any(singletonRows)

            [snglRows,snglCols,coefs]=find(Aineq(singletonRows,:));




            bsngl=bineq(singletonRows);
            isLB=coefs<0;
            tightenedIdx=tightenBounds(bsngl(snglRows)./coefs,isLB,snglCols);
            if infeasProb
                return
            end


            Aineq(singletonRows,:)=[];
            bineq(singletonRows,:)=[];
            nnzAineqRows(singletonRows,:)=[];



            nnzAineqCols=getNNZcounts(Aineq,2);



            if computeLambda

                singletonRowsIdx=find(singletonRows);



                tightenedLbIdx=tightenedIdx&isLB(:);
                tightenedUbIdx=tightenedIdx&~isLB(:);
                sngltnIneqStruct.tightenedLbIdx=varsInProblem(snglCols(tightenedLbIdx));
                sngltnIneqStruct.tightenedUbIdx=varsInProblem(snglCols(tightenedUbIdx));
                sngltnIneqStruct.lbImpliedConstrIdx=ineqsInProblem(singletonRowsIdx(snglRows(tightenedLbIdx)));
                sngltnIneqStruct.ubImpliedConstrIdx=ineqsInProblem(singletonRowsIdx(snglRows(tightenedUbIdx)));

                sngltnIneqStruct.lbImpliedConstrCoefs=coefs(tightenedLbIdx);
                sngltnIneqStruct.ubImpliedConstrCoefs=coefs(tightenedUbIdx);



                sngltnIneqStruct.untightenedIdx=ineqsInProblem(singletonRowsIdx(snglRows(~tightenedIdx)));
                ineqsInProblem(singletonRows,:)=[];
                pushTransformOnStack(2,[],[],sngltnIneqStruct)
            end
            if testingDisp
                fprintf('Removing %i singleton ineq rows\n',sum(singletonRows));
                if xtraVerbose
                    fprintf('Tightened lower bounds on variables\n');
                    disp(varsInProblem(snglCols(tightenedIdx&isLB))');
                    fprintf('Tightened upper bounds on variables\n');
                    disp(varsInProblem(snglCols(tightenedIdx&~isLB))');
                end
            end
            done=false;
        end
    end


    function singletonEqs
        singletonRows=(nnzAeqRows==1);
        if any(singletonRows)

            [snglRows,snglCols,coefs]=find(Aeq(singletonRows,:));

            beqSngl=beq(singletonRows);
            xFixedEqSngl=beqSngl(snglRows)./coefs;


            repeats=(diff([0;snglCols])==0);
            if any(repeats)
                repeatedCols=unique(snglCols(repeats));


                for k=1:length(repeatedCols)
                    logicWorkVec=(snglCols==repeatedCols(k));
                    xTemp=xFixedEqSngl(logicWorkVec);
                    xMin=min(xTemp);xMax=max(xTemp);
                    if abs(xMax-xMin)>tolFixed*max(1,abs((xMax+xMin)/2))
                        if testingDisp
                            fprintf('Infeasibility detected: eq singleton dup cols\n');
                        end
                        infeasProb=true;
                        return
                    end
                end


                snglCols=snglCols(~repeats);
                xFixedEqSngl=xFixedEqSngl(~repeats);
            end


            if any((xFixedEqSngl-lb(snglCols)<-tolZero.*max(abs(xFixedEqSngl),1))|...
                (xFixedEqSngl-ub(snglCols)>tolZero.*max(abs(xFixedEqSngl),1)))
                if testingDisp
                    fprintf('Infeasibility detected: eq singleton out of bnds\n');
                end
                infeasProb=true;
                return
            end


            Aeq(singletonRows,:)=[];
            beq(singletonRows,:)=[];

            nnzAeqRows(singletonRows,:)=[];


            if computeLambda
                singletonRowsIdx=find(singletonRows);

                sngltnEqStruct.constrIdx=eqsInProblem(singletonRowsIdx(snglRows(~repeats)));
                sngltnEqStruct.coefs=coefs(~repeats);
                sngltnEqStruct.repeats=eqsInProblem(singletonRowsIdx(snglRows(repeats)));
                eqsInProblem(singletonRows,:)=[];







            else
                sngltnEqStruct=[];
            end

            if testingDisp
                fprintf('Removing %i singleton eq rows\n',length(snglRows));
                if xtraVerbose
                    fprintf('Variables fixed:\n');
                    disp(varsInProblem(snglCols)');
                end
            end

            fixVariables(3,xFixedEqSngl,[],snglCols,sngltnEqStruct);
            done=false;
        end
    end


    function emptyRows



        emptyRowStruct.eqIdx=[];
        emptyRowStruct.ineqIdx=[];
        zeroRows=(nnzAineqRows==0);
        if any(bineq(zeroRows)<-tolCon)
            if testingDisp
                fprintf('Infeasibility detected: ineq zero rows\n');
            end
            infeasProb=true;
            return
        end

        if any(zeroRows)
            if testingDisp
                fprintf('Removing %i zero ineq rows\n',sum(full(zeroRows)));
            end
            Aineq(zeroRows,:)=[];
            bineq(zeroRows,:)=[];
            nnzAineqRows(zeroRows,:)=[];
            if computeLambda
                emptyRowStruct.ineqIdx=ineqsInProblem(zeroRows);
                ineqsInProblem(zeroRows)=[];
            end
            done=false;
        end

        zeroRows=(nnzAeqRows==0);
        if any(abs(beq(zeroRows))>tolCon)
            if testingDisp
                fprintf('Infeasibility detected: eq zero row\n');
            end
            infeasProb=true;
            return
        end

        if any(zeroRows)
            if testingDisp
                fprintf('Removing %i eq zero rows\n',sum(full(zeroRows)));
            end
            Aeq(zeroRows,:)=[];
            beq(zeroRows,:)=[];
            nnzAeqRows(zeroRows)=[];
            if computeLambda
                emptyRowStruct.eqIdx=eqsInProblem(zeroRows);
                eqsInProblem(zeroRows)=[];
            end
            done=false;
        end

        if computeLambda&&(~isempty(emptyRowStruct.eqIdx)||~isempty(emptyRowStruct.ineqIdx))
            pushTransformOnStack(4,[],[],emptyRowStruct)
        end
    end


    function compImpliedBnds
















        if~isempty(Aeq)
            [eqImpliedLB,eqImpliedUB]=constrImpliedBoundaries(Aeq,lb,ub);

            if any(eqImpliedLB-beq>=tolBndShift)||any(eqImpliedUB-beq<=-tolBndShift)
                if testingDisp
                    fprintf('Infeasibility detected in computing implied bounds: eq infeasible\n');
                end
                infeasProb=true;
                return
            end
            isImpliedLBfinite=isfinite(eqImpliedLB);
            isImpliedUBfinite=isfinite(eqImpliedUB);
            if any(isImpliedLBfinite|isImpliedUBfinite)
                [rows,cols,coefs]=find(Aeq);



                rows=rows(:);cols=cols(:);coefs=coefs(:);
                isCoefPos=coefs>0;


                isImpliedLBfinite=isImpliedLBfinite(rows);
                isImpliedUBfinite=isImpliedUBfinite(rows);











                impliedLBBounds=zeros(numel(coefs),1);
                impliedLBBounds(isCoefPos)=lb(cols(isCoefPos));
                impliedLBBounds(~isCoefPos)=ub(cols(~isCoefPos));
                impliedLBBounds=impliedLBBounds+(beq(rows)-eqImpliedLB(rows))./coefs;

                impliedUBBounds=zeros(size(coefs,1),1);
                impliedUBBounds(isCoefPos)=ub(cols(isCoefPos));
                impliedUBBounds(~isCoefPos)=lb(cols(~isCoefPos));
                impliedUBBounds=impliedUBBounds+(beq(rows)-eqImpliedUB(rows))./coefs;



                isLB=[~isCoefPos(isImpliedLBfinite);isCoefPos(isImpliedUBfinite)];
                impliedBndVarIdx=[cols(isImpliedLBfinite);cols(isImpliedUBfinite)];
                impliedBndConstrIdx=[rows(isImpliedLBfinite);rows(isImpliedUBfinite)];
                impliedBnds=[impliedLBBounds(isImpliedLBfinite);impliedUBBounds(isImpliedUBfinite)];
                tightenedIdx=tightenBounds(impliedBnds,isLB,impliedBndVarIdx);
                if infeasProb
                    return
                end

                if any(tightenedIdx)

                    tightenedLbIdx=isLB&tightenedIdx;
                    tightenedUbIdx=~isLB&tightenedIdx;
                    impliedLowerBounded(impliedBndVarIdx(tightenedLbIdx))=true;
                    impliedUpperBounded(impliedBndVarIdx(tightenedUbIdx))=true;

                    if computeLambda














                        domConstrStruct.tightenedLbIdx=varsInProblem(impliedBndVarIdx(tightenedLbIdx));
                        domConstrStruct.tightenedUbIdx=varsInProblem(impliedBndVarIdx(tightenedUbIdx));
                        domConstrStruct.lbImpliedConstrIdx=eqsInProblem(impliedBndConstrIdx(tightenedLbIdx));
                        domConstrStruct.ubImpliedConstrIdx=eqsInProblem(impliedBndConstrIdx(tightenedUbIdx));
                    end
                    if testingDisp
                        fprintf('Tightening %i lower and %i upper bounds via equality constraints\n',...
                        sum(tightenedLbIdx),sum(tightenedUbIdx));
                        if xtraVerbose
                            fprintf('Tightened lower bounds on variables\n');
                            disp(varsInProblem(impliedBndVarIdx(tightenedLbIdx))');
                            fprintf('Tightened upper bounds on variables\n');
                            disp(varsInProblem(impliedBndVarIdx(tightenedUbIdx))');
                        end
                    end
                    done=false;
                end
            end
        end

        if~isempty(Aineq)

            [ineqImpliedLB,~]=constrImpliedBoundaries(Aineq,lb,ub);

            if any(ineqImpliedLB-bineq>=tolBndShift)
                if testingDisp
                    fprintf('Infeasibility detected in computing implied bounds: ineq infeasible\n');
                end
                infeasProb=true;
                return
            end

            isImpliedLBfinite=isfinite(ineqImpliedLB);
            if any(isImpliedLBfinite)
                [rows,cols,coefs]=find(Aineq);



                rows=rows(:);cols=cols(:);coefs=coefs(:);
                isCoefPos=coefs>0;












                impliedBounds=zeros(numel(coefs),1);
                impliedBounds(isCoefPos)=lb(cols(isCoefPos));
                impliedBounds(~isCoefPos)=ub(cols(~isCoefPos));

                impliedBounds=impliedBounds+(bineq(rows)-ineqImpliedLB(rows))./coefs;


                isImpliedLBfinite=isImpliedLBfinite(rows);

                isLB=~isCoefPos(isImpliedLBfinite);
                impliedBndVarIdx=cols(isImpliedLBfinite);
                impliedBndConstrIdx=rows(isImpliedLBfinite);
                tightenedIdx=tightenBounds(impliedBounds(isImpliedLBfinite),isLB,impliedBndVarIdx);
                if infeasProb
                    return
                end

                if any(tightenedIdx)

                    tightenedLbIdx=isLB(:)&tightenedIdx;
                    tightenedUbIdx=~isLB(:)&tightenedIdx;
                    impliedLowerBounded(impliedBndVarIdx(tightenedLbIdx))=true;
                    impliedUpperBounded(impliedBndVarIdx(tightenedUbIdx))=true;

                    if computeLambda













                        domConstrStruct.tightenedLbIdx=varsInProblem(impliedBndVarIdx(tightenedLbIdx));
                        domConstrStruct.tightenedUbIdx=varsInProblem(impliedBndVarIdx(tightenedUbIdx));

                        domConstrStruct.lbImpliedConstrIdx=ineqsInProblem(impliedBndConstrIdx(tightenedLbIdx));
                        domConstrStruct.ubImpliedConstrIdx=ineqsInProblem(impliedBndConstrIdx(tightenedUbIdx));










                        [impliedBndConstrIdx,idx]=sort(impliedBndConstrIdx);
                        impliedBndVarIdx=impliedBndVarIdx(idx);
                        tightenedLbIdx=tightenedLbIdx(idx);
                        tightenedUbIdx=tightenedUbIdx(idx);
                        coefs=coefs(isImpliedLBfinite);
                        coefs=coefs(idx);







                    end
                    if testingDisp
                        fprintf('Tightening %i lower and %i upper bounds via inequality constraints\n',...
                        sum(tightenedLbIdx),sum(tightenedUbIdx));
                        if xtraVerbose
                            fprintf('Tightened lower bounds on variables\n');
                            disp(varsInProblem(impliedBndVarIdx(tightenedLbIdx))');
                            fprintf('Tightened upper bounds on variables\n');
                            disp(varsInProblem(impliedBndVarIdx(tightenedUbIdx))');
                        end
                    end
                    done=false;
                end
            end
        end
    end


    function forcingRedundantConstr








        varFixedToUB=false(1,nVar);
        varFixedToLB=false(1,nVar);



        eqForcingConstr=[];
        eqLowerForcingConstr=[];
        ineqForcingConstr=[];
        redundantConstr=[];


        forcingStruct.coefs=[];
        forcingStruct.nnzForcingRows=[];
        forcingStruct.lowerForcingConstr=[];
        forcingStruct.lambdaIdx=[];

        if~isempty(Aeq)

            [eqImpliedLB,eqImpliedUB]=constrImpliedBoundaries(Aeq,lb,ub);





            eqRelTol=tolZero.*max(abs(beq),1);
            if any(eqImpliedLB-beq>eqRelTol)||...
                any(eqImpliedUB-beq<-eqRelTol)
                if testingDisp
                    fprintf('Infeasibility detected in forcing constr check: eq infeasible\n');
                end
                infeasProb=true;
                return
            end


            eqLowerForcingConstr=(abs(eqImpliedLB-beq)<=eqRelTol);
            eqUpperForcingConstr=(abs(eqImpliedUB-beq)<=eqRelTol);
            eqForcingConstr=eqLowerForcingConstr|eqUpperForcingConstr;
            if any(eqForcingConstr)







                if any((abs(ub-lb)>tolZero)&any(Aeq((abs(eqImpliedUB-eqImpliedLB)<tolZero),:),1)')
                    if testingDisp
                        fprintf('Infeasibility detected: eq forcing\n');
                    end
                    infeasProb=true;
                    return
                end
                varFixedToUB=any(Aeq(eqLowerForcingConstr,:)<0,1)|...
                any(Aeq(eqUpperForcingConstr,:)>0,1);
                varFixedToLB=any(Aeq(eqLowerForcingConstr,:)>0,1)|...
                any(Aeq(eqUpperForcingConstr,:)<0,1);

                done=false;
            end
        end

        if~isempty(Aineq)

            [ineqImpliedLB,ineqImpliedUB]=constrImpliedBoundaries(Aineq,lb,ub);






            ineqRelTol=tolZero.*max(abs(bineq),1);
            if any(ineqImpliedLB-bineq>ineqRelTol)
                if testingDisp
                    fprintf('Infeasibility detected: ineq infeasible\n');
                end
                infeasProb=true;
                return
            end


            redundantConstr=(ineqImpliedUB-bineq<0);
            ineqForcingConstr=(abs(ineqImpliedLB-bineq)<=ineqRelTol);
            if any(ineqForcingConstr)||any(redundantConstr)


                if any((abs(ub-lb)>tolFixed*max(1,max(abs(lb),abs(ub))))&...
                    any(Aineq((abs(ineqImpliedUB-ineqImpliedLB)<tolZero),:),1)')
                    if testingDisp
                        fprintf('Infeasibility detected: ineq forcing constr\n');
                    end
                    infeasProb=true;
                    return
                end


                varFixedToUB=varFixedToUB|any(Aineq(ineqForcingConstr,:)<0,1);
                varFixedToLB=varFixedToLB|any(Aineq(ineqForcingConstr,:)>0,1);

                done=false;
            end
        end

        if any(varFixedToUB|varFixedToLB)||any(redundantConstr)


            varFixedToBothBnds=varFixedToUB(:)&varFixedToLB(:);
            if any((abs(ub-lb)>tolFixed*max(1,max(abs(lb),abs(ub))))&...
                varFixedToBothBnds)
                if testingDisp
                    fprintf('Infeasibility detected: forcing constr\n');
                end
                infeasProb=true;
                return
            end


            varFixedToUB(varFixedToBothBnds)=false;

            fixedVarIdx=varFixedToUB|varFixedToLB;
            if computeLambda


                [forcingStruct.lambdaIdx,~,forcingStruct.coefs]=...
                find(Aeq(eqForcingConstr,fixedVarIdx)');


                [idx,~,ineqCoefs]=find(Aineq(ineqForcingConstr,fixedVarIdx)');
                forcingStruct.coefs=[forcingStruct.coefs;
                ineqCoefs];
                forcingStruct.lambdaIdx=[forcingStruct.lambdaIdx;
                idx];


                forcingStruct.nnzForcingRows=[nnzAeqRows(eqForcingConstr);
                nnzAineqRows(ineqForcingConstr)];


                forcingStruct.lowerForcingConstr=[eqLowerForcingConstr(eqForcingConstr);
                false(sum(ineqForcingConstr),1)];

                forcingStruct.eqIdx=eqsInProblem(eqForcingConstr);
                eqsInProblem(eqForcingConstr)=[];
                forcingStruct.ineqIdx=ineqsInProblem(ineqForcingConstr);
                forcingStruct.redundantIneqIdx=ineqsInProblem(redundantConstr);
                ineqsInProblem(ineqForcingConstr|redundantConstr)=[];

                forcingStruct.varFixedToLB=varFixedToLB(fixedVarIdx);
            end




            nnzAineqCols=nnzAineqCols-getNNZcounts(Aineq(redundantConstr,:),2);


            nnzAeqRows(eqForcingConstr,:)=[];
            nnzAineqRows(ineqForcingConstr|redundantConstr,:)=[];


            Aeq(eqForcingConstr,:)=[];
            beq(eqForcingConstr,:)=[];
            Aineq(ineqForcingConstr|redundantConstr,:)=[];
            bineq(ineqForcingConstr|redundantConstr,:)=[];



            xFixed=[lb(varFixedToLB);ub(varFixedToUB)];

            [~,idx]=sort([find(varFixedToLB(:));find(varFixedToUB(:))]);

            if testingDisp
                fprintf('Removing %i forcing equalities, %i forcing and %i redundant inequality constraints\n',...
                sum(eqForcingConstr),sum(ineqForcingConstr),sum(redundantConstr));
                if xtraVerbose
                    fprintf('Variables fixed:\n');
                    disp(varsInProblem(fixedVarIdx)');
                end
            end

            fixVariables(6,xFixed(idx),fixedVarIdx,[],forcingStruct);
        end
    end


    function dbltnEqualities











        if any(linearVars)&&~isempty(Aeq)

            totalConstrPerVar=nnzAeqCols+nnzAineqCols;


            linearSnglVars=linearVars&(totalConstrPerVar==1)&...
            ~(impliedLowerBounded&impliedUpperBounded)&(isfinite(lb)|isfinite(ub));



            if any(nnzAeqCols(linearSnglVars)>0)






                linSnglVarIdx=find(linearSnglVars);


                doubletonEqs=(nnzAeqRows==2);
                if any(doubletonEqs)
                    AeqDbltn=Aeq(doubletonEqs,:);
                    beqDbltn=beq(doubletonEqs);

                    [rows,cols,linSnglVarsCoefs]=find(AeqDbltn(:,linearSnglVars));

                    if~isempty(rows)





















                        logicWorkVec=(diff([0;cols(:)])~=0);
                        rows=rows(logicWorkVec);
                        cols=cols(logicWorkVec);
                        linSnglVarsCoefs=linSnglVarsCoefs(logicWorkVec);


                        [rows,idx]=sort(rows(:));
                        cols=cols(idx);
                        linSnglVarsCoefs=linSnglVarsCoefs(idx);
                        logicWorkVec=(diff([0;rows])~=0);


                        rows=rows(logicWorkVec);
                        cols=cols(logicWorkVec);
                        linSnglVarsCoefs=linSnglVarsCoefs(logicWorkVec);


                        freedVarIdx=linSnglVarIdx(cols);





                        impliedLowerBounded(freedVarIdx)=true;
                        impliedUpperBounded(freedVarIdx)=true;



                        logicWorkVec=true(nVar,1);
                        logicWorkVec(freedVarIdx)=false;


                        impliedBndVars=(1:nVar)';

                        impliedBndVars=impliedBndVars(logicWorkVec);


                        [cols,~,otherVarsCoefs]=find(AeqDbltn(rows,logicWorkVec)');

                        cols=cols(:);
                        otherVarsCoefs=otherVarsCoefs(:);


                        impliedBndVarIdx=impliedBndVars(cols);




                        impliedBounds=[(beqDbltn(rows)-linSnglVarsCoefs.*lb(freedVarIdx))./otherVarsCoefs;...
                        (beqDbltn(rows)-linSnglVarsCoefs.*ub(freedVarIdx))./otherVarsCoefs];




                        isLowerBound=(linSnglVarsCoefs.*otherVarsCoefs<0);

                        nFreedVars=length(freedVarIdx);
                        isLowerBound=[isLowerBound;~isLowerBound];
                        impliedBndVarIdx=[impliedBndVarIdx;impliedBndVarIdx];
                        freedVarIdx=[freedVarIdx(:);freedVarIdx(:)];
                        tightenedIdx=tightenBounds(impliedBounds,isLowerBound,impliedBndVarIdx);
                        if infeasProb
                            return
                        end

                        if any(tightenedIdx)
                            done=false;

                            if computeLambda

                                tightenedLbIdx=tightenedIdx&isLowerBound;
                                tightenedUbIdx=tightenedIdx&~isLowerBound;


                                dbltnEqIdx=find(doubletonEqs);












                                impliedBndConstrIdx=[dbltnEqIdx(rows);dbltnEqIdx(rows)];

                                linSnglVarsCoefs=[linSnglVarsCoefs;linSnglVarsCoefs];
                                otherVarsCoefs=[otherVarsCoefs;otherVarsCoefs];

                                dbltnEqStruct.tightenedLbIdx=varsInProblem(impliedBndVarIdx(tightenedLbIdx));
                                dbltnEqStruct.tightenedUbIdx=varsInProblem(impliedBndVarIdx(tightenedUbIdx));

                                dbltnEqStruct.lbFreedVarIdx=varsInProblem(freedVarIdx(tightenedLbIdx));
                                dbltnEqStruct.ubFreedVarIdx=varsInProblem(freedVarIdx(tightenedUbIdx));

                                dbltnEqStruct.lbImpliedConstrIdx=eqsInProblem(impliedBndConstrIdx(tightenedLbIdx));
                                dbltnEqStruct.ubImpliedConstrIdx=eqsInProblem(impliedBndConstrIdx(tightenedUbIdx));

                                dbltnEqStruct.lbFreedVarConstrCoefs=linSnglVarsCoefs(tightenedLbIdx);
                                dbltnEqStruct.ubFreedVarConstrCoefs=linSnglVarsCoefs(tightenedUbIdx);

                                dbltnEqStruct.lbImpliedConstrCoefs=otherVarsCoefs(tightenedLbIdx);
                                dbltnEqStruct.ubImpliedConstrCoefs=otherVarsCoefs(tightenedUbIdx);


                                dbltnEqStruct.dbltnEqIdx=eqsInProblem(impliedBndConstrIdx(1:nFreedVars));

                                pushTransformOnStack(7,...
                                [varsInProblem(freedVarIdx(1:nFreedVars));varsInProblem(impliedBndVarIdx(1:nFreedVars))],...
                                [],dbltnEqStruct);
                            end

                            if testingDisp
                                fprintf('Freeing %i variables using doubleton equalities\n',nFreedVars);
                                if xtraVerbose
                                    fprintf('Implied free variables:\n');
                                    disp(varsInProblem(freedVarIdx(tightenedIdx))');
                                    if computeLambda
                                        fprintf('Tightened lower bounds on variables\n');
                                        disp(varsInProblem(impliedBndVarIdx(tightenedLbIdx))');
                                        fprintf('Tightened upper bounds on variables\n');
                                        disp(varsInProblem(impliedBndVarIdx(tightenedUbIdx))');
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end


    function freeLinearColumnSingletons











        totalConstrPerVar=nnzAeqCols+nnzAineqCols;
        isFreeLinColSngl=(totalConstrPerVar==1)&linearVars&...
        ((impliedLowerBounded&impliedUpperBounded)|~(isfinite(lb)|isfinite(ub)));
        if any(isFreeLinColSngl)

            freeLinColSnglIdx=find(isFreeLinColSngl);

            linColSnglPrimalStruct.coefs=[];
            linColSnglPrimalStruct.constrRhs=[];
            linColSnglPrimalStruct.constrRows=[];
            varIdx=[];
            lambdaIneq=[];
            lambdaEq=[];
            linColSnglDualStruct.lambda=[];
            linColSnglDualStruct.eqIdx=[];
            linColSnglDualStruct.ineqIdx=[];
            ineqLinColSngltnExists=false;
            eqLinColSngltnExists=false;


            [rowsIneq,cols,freeLinColSnglCoefs]=find(Aineq(:,isFreeLinColSngl));
            if~isempty(freeLinColSnglCoefs)







                [rowsIneq,cols,freeLinColSnglCoefs,lambdaIneq]=sortFreeLinColSngltn(...
                rowsIneq(:),cols(:),freeLinColSnglCoefs(:),freeLinColSnglIdx,true);
                if unboundedProb
                    return
                end
            end


            if~isempty(freeLinColSnglCoefs)
                ineqLinColSngltnExists=true;


                logicWorkVec=false(nVar,1);
                logicWorkVec(freeLinColSnglIdx(cols))=true;


                varIdx=varsInProblem(logicWorkVec);


                removeVars(logicWorkVec);




                linColSnglPrimalStruct.coefs=freeLinColSnglCoefs;
                linColSnglPrimalStruct.constrRhs=bineq(rowsIneq);
                linColSnglPrimalStruct.constrRows=Aineq(rowsIneq,:);



                nnzAineqCols=nnzAineqCols-getNNZcounts(sparse(Aineq(rowsIneq,:)),2);

                nnzAineqRows(rowsIneq,:)=[];
                Aineq(rowsIneq,:)=[];
                bineq(rowsIneq,:)=[];

                if~isempty(f)


                    f=f+linColSnglPrimalStruct.constrRows'*lambdaIneq;
                else
                    solvedProb=true;
                    return
                end



                isFreeLinColSngl(logicWorkVec)=[];

                freeLinColSnglIdx=find(isFreeLinColSngl);
                done=false;
            end


            [rowsEq,cols,freeLinColSnglCoefs]=find(Aeq(:,isFreeLinColSngl));
            if~isempty(freeLinColSnglCoefs)


                [rowsEq,cols,freeLinColSnglCoefs,lambdaEq]=sortFreeLinColSngltn(...
                rowsEq(:),cols(:),freeLinColSnglCoefs(:),freeLinColSnglIdx,false);
                if unboundedProb
                    return
                end
            end


            if~isempty(freeLinColSnglCoefs)
                eqLinColSngltnExists=true;


                logicWorkVec=false(nVar,1);
                logicWorkVec(freeLinColSnglIdx(cols))=true;


                varIdx=[varIdx;varsInProblem(freeLinColSnglIdx(cols))];


                removeVars(logicWorkVec);




                linColSnglPrimalStruct.coefs=[linColSnglPrimalStruct.coefs;
                freeLinColSnglCoefs];
                linColSnglPrimalStruct.constrRhs=[linColSnglPrimalStruct.constrRhs;
                beq(rowsEq)];
                linColSnglPrimalStruct.constrRows=[linColSnglPrimalStruct.constrRows;
                Aeq(rowsEq,:)];


                nnzAeqCols=nnzAeqCols-getNNZcounts(sparse(Aeq(rowsEq,:)),2);

                nnzAeqRows(rowsEq)=[];
                Aeq(rowsEq,:)=[];
                beq(rowsEq,:)=[];

                if~isempty(f)


                    f=f+linColSnglPrimalStruct.constrRows'*lambdaEq;
                else
                    solvedProb=true;
                    return
                end

                done=false;
            end

            if eqLinColSngltnExists||ineqLinColSngltnExists
                if computeLambda
                    linColSnglDualStruct.lambda=[lambdaIneq;lambdaEq];
                    linColSnglDualStruct.ineqIdx=ineqsInProblem(rowsIneq);
                    linColSnglDualStruct.eqIdx=eqsInProblem(rowsEq);
                    ineqsInProblem(rowsIneq)=[];
                    eqsInProblem(rowsEq)=[];
                end
                pushTransformOnStack(8,varIdx,linColSnglPrimalStruct,linColSnglDualStruct);
                if testingDisp
                    fprintf(['Removing %i equalities and %i inequalities with free ',...
                    'linear singleton column variables.\n'],numel(rowsEq),numel(rowsIneq));
                    if xtraVerbose
                        fprintf('Variables fixed:\n');
                        disp(varIdx');
                    end
                end
            end
        end
    end


    function[rows,cols,coefs,lambda]=sortFreeLinColSngltn(rows,cols,coefs,...
        freeLinColSnglIdx,isIneq)







        [rows,idx]=sort(rows);
        cols=cols(idx);
        coefs=coefs(idx);





        lambda=-f(freeLinColSnglIdx(cols))./coefs;


        if isIneq&&any(lambda<-tolZero)
            if testingDisp
                fprintf(['Unbounded problem detected: inequality free linear column singletons ',...
                'violate dual constraints\n']);
            end
            unboundedProb=true;
            return
        end


        logicWorkVec=(diff([0;rows])==0);
        if any(logicWorkVec)


            rowIdx=rows(logicWorkVec);
            for m=1:length(rowIdx)
                logicWorkVec=(rows==rowIdx(m));
                lambdaTemp=lambda(logicWorkVec);
                lambdaMax=max(lambdaTemp);
                lambdaMin=min(lambdaTemp);
                if any(abs(lambdaMax-lambdaMin)>tolZero*max(1,abs((lambdaMax+lambdaMin)/2)))
                    if testingDisp
                        fprintf(['Unbounded problem detected: multiple free linear column ',...
                        'singletons in one row\n']);
                    end
                    unboundedProb=true;
                    return
                end

                rows(logicWorkVec)=NaN;
            end




            logicWorkVec=isnan(rows);
            cols(logicWorkVec)=[];
            rows(logicWorkVec)=[];
            coefs(logicWorkVec)=[];
            lambda(logicWorkVec)=[];
        end
    end


    function unconstrVars



        totalConstrPerVar=nnzAeqCols+nnzAineqCols;




        logicWorkVec=linearVars&(totalConstrPerVar==0);
        if any(logicWorkVec)


            varFixedToLB=logicWorkVec&(f>0);
            independentVar=logicWorkVec&(f==0);
            varFixedToUB=logicWorkVec&(f<0);


            if any(~isfinite([lb(varFixedToLB);ub(varFixedToUB)]))
                if testingDisp
                    fprintf('Dual infeasibility detected: linearly unconstrained vars\n');
                end
                unboundedProb=true;
                return
            end


            lbIndependent=lb(independentVar);
            ubIndependent=ub(independentVar);

            isInfLbInd=~isfinite(lbIndependent);
            isInfUbInd=~isfinite(ubIndependent);



            relPerturbFactor=tolZero*1e2;
            xIndependent=0.5*(lbIndependent+ubIndependent);


            xIndependent(isInfLbInd&~isInfUbInd)=(1-relPerturbFactor).*ubIndependent(isInfLbInd&~isInfUbInd);


            xIndependent(isInfUbInd&~isInfLbInd)=(1+relPerturbFactor).*lbIndependent(isInfUbInd&~isInfLbInd);

            xIndependent(isInfLbInd&isInfUbInd)=0;

            xFixed=[lb(varFixedToLB);ub(varFixedToUB);xIndependent];


            varIdx.fixedToLB=varsInProblem(varFixedToLB);
            varIdx.fixedToUB=varsInProblem(varFixedToUB);
            varIdx.independent=varsInProblem(independentVar);

            if computeLambda


                unconstrStruct.lambda.lower=f(varFixedToLB);
                unconstrStruct.lambda.upper=f(varFixedToUB);
            else
                unconstrStruct=[];
            end
            pushTransformOnStack(9,varIdx,xFixed,unconstrStruct);

            if testingDisp
                fprintf('Removing %i linear unconstrained variables.\n',numel(xFixed));
                if xtraVerbose
                    fprintf('Variables fixed to lb:\n');
                    disp(varIdx.fixedToLB');
                    fprintf('Variables fixed to ub:\n');
                    disp(varIdx.fixedToUB');
                    fprintf('Independent Variables:\n');
                    disp(varIdx.independent');
                end
            end


            removeVars(logicWorkVec);

            if isempty(f)

                solvedProb=true;
            end
            done=false;
        end
    end


    function duplicateEqs








        if~isempty(Aeq)




            maxVals=max(abs(Aeq),[],2);



            randVec=any(Aeq,1)';
            if nnz(randVec)/length(randVec)>0.5
                randVec=rand(length(randVec),1);
            else
                randVec=sprand(randVec);
            end

            AeqtimesRandVec=Aeq*randVec;

            AeqtimesRandVec=AeqtimesRandVec./(nnzAeqRows.*maxVals);

            [AeqtimesRandVec,origRowIdx]=sort(AeqtimesRandVec);
            logicWorkVec=abs(diff([0;AeqtimesRandVec]))<=tolDuplicate;
            if any(logicWorkVec)

                duplicateIdx=find(logicWorkVec);

                nDuplicates=length(duplicateIdx);
                duplicateRows=[];k=1;
                while k<=nDuplicates
                    groupIdx=[duplicateIdx(k)-1;duplicateIdx(k)];



                    keepChecking=true;
                    while keepChecking&&(k~=nDuplicates)
                        if duplicateIdx(k+1)-duplicateIdx(k)==1

                            groupIdx=[groupIdx;duplicateIdx(k+1)];
                            k=k+1;
                        else
                            keepChecking=false;
                        end
                    end

                    groupRows=origRowIdx(groupIdx);
                    groupLength=length(groupRows);
                    if groupLength>2
                        AeqGroup=Aeq(groupRows,:);

                        [AeqGroup,idx]=sortrows(AeqGroup);
                        dups=abs(AeqGroup(1:groupLength-1,:)-AeqGroup(2:groupLength,:));
                        dups=[false;~any(dups>tolDuplicate,2)];
                        if any(dups)
                            groupRows=groupRows(idx);
                            beqTemp=beq([groupRows(1);groupRows(dups)]);
                            beqMin=min(beqTemp);beqMax=max(beqTemp);
                            if abs(beqMax-beqMin)>tolDuplicate*max(1,abs((beqMax+beqMin)/2))
                                if testingDisp
                                    fprintf('Infeasible problem: duplicate equalities have different rhs\n');
                                end
                                infeasProb=true;
                                return
                            end
                            duplicateRows=[duplicateRows;groupRows(dups)];
                        end
                    else
                        if all(abs(Aeq(groupRows(1),:)-Aeq(groupRows(2),:))<=tolDuplicate)


                            if abs(beq(groupRows(1))-beq(groupRows(2)))>=tolDuplicate
                                if testingDisp
                                    fprintf('Infeasible problem: duplicate equalities have different rhs\n');
                                end
                                infeasProb=true;
                                return
                            end

                            duplicateRows=[duplicateRows;groupRows(2)];
                        end
                    end
                    k=k+1;
                end
                if~isempty(duplicateRows)
                    if testingDisp
                        fprintf('Removing %i duplicate equality constraints.\n',numel(duplicateRows));
                        if xtraVerbose
                            fprintf('Duplicate equalities:\n');
                            disp(eqsInProblem(duplicateRows)');
                        end
                    end
                    if computeLambda
                        dupRowStruct.ineqIdx=[];
                        dupRowStruct.eqIdx=eqsInProblem(duplicateRows);
                        eqsInProblem(duplicateRows)=[];
                        pushTransformOnStack(10,[],[],dupRowStruct)
                    end
                    Aeq(duplicateRows,:)=[];
                    beq(duplicateRows,:)=[];
                    nnzAeqRows(duplicateRows)=[];
                end
            end
        end
    end



    function scaleProblem()

        maxScaleIter=25;
        if any(nnzAeqCols+nnzAineqCols>0)
            A=[Aeq;Aineq];

            [rowScale,colScale,A]=symScalingInf(A,maxScaleIter,tolCon);
            colScale=colScale';
            meq=size(Aeq,1);
            Aeq=A(1:meq,:);
            Aineq=A(meq+1:end,:);

            beq=beq./rowScale(1:meq,1);
            bineq=bineq./rowScale(meq+1:end,1);

            finiteUB=~isinf(ub);
            finiteLB=~isinf(lb);
            ub(finiteUB)=colScale(finiteUB).*ub(finiteUB);
            lb(finiteLB)=colScale(finiteLB).*lb(finiteLB);
            f=f./colScale;
            if~isLP
                H=spdiags(1./colScale,0,nVar,nVar)*H*spdiags(1./colScale,0,nVar,nVar);
            end

            scaleStruct.rowScale=rowScale;
            scaleStruct.colScale=colScale;

            pushTransformOnStack(11,[],scaleStruct,[]);
        end

    end


    function[Dr,Dc,A,err]=symScalingInf(A,MaxScalIter,tol)








        numIters=0;
        err=Inf;
        m=size(Aeq,1)+size(Aineq,1);
        Dr=ones(m,1);Dc=ones(1,nVar);

        I=[nnzAeqRows;nnzAineqRows]==0;
        J=nnzAeqCols+nnzAineqCols==0;

        if issparse(A)
            scaleMatrix=@(M,dr,dc)spdiags(1./dr(:),0,m,m)*M*spdiags(1./dc(:),0,nVar,nVar);
        else
            scaleMatrix=@(M,dr,dc)bsxfun(@rdivide,bsxfun(@rdivide,M,dr),dc);
        end

        while err>tol&&numIters<MaxScalIter;
            dleft=full(sqrt(max(abs(A),[],2)));dright=full(sqrt(max(abs(A),[],1)));
            dleft(I)=1;dright(J)=1;
            A=scaleMatrix(A,dleft,dright);
            Dr=Dr.*dleft;Dc=Dc.*dright;

            errR=norm(dleft.^2-1,Inf);
            errC=norm(dright.^2-1,Inf);
            err=max(errR,errC);
            numIters=numIters+1;
        end
    end


    function fixVariables(type,xFixed,fixed,varIdx,dualVals)






















        if isempty(fixed)
            assert(~isempty(varIdx),'optimlib:presolve:fixVariables:emptyVarIdx',...
            'Cannot fix variables: no indices given');

            fixed=false(nVar,1);
            fixed(varIdx)=true;
        end


        if any(~isfinite(xFixed))
            if testingDisp
                fprintf('Unbounded problem detected: fixed variable to Inf bound\n');
            end
            unboundedProb=true;
            return
        end

        Hfixed=H(:,fixed);
        Afixed=Aineq(:,fixed);
        Aeqfixed=Aeq(:,fixed);


        if computeLambda




            dualVals.Afixed=Afixed;
            dualVals.Aeqfixed=Aeqfixed;
            dualVals.Hfixed=Hfixed;
            dualVals.ffixed=f(fixed);
        end






        if any(fixed)

            if~isLP
                f=f+Hfixed*xFixed;
            end


            bineq=bineq-Afixed*xFixed;
            beq=beq-Aeqfixed*xFixed;


            nnzAineqRows=nnzAineqRows-getNNZcounts(sparse(Afixed),1);
            nnzAeqRows=nnzAeqRows-getNNZcounts(sparse(Aeqfixed),1);
        end

        pushTransformOnStack(type,varsInProblem(fixed),xFixed,dualVals);



        removeVars(fixed);

        if isempty(f)


            if norm([beq;min(0,bineq)],Inf)>=tolCon*feasRelFactor
                infeasProb=true;
            else
                solvedProb=true;
            end
        end
    end


    function shiftedIdx=tightenBounds(impliedBnds,isLB,varIdx)



















        impliedBnds=impliedBnds(:);
        varIdx=varIdx(:);


        impliedLbs=impliedBnds(isLB);
        impliedLbIdx=varIdx(isLB);

        impliedUbs=impliedBnds(~isLB);
        impliedUbIdx=varIdx(~isLB);

        shiftedIdx=false(numel(impliedBnds),1);



        uniqueLbVars=diff([0;impliedLbIdx])~=0;
        uniqueUbVars=diff([0;impliedUbIdx])~=0;

        if all(uniqueLbVars)
            idx=impliedLbs-lb(impliedLbIdx)>tolBndShift;
            lb(impliedLbIdx(idx))=impliedLbs(idx);
            shiftedIdx(isLB)=idx;
        else


            uniqueVarsIdx=find(uniqueLbVars);
            nUniqueVars=numel(uniqueVarsIdx);
            logicWorkVec=false(numel(impliedLbIdx),1);
            uniqueImpliedBnds=zeros(nUniqueVars,1);

            for j=1:(nUniqueVars-1)

                [uniqueImpliedBnds(j),tightestIdx]=max(impliedLbs(uniqueVarsIdx(j):uniqueVarsIdx(j+1)-1));

                uniqueVarsIdx(j)=uniqueVarsIdx(j)+tightestIdx-1;
            end
            j=nUniqueVars;
            [uniqueImpliedBnds(j),tightestIdx]=max(impliedLbs(uniqueVarsIdx(j):end));
            uniqueVarsIdx(j)=uniqueVarsIdx(j)+tightestIdx-1;

            idx=uniqueImpliedBnds-lb(impliedLbIdx(uniqueVarsIdx))>tolBndShift;

            logicWorkVec(uniqueVarsIdx(idx))=true;
            lb(impliedLbIdx(logicWorkVec))=uniqueImpliedBnds(idx);
            shiftedIdx(isLB)=logicWorkVec;
        end

        if all(uniqueUbVars)
            idx=ub(impliedUbIdx)-impliedUbs>tolBndShift;
            ub(impliedUbIdx(idx))=impliedUbs(idx);
            shiftedIdx(~isLB)=idx;
        else


            uniqueVarsIdx=find(uniqueUbVars);
            nUniqueVars=length(uniqueVarsIdx);
            logicWorkVec=false(numel(impliedUbIdx),1);
            uniqueImpliedBnds=zeros(nUniqueVars,1);

            for j=1:(nUniqueVars-1)
                [uniqueImpliedBnds(j),tightestIdx]=min(impliedUbs(uniqueVarsIdx(j):uniqueVarsIdx(j+1)-1));
                uniqueVarsIdx(j)=uniqueVarsIdx(j)+tightestIdx-1;
            end
            j=nUniqueVars;
            [uniqueImpliedBnds(j),tightestIdx]=min(impliedUbs(uniqueVarsIdx(j):end));
            uniqueVarsIdx(j)=uniqueVarsIdx(j)+tightestIdx-1;

            idx=ub(impliedUbIdx(uniqueVarsIdx))-uniqueImpliedBnds>tolBndShift;
            logicWorkVec(uniqueVarsIdx(idx))=true;
            ub(impliedUbIdx(logicWorkVec))=uniqueImpliedBnds(idx);
            shiftedIdx(~isLB)=logicWorkVec;
        end

        if any(lb-ub>tolBndShift)
            if testingDisp
                fprintf('Infeasible problem: implied bounds are inconsistent\n');
            end
            infeasProb=true;
            return
        end
    end


    function removeVars(logicalVarIdx)






        f(logicalVarIdx,:)=[];
        Aineq(:,logicalVarIdx)=[];
        nnzAineqCols(logicalVarIdx)=[];
        Aeq(:,logicalVarIdx)=[];
        nnzAeqCols(logicalVarIdx)=[];

        lb(logicalVarIdx)=[];
        ub(logicalVarIdx)=[];
        impliedLowerBounded(logicalVarIdx)=[];
        impliedUpperBounded(logicalVarIdx)=[];

        linearVars(logicalVarIdx)=[];
        if~isLP
            H(:,logicalVarIdx)=[];
            H(logicalVarIdx,:)=[];
        end

        nVar=nVar-sum(logicalVarIdx);
        varsInProblem(logicalVarIdx)=[];
    end


    function pushTransformOnStack(type,varIdx,primalValues,dualValues)
















        transforms(transformIdx).type=type;
        transforms(transformIdx).varIdx=varIdx;
        transforms(transformIdx).primalVals=primalValues;
        transforms(transformIdx).dualVals=dualValues;

        transformIdx=transformIdx+1;
    end

end
