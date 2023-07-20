classdef(Abstract)FileHandler<matlab.mixin.Heterogeneous





    properties(Abstract,Constant)

        Type(1,1)string;
    end

    methods





        changeName(this,filePath,oldVariableName,newVariableName);








        modifyObject(this,filePath,variableName,updateSignalFunc);
    end
end

