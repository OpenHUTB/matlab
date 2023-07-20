function fpMap=vhdlgetFpMap(this,port)






    fpMapKeySet=getHDLSignals(this,'in',port);

    if port.dataIsComplex
        fpMapValueSet=cell(1,2);
        for ii=1:2
            fpMapValueSet{ii}=fpMapKeySet(ii);
        end
    else
        fpMapValueSet={fpMapKeySet};
    end

    fpMap=containers.Map(fpMapKeySet,fpMapValueSet);
end
