function open(modelName,type)

















    if nargin==1
        type='';
    end
    Simulink.ModelReference.ProtectedModel.open(modelName,'',type);


