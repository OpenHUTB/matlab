function RTWRemove(obj)





    if isR2010bOrEarlier(obj.ver)
        cs=getActiveConfigSet(obj.modelName);
        if isa(cs,'Simulink.ConfigSet')
            cs.CurrentDlgPage=strrep(cs.CurrentDlgPage,'Code Generation','Real-Time Workshop');
        end
    end

end

