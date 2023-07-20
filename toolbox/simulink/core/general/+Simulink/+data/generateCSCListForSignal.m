function retVal=generateCSCListForSignal





    persistent classname;
    persistent defaultList;

    defaultClassname=Simulink.data.getDefaultClassname('Signal');


    if isempty(classname)||~strcmp(defaultClassname,classname)
        hClass=meta.class.fromName(defaultClassname);
        assert(Simulink.data.isDerivedFrom(hClass,'Simulink.Signal'));
        tempObj=feval(defaultClassname);
        defaultList=getPropAllowedValues(tempObj,'StorageClass');
        classname=defaultClassname;
    end

    retVal=defaultList;
end

