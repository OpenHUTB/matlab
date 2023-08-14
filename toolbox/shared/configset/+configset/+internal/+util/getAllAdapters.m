function out=getAllAdapters(cs)

    f=@configset.internal.util.getAllAdapters;

    if isempty(cs)
        out=[];
    elseif isa(cs,'Simulink.ConfigSetDialogController')
        if~isempty(cs.csv2)
            out={cs.csv2};
        else
            out=[];
        end
    else
        out=[f(cs.right);f(cs.down)];
    end
