function obj=getInstance()




    persistent h

    if isempty(h)
        h=slmle.internal.EMLEditorApi();
    end

    obj=h;



