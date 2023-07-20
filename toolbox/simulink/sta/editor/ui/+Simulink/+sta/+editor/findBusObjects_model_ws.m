function nameOfBusObjects=findBusObjects_model_ws(modelName)



    nameOfBusObjects={};

    mdlWks=get_param(modelName,'ModelWorkspace');
    whosInTheBase=evalin(mdlWks,'whos');

    allVarNames={whosInTheBase.name};
    allVarClass={whosInTheBase.class};

    IS_BUS_OBJ=strcmpi(allVarClass,'Simulink.Bus');


    if any(IS_BUS_OBJ)

        nameOfBusObjects=allVarNames(IS_BUS_OBJ);

    end
