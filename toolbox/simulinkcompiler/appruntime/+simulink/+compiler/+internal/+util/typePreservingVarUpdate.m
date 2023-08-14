function variable=typePreservingVarUpdate(variable,newData)




    castNewData=class(variable.Value)+"("+string(newData)+")";
    newData=eval(join(castNewData,''));
    variable.Value=newData;
end