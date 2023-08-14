function[state,message]=systemSelector(obj,~)






    result=isa(obj,'Simulink.BlockDiagram')||...
    isa(obj,'Simulink.ModelReference');

    if result
        state='supported';
        message='';
    else
        state='nonsupported';
        message='Selection is not supported.';
    end
