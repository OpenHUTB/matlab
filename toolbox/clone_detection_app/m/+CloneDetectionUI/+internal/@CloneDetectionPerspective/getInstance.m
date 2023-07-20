function obj=getInstance


    persistent ins;
    mlock;

    if isempty(ins)
        ins=CloneDetectionUI.internal.CloneDetectionPerspective;
    end

    obj=ins;