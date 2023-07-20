function[alpha,f_alpha,grad,exitflag,funcCount,faultTolStruct]=...
    lineSearch(funfcn,xInitial,dir,fInitial,fPrimeInitial,initialStepLength,...
    rho,sigma,fminimum,maxFunEvals,TolFunLnSrch,finDiffOpts,finDiffFlags,...
    sizes,grad,TolX,faultTolStruct,varargin)






















































    if fPrimeInitial>=0
        error(message('optim:lineSearch:FPrimeInitialNeg'))
    end


    [a,b,f_a,fPrime_a,f_b,fPrime_b,alpha,f_alpha,grad,exitflagBrckt,funcCountBrckt,faultTolStruct]=...
    bracketingPhase(funfcn,xInitial,dir,fInitial,fPrimeInitial,initialStepLength,...
    rho,sigma,fminimum,maxFunEvals,finDiffOpts,finDiffFlags,sizes,grad,TolX,...
    faultTolStruct,varargin{:});

    if exitflagBrckt==2


        [alpha,f_alpha,grad,exitflag,funcCount,faultTolStruct]=sectioningPhase(funfcn,...
        xInitial,dir,fInitial,fPrimeInitial,alpha,f_alpha,a,b,f_a,fPrime_a,f_b,...
        fPrime_b,rho,sigma,fminimum,maxFunEvals,funcCountBrckt,TolFunLnSrch,finDiffOpts,...
        finDiffFlags,sizes,grad,TolX,faultTolStruct,varargin{:});
    else

        exitflag=exitflagBrckt;
        funcCount=funcCountBrckt;
    end


    function[a,b,f_a,fPrime_a,f_b,fPrime_b,alpha,f_alpha,grad,exitflag,...
        funcCount,faultTolStruct]=bracketingPhase(funfcn,xInitial,dir,fInitial,...
        fPrimeInitial,initialStepLength,rho,sigma,fminimum,maxFunEvals,finDiffOpts,...
        finDiffFlags,sizes,grad,TolX,faultTolStruct,varargin)










        tau1=9;
        a=[];b=[];f_a=[];fPrime_a=[];f_b=[];fPrime_b=[];


        faultTolStruct.evalFinDiffOK=true;


        f_alpha=fInitial;


        fPrime_alpha=fPrimeInitial;


        alphaMax=(fminimum-fInitial)/(rho*fPrimeInitial);





        alphaMax=max(alphaMax,sqrt(eps));

        funcCount=0;



        faultTolStruct.undefObj=false;


        alpha=0;
        alphaNew=min(initialStepLength,alphaMax);

        nVar=length(xInitial(:));


        confcn={'','','','',''};

        while funcCount<maxFunEvals


            alphaPrev=alpha;
            alpha=alphaNew;

            fPrev=f_alpha;
            fPrimePrev=fPrime_alpha;



            ctr=1;
            doneEval=false;
            while~doneEval
                switch funfcn{1}
                case 'fun'
                    f_alpha=feval(funfcn{3},reshape(xInitial(:)+alpha*dir(:),sizes.xShape),varargin{:});
                    evalOK=isfinite(f_alpha)&&isreal(f_alpha);
                    if evalOK

                        [grad,~,~,numEvals,faultTolStruct.evalFinDiffOK]=...
                        computeFinDiffGradAndJac(xInitial(:)+alpha*dir(:),funfcn,confcn,f_alpha,...
                        [],[],grad,[],[],-Inf*ones(nVar,1),Inf*ones(nVar,1),[],finDiffOpts,finDiffFlags,sizes,varargin{:});

                        funcCount=funcCount+numEvals;
                        if faultTolStruct.evalFinDiffOK


                            grad=grad(:);
                            fPrime_alpha=grad'*dir(:);


                            faultTolStruct.evalFinDiffOK=faultTolStruct.evalFinDiffOK&&...
                            (isreal(fPrime_alpha)&&isfinite(fPrime_alpha));
                        end
                    end
                case 'fungrad'
                    [f_alpha,grad]=feval(funfcn{3},reshape(xInitial(:)+alpha*dir(:),sizes.xShape),varargin{:});
                    grad=grad(:);
                    fPrime_alpha=grad'*dir(:);
                case 'fun_then_grad'
                    f_alpha=feval(funfcn{3},reshape(xInitial(:)+alpha*dir(:),sizes.xShape),varargin{:});
                    grad=feval(funfcn{4},reshape(xInitial(:)+alpha*dir(:),sizes.xShape),varargin{:});
                    grad=grad(:);
                    fPrime_alpha=grad'*dir(:);
                otherwise
                    error(message('optim:lineSearch:UndefCalltype1'))
                end
                funcCount=funcCount+1;


                faultTolStruct.currTrialWellDefined=isfinite(f_alpha)&&isreal(f_alpha)&&faultTolStruct.evalFinDiffOK;
                if faultTolStruct.currTrialWellDefined

                    objEvalOutcome='success';
                    doneEval=true;
                else
                    if funcCount<maxFunEvals

                        backTrackFactor=2^(-ctr^2);
                        alpha=alphaPrev+backTrackFactor*(alpha-alphaPrev);

                        relStepSize=relDeltaXFminunc(xInitial,alpha*dir);
                        if relStepSize<TolX
                            objEvalOutcome='stepTooSmall';
                            doneEval=true;
                        end


                        faultTolStruct.relStepSize=relStepSize;
                    else
                        objEvalOutcome='maxFunEvals';
                        doneEval=true;
                    end

                    faultTolStruct.undefObj=true;
                    faultTolStruct.undefObjValue=f_alpha;
                end
                ctr=ctr+1;
            end


            if f_alpha<fminimum
                exitflag=1;
                return
            end

            if strcmpi(objEvalOutcome,'stepTooSmall')


                exitflag=-3;
                return
            end

            if strcmpi(objEvalOutcome,'maxFunEvals')


                exitflag=-1;
                return
            end


            if f_alpha>fInitial+alpha*rho*fPrimeInitial||f_alpha>=fPrev
                a=alphaPrev;b=alpha;
                f_a=fPrev;fPrime_a=fPrimePrev;
                f_b=f_alpha;fPrime_b=fPrime_alpha;




                if abs(b-a)<eps
                    exitflag=-2;
                else
                    exitflag=2;
                end
                return
            end


            if abs(fPrime_alpha)<=-sigma*fPrimeInitial
                exitflag=0;
                return
            end


            if fPrime_alpha>=0
                a=alpha;b=alphaPrev;
                f_a=f_alpha;fPrime_a=fPrime_alpha;
                f_b=fPrev;fPrime_b=fPrimePrev;




                if abs(b-a)<eps
                    exitflag=-2;
                else
                    exitflag=2;
                end
                return
            end


            if 2*alpha-alphaPrev<alphaMax
                brcktEndpntA=2*alpha-alphaPrev;
                brcktEndpntB=min(alphaMax,alpha+tau1*(alpha-alphaPrev));


                alphaNew=pickAlphaWithinInterval(brcktEndpntA,brcktEndpntB,alphaPrev,alpha,fPrev,...
                fPrimePrev,f_alpha,fPrime_alpha);
            else
                alphaNew=alphaMax;
            end
        end


        exitflag=-1;


        function[alpha,f_alpha,grad,exitflag,funcCount,faultTolStruct]=sectioningPhase(...
            funfcn,xInitial,dir,fInitial,fPrimeInitial,alpha,f_alpha,a,b,f_a,fPrime_a,...
            f_b,fPrime_b,rho,sigma,fminimum,maxFunEvals,funcCountBracketingPhase,TolFunLnSrch,...
            finDiffOpts,finDiffFlags,sizes,grad,TolX,faultTolStruct,varargin)





            tau2=min(0.1,sigma);tau3=0.5;


            faultTolStruct.evalFinDiffOK=true;

            nVar=length(xInitial(:));


            confcn={'','','','',''};

            funcCount=funcCountBracketingPhase;
            while funcCount<maxFunEvals


                alphaPrev=alpha;

                brcktEndpntA=a+tau2*(b-a);
                brcktEndpntB=b-tau3*(b-a);


                alpha=pickAlphaWithinInterval(brcktEndpntA,brcktEndpntB,a,b,f_a,fPrime_a,f_b,fPrime_b);




                if abs((alpha-a)*fPrime_a)<=TolFunLnSrch
                    exitflag=-2;
                    return
                end



                ctr=1;
                doneEval=false;
                while~doneEval
                    switch funfcn{1}
                    case 'fun'
                        f_alpha=feval(funfcn{3},reshape(xInitial(:)+alpha*dir(:),sizes.xShape),varargin{:});
                        evalOK=isfinite(f_alpha)&&isreal(f_alpha);
                        if evalOK

                            [grad,~,~,numEvals,faultTolStruct.evalFinDiffOK]=...
                            computeFinDiffGradAndJac(xInitial(:)+alpha*dir(:),funfcn,confcn,f_alpha,...
                            [],[],grad,[],[],-Inf*ones(nVar,1),Inf*ones(nVar,1),[],finDiffOpts,finDiffFlags,sizes,varargin{:});

                            funcCount=funcCount+numEvals;
                            if faultTolStruct.evalFinDiffOK


                                grad=grad(:);
                                fPrime_alpha=grad'*dir(:);


                                faultTolStruct.evalFinDiffOK=faultTolStruct.evalFinDiffOK&&...
                                (isreal(fPrime_alpha)&&isfinite(fPrime_alpha));
                            end
                        end
                    case 'fungrad'
                        [f_alpha,grad]=feval(funfcn{3},reshape(xInitial(:)+alpha*dir(:),sizes.xShape),varargin{:});
                        grad=grad(:);
                        fPrime_alpha=grad'*dir(:);
                    case 'fun_then_grad'
                        f_alpha=feval(funfcn{3},reshape(xInitial(:)+alpha*dir(:),sizes.xShape),varargin{:});
                        grad=feval(funfcn{4},reshape(xInitial(:)+alpha*dir(:),sizes.xShape),varargin{:});
                        grad=grad(:);
                        fPrime_alpha=grad'*dir(:);
                    otherwise
                        error(message('optim:lineSearch:UndefCalltype2'))
                    end
                    funcCount=funcCount+1;

                    faultTolStruct.currTrialWellDefined=isfinite(f_alpha)&&isreal(f_alpha)&&faultTolStruct.evalFinDiffOK;
                    if faultTolStruct.currTrialWellDefined

                        objEvalOutcome='success';
                        doneEval=true;
                    else
                        if funcCount<maxFunEvals

                            backTrackFactor=2^(-ctr^2);
                            alpha=alphaPrev+backTrackFactor*(alpha-alphaPrev);

                            relStepSize=relDeltaXFminunc(xInitial,alpha*dir);
                            if relStepSize<TolX
                                objEvalOutcome='stepTooSmall';
                                doneEval=true;
                            end


                            faultTolStruct.relStepSize=relStepSize;
                        else
                            objEvalOutcome='maxFunEvals';
                            doneEval=true;
                        end

                        faultTolStruct.undefObj=true;
                        faultTolStruct.undefObjValue=f_alpha;
                    end
                    ctr=ctr+1;
                end


                if f_alpha<fminimum
                    exitflag=1;
                    return
                end

                if strcmpi(objEvalOutcome,'stepTooSmall')


                    exitflag=-3;
                    return
                end

                if strcmpi(objEvalOutcome,'maxFunEvals')


                    exitflag=-1;
                    return
                end


                aPrev=a;bPrev=b;f_aPrev=f_a;f_bPrev=f_b;
                fPrime_aPrev=fPrime_a;fPrime_bPrev=fPrime_b;
                if f_alpha>fInitial+alpha*rho*fPrimeInitial||f_alpha>=f_a
                    a=aPrev;b=alpha;
                    f_a=f_aPrev;f_b=f_alpha;
                    fPrime_a=fPrime_aPrev;fPrime_b=fPrime_alpha;
                else
                    if abs(fPrime_alpha)<=-sigma*fPrimeInitial
                        exitflag=0;
                        return
                    end
                    a=alpha;f_a=f_alpha;fPrime_a=fPrime_alpha;
                    if(b-a)*fPrime_alpha>=0
                        b=aPrev;f_b=f_aPrev;fPrime_b=fPrime_aPrev;
                    else
                        b=bPrev;f_b=f_bPrev;fPrime_b=fPrime_bPrev;
                    end
                end


                if abs(b-a)<eps
                    exitflag=-2;
                    return
                end
            end


            exitflag=-1;


            function alpha=pickAlphaWithinInterval(brcktEndpntA,brcktEndpntB,alpha1,alpha2,f1,fPrime1,f2,fPrime2)








                coeff=interpolatingCubic(alpha1,alpha2,f1,fPrime1,f2,fPrime2);


                zlb=(brcktEndpntA-alpha1)/(alpha2-alpha1);
                zub=(brcktEndpntB-alpha1)/(alpha2-alpha1);


                if zlb>zub
                    [zub,zlb]=deal(zlb,zub);
                end


                z=globalMinimizerOfPolyInInterval(zlb,zub,coeff);
                alpha=alpha1+z*(alpha2-alpha1);


                function coeff=interpolatingCubic(alpha1,alpha2,f1,fPrime1,f2,fPrime2)






                    deltaAlpha=alpha2-alpha1;
                    coeff(4)=f1;
                    coeff(3)=deltaAlpha*fPrime1;
                    coeff(2)=3*(f2-f1)-(2*fPrime1+fPrime2)*deltaAlpha;
                    coeff(1)=(fPrime1+fPrime2)*deltaAlpha-2*(f2-f1);


                    function alpha=globalMinimizerOfPolyInInterval(lowerBound,upperBound,coeff)






                        stationaryPoint=roots([3*coeff(1),2*coeff(2),coeff(3)]);


                        [fmin,whichOne]=min([polyval(coeff,lowerBound),polyval(coeff,upperBound)]);
                        if whichOne==1
                            alpha=lowerBound;
                        else
                            alpha=upperBound;
                        end




                        if length(stationaryPoint)==2


                            if all(isreal(stationaryPoint))
                                if lowerBound<=stationaryPoint(2)&&stationaryPoint(2)<=upperBound
                                    [fmin,whichOne]=min([fmin,polyval(coeff,stationaryPoint(2))]);
                                    if whichOne==2
                                        alpha=stationaryPoint(2);
                                    end
                                end
                                if lowerBound<=stationaryPoint(1)&&stationaryPoint(1)<=upperBound
                                    [~,whichOne]=min([fmin,polyval(coeff,stationaryPoint(1))]);
                                    if whichOne==2
                                        alpha=stationaryPoint(1);
                                    end
                                end
                            end
                        elseif length(stationaryPoint)==1
                            if isreal(stationaryPoint)
                                if lowerBound<=stationaryPoint&&stationaryPoint<=upperBound
                                    [~,whichOne]=min([fmin,polyval(coeff,stationaryPoint)]);
                                    if whichOne==2
                                        alpha=stationaryPoint;
                                    end
                                end
                            end
                        end
