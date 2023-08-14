function cm_name=getAndCheckASAP2CompuMethodName(datatype,units)






    cm_name=getCompuMethodName(datatype,units);





    isValid=isempty(regexp(cm_name,'^\d|[^a-zA-Z_0-9]','once'));

    if~isValid

        cm_name='';
    end
