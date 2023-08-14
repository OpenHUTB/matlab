


function obj=getInstance

    persistent ins;
    mlock;

    if isempty(ins)
        ins=slci.manualreview.Manager;
    end

    obj=ins;
