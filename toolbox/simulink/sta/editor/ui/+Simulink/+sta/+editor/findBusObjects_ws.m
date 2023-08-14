function nameOfBusObjects=findBusObjects_ws()



    nameOfBusObjects={};

    whosInTheBase=evalin('base','whos');

    allVarNames={whosInTheBase.name};
    allVarClass={whosInTheBase.class};

    IS_BUS_OBJ=strcmpi(allVarClass,'Simulink.Bus');


    if any(IS_BUS_OBJ)

        nameOfBusObjects=allVarNames(IS_BUS_OBJ);

    end