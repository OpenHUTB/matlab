function hEnt=Ifl_addIndexFractionConceptualArguments(hEnt,argString,argdatatype,typeOfArgument,isBus)

    if~isBus
        arg=hEnt.getTflArgFromString(argString{1},argdatatype{1});
        arg.IOType=typeOfArgument;
        hEnt.addConceptualArg(arg);

        arg=hEnt.getTflArgFromString(argString{2},argdatatype{2});
        arg.IOType=typeOfArgument;
        hEnt.addConceptualArg(arg);

    else
        [elemT1,elemT2]=coder.Ifl_getDistributedStructElements;

        ssType=embedded.structtype;
        ssType.Elements=[elemT1,elemT2];
        ssType.Identifier='Ifl_DPResultF32_Type';

        arg=RTW.TflArgStruct(argString{1},typeOfArgument,ssType);
        hEnt.addConceptualArg(arg);

    end

end
