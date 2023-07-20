function obj=getInstance



    persistent ins;
    mlock;

    if isempty(ins)
        ins=simulinkcoder.internal.Report;
    end

    obj=ins;

