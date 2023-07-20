function[state,message]=systemSelectorCD(obj,~)




    result=isa(obj,'Simulink.BlockDiagram')||...
    isa(obj,'Simulink.SubSystem')||...
    isa(obj,'Simulink.ModelReference');

    if result
        state='supported';
        message='';
    else
        state='nonsupported';
        message='Selection is not supported.';
    end
