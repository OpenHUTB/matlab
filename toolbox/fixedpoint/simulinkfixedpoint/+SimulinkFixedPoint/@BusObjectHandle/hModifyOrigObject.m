function hModifyOrigObject(h)






    if isempty(h.busObjContextModel)||~isa(h.busObjContextModel,'Simulink.BlockDiagram')
        assignin('base',h.busName,h.busObj);
    else
        assigninGlobalScope(h.busObjContextModel.getFullName,h.busName,h.busObj);
    end


