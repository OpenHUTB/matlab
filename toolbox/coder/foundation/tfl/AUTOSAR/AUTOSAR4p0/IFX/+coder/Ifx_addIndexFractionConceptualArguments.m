function hEnt=Ifx_addIndexFractionConceptualArguments(hEnt,argString,argdatatype,typeOfArgument,isBus)

    if~isBus
        arg=hEnt.getTflArgFromString(argString{1},argdatatype{1}{1});
        arg.IOType=typeOfArgument;


        hEnt.addConceptualArg(arg);

        arg=hEnt.getTflArgFromString(argString{2},argdatatype{2}{1});
        arg.IOType=typeOfArgument;


        hEnt.addConceptualArg(arg);

    else
        elemT1=coder.Ifx_getDistributedStructElement('Unsigned',16,0,'Index');
        elemT2=coder.Ifx_getDistributedStructElement('Unsigned',16,16,'Ratio');
        identifier='Ifx_DPResultU16_Type';

        ssType=embedded.structtype;
        ssType.Elements=[elemT1,elemT2];
        ssType.Identifier=identifier;

        arg=RTW.TflArgStruct(argString{1},typeOfArgument,ssType);
        hEnt.addConceptualArg(arg);
    end

end
