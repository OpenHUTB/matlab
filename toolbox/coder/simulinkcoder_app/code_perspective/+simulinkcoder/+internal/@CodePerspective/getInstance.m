function obj=getInstance



    persistent ins;
    mlock;

    if isempty(ins)
        ins=simulinkcoder.internal.CodePerspective;
    end

    obj=ins;