function classType=getPrecisionClassType(precisionSetValue)






    if(strcmp(precisionSetValue,'on'))
        classType='double';
    else

        classType='single';
    end
