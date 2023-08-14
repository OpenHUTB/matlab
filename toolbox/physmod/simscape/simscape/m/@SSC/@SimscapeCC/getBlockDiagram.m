function bd=getBlockDiagram(this)







    bd=this.up;
    while~(isempty(bd)||bd.isa('Simulink.ConfigSet'))
        bd=bd.up;
    end
    if isa(bd,'Simulink.ConfigSet')
        bdhdl=bd.getModel;
        bd=get_param(bdhdl,'Object');
    end



