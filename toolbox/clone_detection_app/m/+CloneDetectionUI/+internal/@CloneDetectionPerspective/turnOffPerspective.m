function turnOffPerspective(input)




    if nargin<=1
        src=simulinkcoder.internal.util.getSource();
    else
        src=simulinkcoder.internal.util.getSource(input);
    end

    sysHandle=src.modelH;


    CloneDetectionUI.internal.util.removeAllHighlights;

    clonedetectionobj=get_param(sysHandle,'CloneDetectionUIObj');
    CloneDetectionUI.internal.util.hideEmbedded(clonedetectionobj.ddgHelp);
    CloneDetectionUI.internal.util.hideEmbedded(clonedetectionobj.ddgRight);
    CloneDetectionUI.internal.util.hideEmbedded(clonedetectionobj.ddgBottom);
    set_param(sysHandle,'CloneDetectionUIObj','');



