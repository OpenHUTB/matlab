function isusingsimstate=nesl_isusingsimstate(modelName)








    if strcmpi(get_param(modelName,'LoadInitialState'),'off')
        isusingsimstate=false;
        return;
    end




    nameInitialState=get_param(modelName,'InitialState');





    try
        initialState=slResolve(nameInitialState,modelName);
        isusingsimstate=isa(initialState,'Simulink.op.ModelOperatingPoint');
    catch
        isusingsimstate=false;
    end
end
