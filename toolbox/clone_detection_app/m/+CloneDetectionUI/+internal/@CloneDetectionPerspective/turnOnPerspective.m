function turnOnPerspective(input)




    if nargin==1
        src=simulinkcoder.internal.util.getSource();
    else
        src=simulinkcoder.internal.util.getSource(input);
    end

    sysHandle=src.modelH;
    clonedetectionobj=get_param(sysHandle,'CloneDetectionUIObj');

    if isempty(clonedetectionobj)
        clonedetectionobj=CloneDetectionUI.CloneDetectionUI(sysHandle);
        set_param(sysHandle,'CloneDetectionUIObj',clonedetectionobj);
    end

    CloneDetectionUI.internal.util.showEmbedded(clonedetectionobj.ddgHelp,'Left','Tabbed');
    CloneDetectionUI.internal.util.showEmbedded(clonedetectionobj.ddgRight,'Right','Tabbed');
    CloneDetectionUI.internal.util.showEmbedded(clonedetectionobj.ddgBottom,'Bottom','Tabbed');


