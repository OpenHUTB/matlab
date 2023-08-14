function hdlcc=gethdlcconfigset(cs)









    narginchk(1,1);



    if isa(cs,'hdlcoderui.hdlcc')
        hdlcc=cs;
    else
        if~isa(cs,'Simulink.ConfigSet')&&~isa(cs,'Simulink.ConfigSetRef')
            error(message('HDLShared:directemit:InvalidConfigSet'));
        end
        hdlcc=cs.getComponent('HDL Coder');



        if isempty(hdlcc)
            comps=cs.Components;
            for ii=1:numel(comps)
                if isa(comps(ii),'hdlcoderui.hdlcc')
                    mdlName=comps(ii).getModelName;
                    error(message('HDLShared:hdlcoderui:badcomponentname',mdlName,mdlName,mdlName));
                end
            end
        end
    end
end


