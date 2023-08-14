function turnHighlightingOff()





    ma=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if~isempty(ma)
        ma.closeInformer();
    end
end