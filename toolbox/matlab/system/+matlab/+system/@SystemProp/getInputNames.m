function names=getInputNames(obj)










    if getNumFixedInputs(obj)<0
        names="";
        return;
    end

    names=callUserImpl(obj);
    names=addSourceSetNames(obj,names);
end

function names=callUserImpl(obj)
    expectedNameCount=getNumFixedInputs(obj);
    implOutputCount=matlab.system.internal.numMethodOutputs(obj,'getInputNamesImpl');
    nameFcn=@obj.getInputNamesImpl;

    names=matlab.system.internal.getInputOrOutputNames(nameFcn,implOutputCount,expectedNameCount,'getInputNamesInvalid');
end

function names=addSourceSetNames(obj,names)
    if obj.hasSourceSets()

        info=matlab.system.internal.getSourceSetInfo(obj);
        propOrInput=info.PropertyOrInput;

        sourceSetNames=string({propOrInput([propOrInput.UseInput]).InputLabel});

        names=[names;sourceSetNames(:)];
    end
end
