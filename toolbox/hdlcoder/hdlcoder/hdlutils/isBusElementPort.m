function val=isBusElementPort(obj)

    val=(isa(obj,'Simulink.Inport')||isa(obj,'Simulink.Outport'))&&strcmp(obj.isBusElementPort,'on');
end