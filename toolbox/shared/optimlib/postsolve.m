function[xOut,lambdaOut]=postsolve(x,transforms,restoreData,lambda,options,computeLambda,isLP)




















































    restoredVars=false(restoreData.nVarOrig,1);
    restoredVars(restoreData.varsInProblem)=true;

    numTransforms=length(transforms);

    if numTransforms>0&&transforms(numTransforms).type==11

        rowScale=transforms(numTransforms).primalVals.rowScale;
        colScale=transforms(numTransforms).primalVals.colScale;
        x=x./colScale;

        if computeLambda&&~isempty(lambda)
            mEq=numel(restoreData.eqsInProblem);
            lambda.eqlin=lambda.eqlin./rowScale(1:mEq,1);
            lambda.ineqlin=lambda.ineqlin./rowScale(mEq+1:end,1);
            lambda.lower=lambda.lower.*colScale;
            lambda.upper=lambda.upper.*colScale;
        end

        numTransforms=numTransforms-1;
    end

    xOut=zeros(restoreData.nVarOrig,1);
    xOut(restoredVars)=x;
    if computeLambda
        lambdaOut.ineqlin=zeros(restoreData.mIneqOrig,1);
        lambdaOut.eqlin=zeros(restoreData.mEqOrig,1);
        lambdaOut.lower=zeros(restoreData.nVarOrig,1);
        lambdaOut.upper=zeros(restoreData.nVarOrig,1);




        restoredIneqs=false(restoreData.mIneqOrig,1);
        restoredIneqs(restoreData.ineqsInProblem)=true;
        restoredEqs=false(restoreData.mEqOrig,1);
        restoredEqs(restoreData.eqsInProblem)=true;
        restoredBounds=false(restoreData.nVarOrig,1);
        restoredBounds(restoreData.varsInProblem)=true;
















        if~isempty(lambda)
            lambdaOut.ineqlin(restoredIneqs)=lambda.ineqlin;
            lambdaOut.eqlin(restoredEqs)=lambda.eqlin;
            lambdaOut.lower(restoredBounds)=lambda.lower;
            lambdaOut.upper(restoredBounds)=lambda.upper;
        end
    else
        lambdaOut=struct('ineqlin',[],'eqlin',[],'lower',[],'upper',[]);
    end


    for k=numTransforms:-1:1
        thisTransform=transforms(k);
        switch thisTransform.type













        case{1,3,6}
            xOut(thisTransform.varIdx)=thisTransform.primalVals;
            restoredVars(thisTransform.varIdx)=true;
            if computeLambda




                if~isLP
                    gradAtSol=thisTransform.dualVals.ffixed+thisTransform.dualVals.Hfixed'*xOut(restoredVars,:);
                else
                    gradAtSol=thisTransform.dualVals.ffixed;
                end
                lambdaBnd=gradAtSol+thisTransform.dualVals.Afixed'*lambdaOut.ineqlin(restoredIneqs,:)+...
                thisTransform.dualVals.Aeqfixed'*lambdaOut.eqlin(restoredEqs,:);
                if thisTransform.type==1


                    isGradPos=gradAtSol>0;
                    lambdaOut.lower(thisTransform.varIdx(isGradPos,:))=lambdaBnd(isGradPos,:);
                    lambdaOut.upper(thisTransform.varIdx(~isGradPos,:))=-lambdaBnd(~isGradPos,:);
                elseif thisTransform.type==3
                    lambdaOut.eqlin(thisTransform.dualVals.constrIdx)=...
                    -lambdaBnd./thisTransform.dualVals.coefs;








                    restoredEqs(thisTransform.dualVals.constrIdx)=true;
                    restoredEqs(thisTransform.dualVals.repeats)=true;
                else



















                    nForcingConstr=length(thisTransform.dualVals.nnzForcingRows);
                    lambdaTemp=zeros(nForcingConstr,1);
                    idxStart=0;
                    for i=1:nForcingConstr
                        idxEnd=idxStart+thisTransform.dualVals.nnzForcingRows(i);
                        if thisTransform.dualVals.lowerForcingConstr(i)
                            lambdaTemp(i)=min(lambdaBnd(thisTransform.dualVals.lambdaIdx(idxStart+1:idxEnd,:))./...
                            thisTransform.dualVals.coefs(idxStart+1:idxEnd,:));
                        else
                            lambdaTemp(i)=max(lambdaBnd(thisTransform.dualVals.lambdaIdx(idxStart+1:idxEnd,:))./...
                            thisTransform.dualVals.coefs(idxStart+1:idxEnd,:));
                        end



                        lambdaBnd(thisTransform.dualVals.lambdaIdx(idxStart+1:idxEnd,:))=...
                        lambdaBnd(thisTransform.dualVals.lambdaIdx(idxStart+1:idxEnd,:))-...
                        lambdaTemp(i)*thisTransform.dualVals.coefs(idxStart+1:idxEnd,:);

                        idxStart=idxEnd;
                    end

                    idx=length(thisTransform.dualVals.eqIdx);
                    lambdaOut.eqlin(thisTransform.dualVals.eqIdx,:)=-lambdaTemp(1:idx,:);
                    lambdaOut.ineqlin(thisTransform.dualVals.ineqIdx,:)=-lambdaTemp(idx+1:end,:);


                    lambdaOut.lower(thisTransform.varIdx(thisTransform.dualVals.varFixedToLB),:)=...
                    lambdaBnd(thisTransform.dualVals.varFixedToLB,:);
                    lambdaOut.upper(thisTransform.varIdx(~thisTransform.dualVals.varFixedToLB),:)=...
                    -lambdaBnd(~thisTransform.dualVals.varFixedToLB,:);

                    restoredIneqs(thisTransform.dualVals.ineqIdx,:)=true;
                    restoredIneqs(thisTransform.dualVals.redundantIneqIdx,:)=true;
                    restoredEqs(thisTransform.dualVals.eqIdx,:)=true;
                end
                restoredBounds(thisTransform.varIdx,:)=true;
            end
        case 2











            if computeLambda

                lambdaBnd=lambdaOut.lower(thisTransform.dualVals.tightenedLbIdx);
                if~isempty(lambdaBnd)
                    lambdaOut.ineqlin(thisTransform.dualVals.lbImpliedConstrIdx,:)=...
                    -lambdaBnd./thisTransform.dualVals.lbImpliedConstrCoefs;

                    lambdaOut.lower(thisTransform.dualVals.tightenedLbIdx,:)=0;
                end


                lambdaBnd=lambdaOut.upper(thisTransform.dualVals.tightenedUbIdx,:);
                if~isempty(lambdaBnd)

                    lambdaOut.ineqlin(thisTransform.dualVals.ubImpliedConstrIdx,:)=...
                    lambdaBnd./thisTransform.dualVals.ubImpliedConstrCoefs;

                    lambdaOut.upper(thisTransform.dualVals.tightenedUbIdx,:)=0;
                end

                restoredIneqs([thisTransform.dualVals.lbImpliedConstrIdx;
                thisTransform.dualVals.ubImpliedConstrIdx;
                thisTransform.dualVals.untightenedIdx])=true;
            end
        case{4,10}


            if computeLambda
                restoredIneqs(thisTransform.dualVals.ineqIdx)=true;
                restoredEqs(thisTransform.dualVals.eqIdx)=true;
            end
        case 7



            if computeLambda


                lambdaBnd=lambdaOut.lower(thisTransform.dualVals.tightenedLbIdx);




                if~isempty(lambdaBnd)
                    unscaledLambda=-lambdaBnd./thisTransform.dualVals.lbImpliedConstrCoefs;

                    lambdaOut.eqlin(thisTransform.dualVals.lbImpliedConstrIdx)=...
                    lambdaOut.eqlin(thisTransform.dualVals.lbImpliedConstrIdx)+unscaledLambda;



                    lambdaFreedVar=thisTransform.dualVals.lbFreedVarConstrCoefs.*unscaledLambda;
                    sameSignCoefs=thisTransform.dualVals.lbFreedVarConstrCoefs.*thisTransform.dualVals.lbImpliedConstrCoefs>0;


                    freedVarIdx=thisTransform.dualVals.lbFreedVarIdx;
                    lambdaOut.lower(freedVarIdx(~sameSignCoefs))=lambdaFreedVar(~sameSignCoefs);
                    lambdaOut.upper(freedVarIdx(sameSignCoefs))=-lambdaFreedVar(sameSignCoefs);

                    lambdaOut.lower(thisTransform.dualVals.tightenedLbIdx)=0;
                end



                lambdaBnd=lambdaOut.upper(thisTransform.dualVals.tightenedUbIdx);

                if~isempty(lambdaBnd)




                    unscaledLambda=lambdaBnd./thisTransform.dualVals.ubImpliedConstrCoefs;

                    lambdaOut.eqlin(thisTransform.dualVals.ubImpliedConstrIdx)=...
                    lambdaOut.eqlin(thisTransform.dualVals.ubImpliedConstrIdx)+unscaledLambda;



                    lambdaFreedVar=thisTransform.dualVals.ubFreedVarConstrCoefs.*unscaledLambda;
                    sameSignCoefs=thisTransform.dualVals.ubFreedVarConstrCoefs.*thisTransform.dualVals.ubImpliedConstrCoefs>0;


                    freedVarIdx=thisTransform.dualVals.ubFreedVarIdx;
                    lambdaOut.lower(freedVarIdx(sameSignCoefs))=lambdaFreedVar(sameSignCoefs);
                    lambdaOut.upper(freedVarIdx(~sameSignCoefs))=-lambdaFreedVar(~sameSignCoefs);

                    lambdaOut.upper(thisTransform.dualVals.tightenedUbIdx)=0;
                end

                restoredBounds(thisTransform.varIdx)=true;
                restoredEqs(thisTransform.dualVals.dbltnEqIdx)=true;
            end
        case 8


            xOut(thisTransform.varIdx)=...
            (thisTransform.primalVals.constrRhs-thisTransform.primalVals.constrRows*xOut(restoredVars,:))./...
            thisTransform.primalVals.coefs;
            restoredVars(thisTransform.varIdx)=true;
            if computeLambda
                idx=length(thisTransform.dualVals.ineqIdx);
                lambdaOut.ineqlin(thisTransform.dualVals.ineqIdx)=thisTransform.dualVals.lambda(1:idx);
                lambdaOut.eqlin(thisTransform.dualVals.eqIdx)=thisTransform.dualVals.lambda(idx+1:end);

                restoredIneqs(thisTransform.dualVals.ineqIdx)=true;
                restoredEqs(thisTransform.dualVals.eqIdx)=true;
                restoredBounds(thisTransform.varIdx)=true;
            end
        case 9
            varIdx=[thisTransform.varIdx.fixedToLB;
            thisTransform.varIdx.fixedToUB;
            thisTransform.varIdx.independent];
            xOut(varIdx)=thisTransform.primalVals;
            restoredVars(varIdx)=true;
            if computeLambda
                lambdaOut.lower(thisTransform.varIdx.fixedToLB)=thisTransform.dualVals.lambda.lower;
                lambdaOut.upper(thisTransform.varIdx.fixedToUB)=-thisTransform.dualVals.lambda.upper;

                restoredBounds(varIdx)=true;
            end

        case 12
            if computeLambda
                restoredIneqs(thisTransform.dualVals.redundantIneqIdx,:)=true;
            end
        otherwise
            warning(message('optimlib:postsolve:unknownTransform'));
        end
    end
