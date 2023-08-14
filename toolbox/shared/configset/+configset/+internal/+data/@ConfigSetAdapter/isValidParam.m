function out=isValidParam(obj,name)








    cs=obj.Source;
    if isa(cs,'Simulink.ConfigSetRef')
        cs=cs.getRefConfigSet;
    end
    if cs.isConfigSetParam(name)
        out=true;
    else

        hdlcc=cs.getComponent('HDL Coder');

        out=~isempty(hdlcc)&&~isempty(hdlcc.getCLI)&&...
        isprop(hdlcc.getCLI,name);
    end



