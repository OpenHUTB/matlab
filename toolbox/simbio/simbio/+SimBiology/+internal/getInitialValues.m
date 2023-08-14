






















function[initialStateValuesInUserUnits,parameterValuesInUserUnits]=getInitialValues(odedata)
    validateattributes(odedata,{'SimBiology.internal.ODESimulationData'},{'scalar'});



    [initialStateValuesInEngine,parameterValuesInEngineUnits]=SimBiology.internal.convertStateVector.toConcentration(odedata.X0,odedata.P,odedata.speciesIndexToConstantCompartment,odedata.speciesIndexToVaryingCompartment);


    if isempty(odedata.XUCM)
        initialStateValuesInUserUnits=initialStateValuesInEngine;
    else
        initialStateValuesInUserUnits=initialStateValuesInEngine./odedata.XUCM';
    end


    if isempty(odedata.PUCM)
        parameterValuesInUserUnits=parameterValuesInEngineUnits;
    else
        parameterValuesInUserUnits=parameterValuesInEngineUnits./odedata.PUCM';
    end

end
