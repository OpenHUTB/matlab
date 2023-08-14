



function obj=getInstance

    persistent ins;
    mlock;

    if isempty(ins)
        ins=slci.view.Manager;
    end

    obj=ins;