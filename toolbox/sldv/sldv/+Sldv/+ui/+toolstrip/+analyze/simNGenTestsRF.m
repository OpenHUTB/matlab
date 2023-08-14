function simNGenTestsRF(~,cbinfo,action)




    if slavteng('feature','SimulateNExtend')>0
        system=Sldv.ui.toolstrip.internal.getsystemselectorinfo(cbinfo);
        if system.isModelReference
            action.enabled=true;
        else
            action.enabled=false;
        end
    else
        action.enabled=false;
    end
end


