function[state,message]=psSystemSelectorBehavior(obj,~)
    result=isa(obj,'Simulink.BlockDiagram')||...
    isa(obj,'Simulink.SubSystem')||...
    isa(obj,'Simulink.SFunction');

    if result
        state='supported';
        message='';
    else
        state='nonsupported';
        message='Selection is not supported.';
    end
