function hEnt=Ifx_addIndexFractionImplementationArguments(hEnt,argString,structName,typeOfArgument,isBus)






    elemT1=coder.Ifx_getDistributedStructElement('Unsigned',16,0,'Index');

    elemT2=coder.Ifx_getDistributedStructElement('Unsigned',16,0,'Ratio');

    ssType=embedded.structtype;
    ssType.Identifier='Ifx_DPResultU16_Type';
    ssType.Elements=[elemT1,elemT2];


    pT=embedded.pointertype;
    pT.BaseType=ssType;

    arg=RTW.TflArgPointer;
    arg.Type=pT;
    arg.IOType=typeOfArgument;

    if strcmp(typeOfArgument,'RTW_IO_INPUT')
        arg.Type.BaseType.ReadOnly=true;
    end

    if isBus
        arg.Name=argString{1};
        hEnt.Implementation.addArgument(arg);
    else
        arg.Name=structName;
        hEnt.Implementation.addArgument(arg);
        hEnt.Implementation.StructFieldMap={structName,{'Index',argString{1},'Ratio',argString{2}}};
    end

end
