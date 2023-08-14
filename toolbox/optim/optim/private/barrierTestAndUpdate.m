function[barrierParam,barrierParam_prev,barrIter,...
    penaltyParamMin,trRadius,prevUseDirect,f_ip,scaledGrad_ip]=...
    barrierTestAndUpdate(barrierParam,lambda_ip,lambdaBarrierStopTest,c_ip,...
    scaledGrad_ip,JacTrans_ip,feasRelativeFactor_scaled,optimRelativeFactor_scaled,...
    useDirect,fval,slacks,grad,barrierParam_prev,barrIter,penaltyParamMin,...
    trRadius,prevUseDirect,f_ip,sizes,options)














    mIneq=sizes.mIneq;

    testBarrier=true;


    while testBarrier
        barrierConverged=barrierStopTest(barrierParam,lambda_ip,lambdaBarrierStopTest,c_ip,...
        scaledGrad_ip,JacTrans_ip,feasRelativeFactor_scaled,...
        optimRelativeFactor_scaled,useDirect,sizes);
        if barrierConverged
            barrierParam_prev=barrierParam;
            [barrierParam,penaltyParamMin,trRadius,prevUseDirect]=...
            updateBarrierParam(barrierParam,barrIter,trRadius,c_ip,options);
            barrIter=0;



            if(barrierParam~=barrierParam_prev)

                f_ip=fval-barrierParam*sum(log(slacks));
                scaledGrad_ip=[grad;-barrierParam*ones(mIneq,1)];
            else
                testBarrier=false;
            end
        else
            testBarrier=false;
        end
    end
end


function barrierConverged=barrierStopTest(barrierParam,lambda_ip,lambdaBarrierStopTest,c_ip,...
    scaledGrad_ip,JacTrans_ip,feasRelativeFactor_scaled,...
    optimRelativeFactor_scaled,useDirect,sizes)




    nVar=sizes.nVar;
    nPrimal=sizes.nPrimal;
    mIneq=sizes.mIneq;






    barrPrimalFeasError=norm(c_ip,inf);





    if~useDirect&&mIneq>0
        lambdaTmp=lambdaBarrierStopTest;
    else
        lambdaTmp=lambda_ip;
    end


    barrDualFeasError=norm(scaledGrad_ip(1:nVar)-JacTrans_ip(1:nVar,:)*lambdaTmp,inf);


    barrComplemError=norm(scaledGrad_ip(nVar+1:nPrimal,1)-JacTrans_ip(nVar+1:nPrimal,:)*lambdaTmp,inf);


    barrierTolCon=barrierParam;
    barrierTolFun=barrierParam;


    if barrPrimalFeasError<=barrierTolCon*feasRelativeFactor_scaled&&...
        barrDualFeasError<=barrierTolFun*optimRelativeFactor_scaled&&...
        barrComplemError<=barrierTolFun*optimRelativeFactor_scaled
        barrierConverged=true;
    else
        barrierConverged=false;
    end

end


function[barrierParam,penaltyParamMin,trRadius,prevUseDirect]=...
    updateBarrierParam(barrierParam,barrIter,trRadius,c_ip,options)




    if barrIter<=2
        barrierParam=1e-2*barrierParam;
    else
        barrierParam=0.2*barrierParam;
    end


    barrierParam=max(barrierParam,eps);


    penaltyParamMin=100*norm(c_ip);
    trRadius=max(5*trRadius,1);


    if strcmpi(options.IpAlgorithm,'direct')
        prevUseDirect=true;
    else
        prevUseDirect=false;
    end

end
