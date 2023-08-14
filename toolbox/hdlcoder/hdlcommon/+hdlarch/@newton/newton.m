


classdef newton<handle

    methods(Static)




        hC=getRecipSqrtNewtonComp(hN,hInSignals,hOutSignals,newtonInfo)
        hC=getRecipSqrtNewtonSingleRateComp(hN,hInSignals,hOutSignals,newtonInfo)
        hC=getNewtonPolynomialIVStageComp(hN,hInSignals,hOutSignals,newtonInfo)
        hC=getRecipNewtonComp(hN,hInSignals,hOutSignals,newtonInfo)
        hC=getRecipNewtonSingleRateComp(hN,hInSignals,hOutSignals,newtonInfo)




        [anorm,dynamicshift,normFixedShift,hC]=getNewtonInputComp(hN,hInSignals)
        [anorm,dynamicshift,normFixedShift,oneMoreShift,changesign,hInC]=getRecipNewtonInputComp(hN,hInSignals)
        hC=getNewtonOutputComp(hN,hInSignals,hOutSignals,newtonInfo,normFixedShift)
        hC=getRecipNewtonOutputComp(hN,hInSignals,hOutSignals,newtonInfo,normFixedShift)
        hNewNet=getNewtonPolynomialIVNetwork(hN,hInSignals,hOutSignals,newtonInfo)
        hNewNet=getNewtonPolynomialIVSingleRateNetwork(hN,hInSignals,hOutSignals,newtonInfo)
        hNewNet=getNewtonRSqrtCoreNetwork(hN,hInSignals,newtonInfo)
        hNewNet=getNewtonRSqrtCoreSingleRateNetwork(hN,hInSignals,newtonInfo)
        hNewNet=getNewtonRecipCoreSingleRateNetwork(hN,hInSignals,newtonInfo)
        hNewNet=getNewtonRecipCoreNetwork(hN,hInSignals,newtonInfo)
        hType=getNewtonRSqrtIntermType(hInSignals,hOutSignals,intermDT,internalRule)
        status=isNewtonRSqrtOverLimit(hInSignals,intermType)




        hType=getNewtonSqrtType(hInSignals)
        status=isNewtonSqrtOverLimit(hInSignals)




        hC=handleReciprocalSpecialCase(hN,hInSignals,hOutSignals,rndMode,satMode,compName)




        hNewNet=getRecipSqrtNewtonNetwork(hN,hInSignals,hOutSignals,NewtonInfo)
        hNewNet=getRecipSqrtNewtonSingleRateNetwork(hN,hInSignals,hOutSignals,NewtonInfo)
        hNewNet=getSqrtNewtonNetwork(hN,hInSignals,hOutSignals,NewtonInfo)
        hNewNet=getSqrtNewtonSingleRateNetwork(hN,hInSignals,hOutSignals,NewtonInfo)
        hNewNet=getRecipNewtonNetwork(hN,hInSignals,hOutSignals,NewtonInfo)
        hNewNet=getRecipNewtonSingleRateNetwork(hN,hInSignals,hOutSignals,NewtonInfo)
        hNewNet=getRecipNewtonRsqrtBasedNetwork(hN,hInSignals,hOutSignals,NewtonInfo)
        hNewNet=getRecipNewtonRsqrtBasedSingleRateNetwork(hN,hInSignals,hOutSignals,NewtonInfo)

    end
end

