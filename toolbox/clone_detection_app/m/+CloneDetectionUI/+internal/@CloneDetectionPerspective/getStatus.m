function bool=getStatus(editor)




    src=simulinkcoder.internal.util.getSource();
    uiobj=get_param(src.modelH,'CloneDetectionUIObj');
    if isempty(uiobj)||(~isa(uiobj,'CloneDetectionUI.CloneDetectionUI'))
        bool=true;
    else
        bool=false;
    end

