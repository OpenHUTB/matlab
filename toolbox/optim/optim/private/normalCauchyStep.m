function[scaledNormalCauchyStep,trActive,normStep]=...
    normalCauchyStep(c_ip,JacTrans_ip,trRadius_normal,AugFactor,slacks,...
    honorBndsOnlyMode,honorIneqsBndsMode,sizes)













    nVar=sizes.nVar;
    mAll=sizes.mAll;
    mEq=sizes.mEq;mIneq=sizes.mIneq;
    mLinIneq=sizes.mLinIneq;
    mNonlinIneq=sizes.mNonlinIneq;
    nFiniteLb=sizes.nFiniteLb;
    nFiniteUb=sizes.nFiniteUb;


    workArray1=JacTrans_ip*c_ip;
    workArray2=JacTrans_ip'*workArray1;
    workScalar1=workArray1'*workArray1;
    workScalar2=workArray2'*workArray2;





    if honorBndsOnlyMode&&mEq+mLinIneq+mNonlinIneq>0


        rhs=-workArray2;

        rhs(mEq+mLinIneq+1:mEq+mLinIneq+nFiniteLb+nFiniteUb,1)=zeros(nFiniteLb+nFiniteUb,1);
        negScaledCauchyDir=solveAugSystem(AugFactor,...
        zeros(nVar,1),zeros(mIneq,1),rhs(1:mEq,1),rhs(mEq+1:mAll,1),...
        slacks,sizes);
        negScaledCauchyDir=-negScaledCauchyDir;
    elseif honorIneqsBndsMode&&mEq>0


        rhs=-workArray2;


        rhs(mEq+1:mEq+mIneq,1)=zeros(mIneq,1);
        negScaledCauchyDir=solveAugSystem(AugFactor,...
        zeros(nVar,1),zeros(mIneq,1),rhs(1:mEq,1),rhs(mEq+1:mAll,1),...
        slacks,sizes);
        negScaledCauchyDir=-negScaledCauchyDir;
    else
        negScaledCauchyDir=workArray1;
    end
    normScaledCauchyDir=norm(negScaledCauchyDir);

    if normScaledCauchyDir*workScalar1>workScalar2*trRadius_normal


        betaCauchy=trRadius_normal/normScaledCauchyDir;
        trActive=true;
    else



        if workScalar2<=0
            betaCauchy=0;
        else
            betaCauchy=workScalar1/workScalar2;
        end
        trActive=false;
    end
    scaledNormalCauchyStep=-betaCauchy*negScaledCauchyDir;
    normStep=abs(betaCauchy)*normScaledCauchyDir;
