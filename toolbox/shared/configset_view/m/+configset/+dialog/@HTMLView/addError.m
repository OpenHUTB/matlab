function addError(obj,error)





    name=error.name;
    obj.errorMap(name)=error;
    obj.updateError(error,true);




